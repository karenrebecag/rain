import AppKit
import SpriteKit
import Testing
@testable import Rain

private func makeStore() -> SettingsStore {
    SettingsStore(defaults: UserDefaults(suiteName: "rain.tests.\(UUID().uuidString)")!)
}

@MainActor
struct IdlePauseTests {
    private func presented(_ store: SettingsStore) -> (SKView, WeatherScene) {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let scene = WeatherScene(size: view.frame.size, settings: store)
        view.presentScene(scene)
        return (view, scene)
    }

    // With no rain and no fireflies there is nothing to draw, so the 120 fps loop must stop.
    @Test func pausesOnceTheSkyIsEmpty() {
        let store = makeStore()
        store.fireflyCount = 0
        store.isRaining = false
        let (view, scene) = presented(store)

        scene.update(1)
        scene.update(1.1)

        #expect(view.isPaused)
    }

    @Test func keepsRunningWhileDropsAreStillFalling() {
        let store = makeStore()
        store.fireflyCount = 0
        let (view, scene) = presented(store)
        stride(from: 1.0, through: 1.5, by: 0.1).forEach { scene.update($0) }

        store.isRaining = false
        scene.update(1.6)

        #expect(!view.isPaused)
    }

    @Test func resumesWhenRainStarts() {
        let store = makeStore()
        store.fireflyCount = 0
        store.isRaining = false
        let (view, scene) = presented(store)
        scene.update(1)
        scene.update(1.1)

        store.isRaining = true

        #expect(!view.isPaused)
    }

    @Test func resumesWhenFirefliesAreAdded() {
        let store = makeStore()
        store.fireflyCount = 0
        store.isRaining = false
        let (view, scene) = presented(store)
        scene.update(1)
        scene.update(1.1)

        store.fireflyCount = 2

        #expect(!view.isPaused)
    }
}

struct DockTrackingPolicyTests {
    @Test func tracksOnlyWhenEnabledAndSomethingCanReact() {
        #expect(DockHoverTracker.shouldTrack(enabled: true, fireflyCount: 3))
        #expect(!DockHoverTracker.shouldTrack(enabled: true, fireflyCount: 0))
        #expect(!DockHoverTracker.shouldTrack(enabled: false, fireflyCount: 3))
    }
}

@MainActor
struct ScreenSharingTests {
    @Test func overlayIsSharedByDefault() {
        let store = makeStore()
        #expect(store.hideFromScreenSharing == false)
        let window = OverlayWindow(screen: NSScreen.screens[0], settings: store)
        #expect(window.sharingType == .readOnly)
    }

    @Test func overlayCanBeHiddenFromCaptures() {
        let window = OverlayWindow(screen: NSScreen.screens[0], settings: makeStore())
        window.applySharing(hidden: true)
        #expect(window.sharingType == NSWindow.SharingType.none)
        window.applySharing(hidden: false)
        #expect(window.sharingType == .readOnly)
    }

    @Test func sharingChoicePersists() {
        let defaults = UserDefaults(suiteName: "rain.tests.\(UUID().uuidString)")!
        SettingsStore(defaults: defaults).hideFromScreenSharing = true
        #expect(SettingsStore(defaults: defaults).hideFromScreenSharing)
    }
}
