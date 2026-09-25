import AppKit
import Testing
@testable import LoRainOSS

@MainActor
struct ColorPanelControllerTests {
    // The panel must report to a long-lived controller: the popover that opened it is gone
    // as soon as the user clicks on the panel.
    @Test func panelChangesReachTheCallback() throws {
        let panel = NSColorPanel.shared
        let controller = ColorPanelController()
        var received: NSColor?
        controller.configure(panel, initial: NSColor.red) { received = $0 }

        #expect(panel.showsAlpha == false)
        panel.color = NSColor(srgbRed: 0.68, green: 0.75, blue: 0.52, alpha: 1)
        controller.colorDidChange(panel)

        let color = try #require(received?.usingColorSpace(.sRGB))
        #expect(abs(color.redComponent - 0.68) < 0.01)
        #expect(abs(color.greenComponent - 0.75) < 0.01)
    }

    @Test func configureShowsTheCurrentColor() throws {
        let panel = NSColorPanel.shared
        ColorPanelController().configure(panel, initial: NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)) { _ in }
        let color = try #require(panel.color.usingColorSpace(.sRGB))
        #expect(color.redComponent > 0.99 && color.greenComponent < 0.01)
    }

    @Test func reopeningReplacesThePreviousCallback() {
        let panel = NSColorPanel.shared
        let controller = ColorPanelController()
        var first = 0, second = 0
        controller.configure(panel, initial: NSColor.red) { _ in first += 1 }
        controller.configure(panel, initial: NSColor.blue) { _ in second += 1 }

        controller.colorDidChange(panel)
        #expect(first == 0)
        #expect(second == 1)
    }
}
