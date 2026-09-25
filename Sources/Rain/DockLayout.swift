import CoreGraphics
import Foundation

enum DockOrientation: String {
    case bottom
    case left
    case right
}

struct DockPreferences: Equatable {
    let tileSize: CGFloat
    let orientation: DockOrientation
    let autohide: Bool
    let magnification: Bool
    let largeSize: CGFloat
    let persistentAppURLs: [String]
    let persistentSpacerCount: Int
    let persistentOthersCount: Int
    let showRecents: Bool
    let recentAppsCount: Int

    // HACK: macOS only writes `tilesize` once the user changes it; 48 is an assumed factory
    // size. Measure a fresh account's Dock via Accessibility if frames come out wrong there.
    private static let assumedDefaultTileSize: CGFloat = 48
    private static let spacerTileTypes: Set<String> = ["spacer-tile", "small-spacer-tile"]

    static func read(from defaults: UserDefaults) -> DockPreferences? {
        guard let apps = defaults.array(forKey: "persistent-apps") as? [[String: Any]] else { return nil }
        let tileSize = number(defaults, "tilesize") ?? assumedDefaultTileSize
        return DockPreferences(
            tileSize: tileSize,
            orientation: DockOrientation(rawValue: defaults.string(forKey: "orientation") ?? "") ?? .bottom,
            autohide: defaults.bool(forKey: "autohide"),
            magnification: defaults.bool(forKey: "magnification"),
            largeSize: number(defaults, "largesize") ?? tileSize,
            persistentAppURLs: apps.compactMap(fileURL(of:)),
            persistentSpacerCount: apps.filter { spacerTileTypes.contains($0["tile-type"] as? String ?? "") }.count,
            persistentOthersCount: defaults.array(forKey: "persistent-others")?.count ?? 0,
            showRecents: defaults.bool(forKey: "show-recents"),
            recentAppsCount: defaults.array(forKey: "recent-apps")?.count ?? 0
        )
    }

    private static func number(_ defaults: UserDefaults, _ key: String) -> CGFloat? {
        (defaults.object(forKey: key) as? NSNumber).map { CGFloat($0.doubleValue) }
    }

    private static func fileURL(of tile: [String: Any]) -> String? {
        let tileData = tile["tile-data"] as? [String: Any]
        let fileData = tileData?["file-data"] as? [String: Any]
        return fileData?["_CFURLString"] as? String
    }
}

// Proportions measured on a real Dock via Accessibility (tilesize 42): every icon slot is
// tilesize + 2, the separator 19 pt, the bar tilesize + 14 thick, with 7 pt of end padding.
enum DockLayout {
    static let finderURL = "file:///System/Library/CoreServices/Finder.app/"
    private static let slotPadding: CGFloat = 2
    private static let separatorRatio: CGFloat = 0.45
    private static let thicknessPadding: CGFloat = 14
    private static let endPadding: CGFloat = 7

    static func appSlotCount(prefs: DockPreferences, runningAppURLs: [String]) -> Int {
        let pinned = Set(prefs.persistentAppURLs)
        let unpinnedRunning = Set(runningAppURLs).subtracting(pinned).subtracting([finderURL])
        return 1 + prefs.persistentAppURLs.count + prefs.persistentSpacerCount + unpinnedRunning.count
    }

    static func frame(prefs: DockPreferences, appSlots: Int, screen: CGRect) -> CGRect {
        let slot = prefs.tileSize + slotPadding
        let separator = (prefs.tileSize * separatorRatio).rounded()
        let thickness = prefs.tileSize + thicknessPadding
        let recents = prefs.showRecents ? separator + CGFloat(prefs.recentAppsCount) * slot : 0
        let trashSlot = slot
        let length = endPadding + CGFloat(appSlots) * slot + separator + recents
            + CGFloat(prefs.persistentOthersCount) * slot + trashSlot

        switch prefs.orientation {
        case .bottom:
            return CGRect(x: screen.midX - length / 2, y: screen.minY, width: length, height: thickness)
        case .left:
            return CGRect(x: screen.minX, y: screen.midY - length / 2, width: thickness, height: length)
        case .right:
            return CGRect(x: screen.maxX - thickness, y: screen.midY - length / 2, width: thickness, height: length)
        }
    }
}
