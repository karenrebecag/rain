import AppKit

final class DockHoverTracker: ObservableObject {
    @Published private(set) var isHoveringDock = false
    @Published private(set) var dockFrame: CGRect?

    private var timer: Timer?
    private var ticksSinceLayout = 0
    private let pollInterval: TimeInterval = 0.15
    // Re-reading the Dock config every ~2 s catches app launches and Dock edits without
    // hitting cfprefsd on every mouse poll.
    private let layoutRefreshTicks = 13
    private let dockDefaults = UserDefaults(suiteName: "com.apple.dock")

    func start() {
        stop()
        refreshLayout()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isHoveringDock = false
    }

    private func poll() {
        ticksSinceLayout += 1
        if ticksSinceLayout >= layoutRefreshTicks {
            refreshLayout()
        }
        isHoveringDock = dockFrame?.contains(NSEvent.mouseLocation) ?? false
    }

    // HACK: assumes the Dock lives on the primary screen. Follow the Dock across displays
    // (it moves to whichever bottom edge the pointer rests on) when multi-monitor matters.
    private func refreshLayout() {
        ticksSinceLayout = 0
        guard let dockDefaults,
              let prefs = DockPreferences.read(from: dockDefaults),
              let screen = NSScreen.screens.first else {
            dockFrame = nil
            return
        }
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { $0.bundleURL?.absoluteString }
        let slots = DockLayout.appSlotCount(prefs: prefs, runningAppURLs: running)
        dockFrame = DockLayout.frame(prefs: prefs, appSlots: slots, screen: screen.frame)
    }
}
