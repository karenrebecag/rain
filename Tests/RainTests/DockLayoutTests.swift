import CoreGraphics
import Foundation
import Testing
@testable import Rain

private let screen = CGRect(x: 0, y: 0, width: 1800, height: 1169)
private let finderURL = "file:///System/Library/CoreServices/Finder.app/"

private func prefs(
    tileSize: CGFloat = 42,
    orientation: DockOrientation = .bottom,
    persistentApps: Int = 30,
    spacers: Int = 0,
    others: Int = 1,
    showRecents: Bool = false,
    recents: Int = 0
) -> DockPreferences {
    DockPreferences(
        tileSize: tileSize,
        orientation: orientation,
        autohide: true,
        magnification: true,
        largeSize: 51,
        persistentAppURLs: (0..<persistentApps).map { "file:///Applications/App\($0).app/" },
        persistentSpacerCount: spacers,
        persistentOthersCount: others,
        showRecents: showRecents,
        recentAppsCount: recents
    )
}

struct DockLayoutTests {
    @Test func appSlotsCountFinderPersistentAndRunningExtras() {
        let running = [finderURL, "file:///Applications/App3.app/", "file:///Applications/Extra1.app/", "file:///Applications/Extra2.app/"]
        #expect(DockLayout.appSlotCount(prefs: prefs(), runningAppURLs: running) == 33)
    }

    @Test func spacersTakeASlot() {
        #expect(DockLayout.appSlotCount(prefs: prefs(spacers: 2), runningAppURLs: []) == 33)
    }

    // Measured via Accessibility on a real Dock: tilesize 42, 33 apps, 1 folder, Trash.
    @Test func bottomFrameMatchesMeasuredDock() {
        let frame = DockLayout.frame(prefs: prefs(), appSlots: 33, screen: screen)
        #expect(frame == CGRect(x: 117, y: 0, width: 1566, height: 56))
    }

    @Test func recentsAddASeparatorAndTheirSlots() {
        let base = DockLayout.frame(prefs: prefs(), appSlots: 33, screen: screen)
        let withRecents = DockLayout.frame(prefs: prefs(showRecents: true, recents: 3), appSlots: 33, screen: screen)
        #expect(abs((withRecents.width - base.width) - (19 + 3 * 44)) < 0.001)
    }

    @Test func leftDockIsVerticalAndCentered() {
        let frame = DockLayout.frame(prefs: prefs(orientation: .left), appSlots: 10, screen: screen)
        #expect(frame.minX == 0)
        #expect(frame.width == 56)
        #expect(abs(frame.midY - screen.midY) < 0.5)
    }

    @Test func rightDockHugsTheRightEdge() {
        let frame = DockLayout.frame(prefs: prefs(orientation: .right), appSlots: 10, screen: screen)
        #expect(frame.maxX == screen.maxX)
    }

    @Test func frameFollowsScreenOrigin() {
        let offset = CGRect(x: 1800, y: 200, width: 1800, height: 1169)
        let frame = DockLayout.frame(prefs: prefs(), appSlots: 33, screen: offset)
        #expect(frame.origin == CGPoint(x: 1917, y: 200))
    }
}

struct DockPreferencesTests {
    private func makeDefaults() -> UserDefaults {
        let suite = "rain.tests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suite)!
    }

    private func appTile(_ url: String) -> [String: Any] {
        ["tile-type": "file-tile", "tile-data": ["file-data": ["_CFURLString": url]]]
    }

    @Test func readsDockDomain() throws {
        let defaults = makeDefaults()
        defaults.set(42, forKey: "tilesize")
        defaults.set("left", forKey: "orientation")
        defaults.set(true, forKey: "autohide")
        defaults.set(true, forKey: "magnification")
        defaults.set(51, forKey: "largesize")
        defaults.set([appTile("file:///Applications/Safari.app/"), ["tile-type": "spacer-tile"]], forKey: "persistent-apps")
        defaults.set([["tile-type": "directory-tile"]], forKey: "persistent-others")
        defaults.set(true, forKey: "show-recents")
        defaults.set([appTile("file:///Applications/Notes.app/")], forKey: "recent-apps")

        let prefs = try #require(DockPreferences.read(from: defaults))
        #expect(prefs.tileSize == 42)
        #expect(prefs.orientation == .left)
        #expect(prefs.autohide)
        #expect(prefs.magnification)
        #expect(prefs.largeSize == 51)
        #expect(prefs.persistentAppURLs == ["file:///Applications/Safari.app/"])
        #expect(prefs.persistentSpacerCount == 1)
        #expect(prefs.persistentOthersCount == 1)
        #expect(prefs.showRecents)
        #expect(prefs.recentAppsCount == 1)
    }

    @Test func missingDockConfigReturnsNil() {
        #expect(DockPreferences.read(from: makeDefaults()) == nil)
    }

    @Test func unknownOrientationFallsBackToBottom() throws {
        let defaults = makeDefaults()
        defaults.set([appTile("file:///Applications/Safari.app/")], forKey: "persistent-apps")
        defaults.set("diagonal", forKey: "orientation")
        let prefs = try #require(DockPreferences.read(from: defaults))
        #expect(prefs.orientation == .bottom)
    }
}
