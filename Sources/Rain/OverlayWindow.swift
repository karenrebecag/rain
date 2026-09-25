import AppKit
import CoreGraphics
import SpriteKit

final class OverlayWindow: NSWindow {
    private let skView: SKView
    let scene: WeatherScene

    weak var dockHoverTracker: DockHoverTracker? {
        didSet { scene.dockHoverTracker = dockHoverTracker }
    }

    init(screen: NSScreen, settings: SettingsStore) {
        let frame = screen.frame
        skView = SKView(frame: CGRect(origin: .zero, size: frame.size))
        scene = WeatherScene(size: frame.size, settings: settings)

        // NSWindow's `screen:`-taking initializer isn't safe to call from a Swift subclass
        // (crashes at runtime looking for the 4-arg initializer instead); use that one and
        // position the window onto `screen` afterwards via setFrame.
        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        setFrame(frame, display: false)
        applyLevel(above: settings.floatsAboveWindows)
        applyPreferredFPS(settings.fps)
        applySharing(hidden: settings.hideFromScreenSharing)

        scene.scaleMode = .resizeFill
        scene.windowOrigin = frame.origin
        skView.allowsTransparency = true
        skView.presentScene(scene)
        contentView = skView
    }

    func applyLevel(above: Bool) {
        if above {
            level = .floating
        } else {
            let desktopIconLevel = Int(CGWindowLevelForKey(.desktopIconWindow))
            level = NSWindow.Level(rawValue: desktopIconLevel + 1)
        }
    }

    // Verified on macOS 26.5: `.none` keeps the overlay out of screencapture output.
    func applySharing(hidden: Bool) {
        sharingType = hidden ? .none : .readOnly
    }

    func applyPreferredFPS(_ fps: Int) {
        skView.preferredFramesPerSecond = fps
    }
}
