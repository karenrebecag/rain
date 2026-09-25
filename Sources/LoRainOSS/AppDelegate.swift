import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = SettingsStore()
    private let dockHoverTracker = DockHoverTracker()
    private let colorPanel = ColorPanelController()
    private var overlayWindows: [ObjectIdentifier: OverlayWindow] = [:]
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        buildStatusItem()
        rebuildOverlayWindows()
        observeSettings()

        NotificationCenter.default.addObserver(
            self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
    }

    private func buildStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: "cloud.rain.fill", accessibilityDescription: "lo-rain-oss")
        item.button?.action = #selector(togglePopover)
        item.button?.target = self
        statusItem = item

        let content = NSPopover()
        content.behavior = .transient
        content.contentSize = CGSize(width: 300, height: 460)
        content.contentViewController = NSHostingController(
            rootView: MenuBarView(
                settings: settings,
                onPickFireflyColor: { [weak self] in self?.pickFireflyColor() },
                onQuit: { NSApp.terminate(nil) }
            )
        )
        popover = content
    }

    private func pickFireflyColor() {
        popover?.performClose(nil)
        colorPanel.open(initial: NSColor(settings.fireflyColor)) { [weak self] color in
            self?.settings.fireflyColor = Color(nsColor: color)
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func rebuildOverlayWindows() {
        overlayWindows.values.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()

        for screen in NSScreen.screens {
            let window = OverlayWindow(screen: screen, settings: settings)
            window.dockHoverTracker = dockHoverTracker
            window.orderFrontRegardless()
            overlayWindows[ObjectIdentifier(screen)] = window
        }
    }

    @objc private func screensChanged() {
        rebuildOverlayWindows()
    }

    private func observeSettings() {
        settings.$floatsAboveWindows
            .sink { [weak self] above in
                self?.overlayWindows.values.forEach { $0.applyLevel(above: above) }
            }
            .store(in: &cancellables)

        settings.$fps
            .sink { [weak self] fps in
                self?.overlayWindows.values.forEach { $0.applyPreferredFPS(fps) }
            }
            .store(in: &cancellables)

        settings.$hideFromScreenSharing
            .sink { [weak self] hidden in
                self?.overlayWindows.values.forEach { $0.applySharing(hidden: hidden) }
            }
            .store(in: &cancellables)

        settings.$dockHoverTrackingEnabled
            .combineLatest(settings.$fireflyCount)
            .map { DockHoverTracker.shouldTrack(enabled: $0, fireflyCount: $1) }
            .removeDuplicates()
            .sink { [weak self] track in
                track ? self?.dockHoverTracker.start() : self?.dockHoverTracker.stop()
            }
            .store(in: &cancellables)
    }
}
