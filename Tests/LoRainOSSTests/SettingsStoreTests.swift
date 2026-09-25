import Foundation
import SwiftUI
import Testing
@testable import LoRainOSS

struct ColorHexTests {
    @Test func roundTripsSixDigitHex() {
        #expect(Color(hex: "FF8000")?.hexString == "FF8000")
        #expect(Color(hex: "abc1a5")?.hexString == "ABC1A5")
    }

    @Test(arguments: [nil, "", "FFF", "GGGGGG", "FF80001", "#FF8000"])
    func rejectsMalformedHex(_ input: String?) {
        #expect(Color(hex: input) == nil)
    }
}

struct SettingsStoreTests {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "lo-rain-oss.tests.\(UUID().uuidString)")!
    }

    @Test func freshInstallUsesDefaults() {
        let store = SettingsStore(defaults: makeDefaults())
        #expect(store.isRaining)
        #expect(store.floatsAboveWindows)
        #expect(store.fps == 60)
        #expect(store.rainIntensity == 150)
    }

    @Test func persistsAcrossLaunches() {
        let defaults = makeDefaults()
        let first = SettingsStore(defaults: defaults)
        first.isRaining = false
        first.fps = 120
        first.rainIntensity = 283
        first.rainColor = Color(hex: "ABC1A5")!
        first.fireflySpeed = 87

        let second = SettingsStore(defaults: defaults)
        #expect(second.isRaining == false)
        #expect(second.fps == 120)
        #expect(second.rainIntensity == 283)
        #expect(second.rainColor.hexString == "ABC1A5")
        #expect(second.fireflySpeed == 87)
    }
}
