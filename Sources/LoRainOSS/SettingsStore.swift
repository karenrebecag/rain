import AppKit
import SwiftUI

final class SettingsStore: ObservableObject {
    @Published var isRaining: Bool { didSet { defaults.set(isRaining, forKey: Key.isRaining) } }
    @Published var floatsAboveWindows: Bool { didSet { defaults.set(floatsAboveWindows, forKey: Key.floatsAbove) } }
    @Published var fps: Int { didSet { defaults.set(fps, forKey: Key.fps) } }

    @Published var rainAngle: Double { didSet { defaults.set(rainAngle, forKey: Key.rainAngle) } }
    @Published var rainSpeed: Double { didSet { defaults.set(rainSpeed, forKey: Key.rainSpeed) } }
    @Published var rainIntensity: Double { didSet { defaults.set(rainIntensity, forKey: Key.rainIntensity) } }
    @Published var rainOpacity: Double { didSet { defaults.set(rainOpacity, forKey: Key.rainOpacity) } }
    @Published var rainColor: Color { didSet { defaults.set(rainColor.hexString, forKey: Key.rainColor) } }

    @Published var fireflyCount: Int { didSet { defaults.set(fireflyCount, forKey: Key.fireflyCount) } }
    @Published var fireflyHeightPercent: Double { didSet { defaults.set(fireflyHeightPercent, forKey: Key.fireflyHeight) } }
    @Published var fireflySpeed: Double { didSet { defaults.set(fireflySpeed, forKey: Key.fireflySpeed) } }
    @Published var fireflyColor: Color { didSet { defaults.set(fireflyColor.hexString, forKey: Key.fireflyColor) } }

    @Published var dockHoverTrackingEnabled: Bool { didSet { defaults.set(dockHoverTrackingEnabled, forKey: Key.dockHover) } }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isRaining = defaults.object(forKey: Key.isRaining) as? Bool ?? true
        floatsAboveWindows = defaults.object(forKey: Key.floatsAbove) as? Bool ?? true
        fps = defaults.object(forKey: Key.fps) as? Int ?? 60

        rainAngle = defaults.object(forKey: Key.rainAngle) as? Double ?? -12
        rainSpeed = defaults.object(forKey: Key.rainSpeed) as? Double ?? 480
        rainIntensity = defaults.object(forKey: Key.rainIntensity) as? Double ?? 150
        rainOpacity = defaults.object(forKey: Key.rainOpacity) as? Double ?? 0.5
        rainColor = Color(hex: defaults.string(forKey: Key.rainColor)) ?? .white

        fireflyCount = defaults.object(forKey: Key.fireflyCount) as? Int ?? 6
        fireflyHeightPercent = defaults.object(forKey: Key.fireflyHeight) as? Double ?? 0.18
        fireflySpeed = defaults.object(forKey: Key.fireflySpeed) as? Double ?? 40
        fireflyColor = Color(hex: defaults.string(forKey: Key.fireflyColor)) ?? .yellow

        dockHoverTrackingEnabled = defaults.object(forKey: Key.dockHover) as? Bool ?? true
    }

    private enum Key {
        static let isRaining = "isRaining"
        static let floatsAbove = "floatsAboveWindows"
        static let fps = "fps"
        static let rainAngle = "rainAngle"
        static let rainSpeed = "rainSpeed"
        static let rainIntensity = "rainDropsPerSecond"
        static let rainOpacity = "rainOpacity"
        static let rainColor = "rainColor"
        static let fireflyCount = "fireflyCount"
        static let fireflyHeight = "fireflyHeightPercent"
        static let fireflySpeed = "fireflySpeed"
        static let fireflyColor = "fireflyColor"
        static let dockHover = "dockHoverTrackingEnabled"
    }
}

extension Color {
    init?(hex: String?) {
        guard let hex, hex.count == 6, hex.allSatisfy(\.isHexDigit), let value = UInt32(hex, radix: 16) else {
            return nil
        }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b)
    }

    var hexString: String {
        let native = NSColor(self).usingColorSpace(.sRGB) ?? .white
        let component = { (value: CGFloat) in Int((min(max(value, 0), 1) * 255).rounded()) }
        return String(format: "%02X%02X%02X", component(native.redComponent), component(native.greenComponent), component(native.blueComponent))
    }
}
