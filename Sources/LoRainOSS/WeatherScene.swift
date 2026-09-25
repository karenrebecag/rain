import AppKit
import Combine
import SpriteKit

final class WeatherScene: SKScene {
    weak var dockHoverTracker: DockHoverTracker?
    var windowOrigin: CGPoint = .zero

    private weak var settings: SettingsStore?
    private var lastUpdateTime: TimeInterval = 0
    private var spawnCarry = 0.0
    private var cancellables = Set<AnyCancellable>()
    private var drops: [Raindrop] = []
    private var fireflies: [Firefly] = []

    // Bounds the catch-up after sleep or a stalled frame so rain doesn't arrive in one burst.
    private static let maxFrameDelta: TimeInterval = 0.25
    private static let splashDuration: TimeInterval = 0.22
    private static let splashSize = CGSize(width: 8, height: 3)

    init(size: CGSize, settings: SettingsStore) {
        self.settings = settings
        super.init(size: size)
        backgroundColor = .clear
        anchorPoint = .zero
        observe(settings)
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    // @Published emits before the property changes, so each sink uses the emitted value.
    private func observe(_ settings: SettingsStore) {
        settings.$fireflyCount
            .sink { [weak self] count in self?.syncFireflies(count: count) }
            .store(in: &cancellables)
        settings.$fireflySpeed
            .sink { [weak self] speed in self?.fireflies.forEach { $0.setSpeed(speed) } }
            .store(in: &cancellables)
        settings.$fireflyColor
            .sink { [weak self] color in self?.fireflies.forEach { $0.setColor(NSColor(color)) } }
            .store(in: &cancellables)
    }

    private func syncFireflies(count: Int) {
        guard let settings else { return }
        if count > fireflies.count {
            let added = (fireflies.count..<count).map { _ in makeFirefly(settings: settings) }
            added.forEach { addChild($0) }
            fireflies += added
        } else {
            fireflies.dropFirst(count).forEach { $0.removeFromParent() }
            fireflies = Array(fireflies.prefix(count))
        }
    }

    private func makeFirefly(settings: SettingsStore) -> Firefly {
        let firefly = Firefly(color: NSColor(settings.fireflyColor), speed: settings.fireflySpeed)
        firefly.position = CGPoint(x: .random(in: 0...size.width), y: size.height * settings.fireflyHeightPercent)
        return firefly
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, Self.maxFrameDelta)
        lastUpdateTime = currentTime
        guard let settings else { return }

        if settings.isRaining {
            spawnDrops(delta: delta, settings: settings)
        }
        advanceDrops(delta: delta, settings: settings)
        advanceFireflies(delta: delta, settings: settings)
    }

    private func spawnDrops(delta: TimeInterval, settings: SettingsStore) {
        let result = RainPhysics.spawn(ratePerSecond: settings.rainIntensity, delta: delta, carry: spawnCarry)
        spawnCarry = result.carry
        guard result.count > 0 else { return }

        let velocity = RainPhysics.velocity(angleDegrees: settings.rainAngle, speed: settings.rainSpeed)
        let rotation = RainPhysics.rotation(angleDegrees: settings.rainAngle)
        let xRange = RainPhysics.spawnXRange(width: size.width, height: size.height, angleDegrees: settings.rainAngle)
        let color = NSColor(settings.rainColor)
        // Staggering the birth height by one frame of travel avoids drops falling in rows.
        let stagger = max(abs(velocity.dy) * CGFloat(delta), 1)

        for _ in 0..<result.count {
            let drop = Raindrop(texture: RainTextures.streak, size: RainTextures.streakSize)
            drop.color = color
            drop.colorBlendFactor = 1
            drop.alpha = settings.rainOpacity
            drop.zRotation = rotation
            drop.velocity = velocity
            drop.position = CGPoint(x: .random(in: xRange), y: size.height + RainTextures.streakSize.height + .random(in: 0...stagger))
            addChild(drop)
            drops.append(drop)
        }
    }

    // Drops keep falling after the rain is switched off, so the sky clears instead of freezing.
    private func advanceDrops(delta: TimeInterval, settings: SettingsStore) {
        let dt = CGFloat(delta)
        for drop in drops {
            drop.position = CGPoint(x: drop.position.x + drop.velocity.dx * dt, y: drop.position.y + drop.velocity.dy * dt)
        }
        let landed = drops.filter { $0.position.y <= 0 }
        drops = drops.filter { $0.position.y > 0 }

        for drop in landed {
            if (0...size.width).contains(drop.position.x) {
                addChild(makeSplash(atX: drop.position.x, settings: settings))
            }
            drop.removeFromParent()
        }
    }

    private func makeSplash(atX x: CGFloat, settings: SettingsStore) -> SKNode {
        let splash = SKSpriteNode(texture: RainTextures.glow, size: Self.splashSize)
        splash.color = NSColor(settings.rainColor)
        splash.colorBlendFactor = 1
        splash.alpha = settings.rainOpacity
        splash.position = CGPoint(x: x, y: Self.splashSize.height / 2)
        splash.run(.sequence([
            .group([.scale(to: 2.2, duration: Self.splashDuration), .fadeOut(withDuration: Self.splashDuration)]),
            .removeFromParent()
        ]))
        return splash
    }

    private func advanceFireflies(delta: TimeInterval, settings: SettingsStore) {
        let bandHeight = size.height * max(settings.fireflyHeightPercent, 0.1) + 60
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: bandHeight)
        let hoverPoint = dockHoverPointInSceneSpace()
        for firefly in fireflies {
            firefly.update(delta: delta, bounds: bounds, dockHoverPoint: hoverPoint, dockHoverRadius: 90)
        }
    }

    private func dockHoverPointInSceneSpace() -> CGPoint? {
        guard let tracker = dockHoverTracker, tracker.isHoveringDock else { return nil }
        let mouse = NSEvent.mouseLocation
        return CGPoint(x: mouse.x - windowOrigin.x, y: mouse.y - windowOrigin.y)
    }
}
