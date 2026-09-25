import AppKit

// SwiftUI's ColorPicker reports to the view that opened the panel; inside a transient
// popover that view is gone the moment the panel is clicked, so no color ever arrives.
final class ColorPanelController: NSObject {
    private var onChange: ((NSColor) -> Void)?

    func open(initial: NSColor, onChange: @escaping (NSColor) -> Void) {
        let panel = NSColorPanel.shared
        configure(panel, initial: initial, onChange: onChange)
        NSApp.activate(ignoringOtherApps: true)
        panel.orderFrontRegardless()
        panel.makeKey()
    }

    func configure(_ panel: NSColorPanel, initial: NSColor, onChange: @escaping (NSColor) -> Void) {
        // Cleared first so setting the initial color doesn't fire the previous callback.
        self.onChange = nil
        panel.showsAlpha = false
        panel.isContinuous = true
        panel.setTarget(self)
        panel.setAction(#selector(colorDidChange(_:)))
        panel.color = initial
        self.onChange = onChange
    }

    @objc func colorDidChange(_ sender: NSColorPanel) {
        onChange?(sender.color)
    }
}
