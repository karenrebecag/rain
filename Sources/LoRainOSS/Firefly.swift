import SpriteKit

final class Firefly: SKNode {
    static let coreDiameter: CGFloat = 2.5
    static let glowDiameter: CGFloat = 40
    private static let glowAlpha: CGFloat = 0.45

    private let halo: SKSpriteNode
    private let core: SKSpriteNode
    private var velocity = CGVector(dx: 0, dy: 0)
    private var directionChangeTimer: TimeInterval = 0
    private var baseSpeed: Double
    private var fleeing = false

    init(color: NSColor, speed: Double) {
        baseSpeed = speed
        halo = SKSpriteNode(texture: RainTextures.glow, size: CGSize(width: Self.glowDiameter, height: Self.glowDiameter))
        halo.color = color
        halo.colorBlendFactor = 1
        halo.alpha = Self.glowAlpha
        halo.blendMode = .add
        core = SKSpriteNode(texture: RainTextures.disc, size: CGSize(width: Self.coreDiameter, height: Self.coreDiameter))
        super.init()
        addChild(halo)
        addChild(core)
        pickNewDirection()
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    func setColor(_ color: NSColor) {
        halo.color = color
    }

    func setSpeed(_ speed: Double) {
        let scale = baseSpeed > 0 ? CGFloat(speed / baseSpeed) : 0
        baseSpeed = speed
        if scale > 0 {
            velocity = CGVector(dx: velocity.dx * scale, dy: velocity.dy * scale)
        } else {
            pickNewDirection()
        }
    }

    func update(delta: TimeInterval, bounds: CGRect, dockHoverPoint: CGPoint?, dockHoverRadius: CGFloat) {
        directionChangeTimer -= delta
        // A random pick mid-flee would strand the firefly in `fleeing` and mute later hovers.
        if directionChangeTimer <= 0 && !fleeing { pickNewDirection() }

        if let dockHoverPoint, !fleeing, distance(from: position, to: dockHoverPoint) < dockHoverRadius {
            flee(from: dockHoverPoint)
        }

        let dt = CGFloat(delta)
        var next = CGPoint(x: position.x + velocity.dx * dt, y: position.y + velocity.dy * dt)
        next.x = min(max(next.x, bounds.minX), bounds.maxX)
        next.y = min(max(next.y, bounds.minY), bounds.maxY)
        position = next

        if fleeing, position.y >= bounds.maxY * 0.6 {
            fleeing = false
        }
    }

    private func pickNewDirection() {
        directionChangeTimer = Double.random(in: 1.5...3.5)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        velocity = CGVector(dx: cos(angle) * baseSpeed, dy: sin(angle) * baseSpeed * 0.4)
    }

    private func flee(from point: CGPoint) {
        fleeing = true
        let direction: Double = position.x >= point.x ? 1 : -1
        velocity = CGVector(dx: direction * baseSpeed * 2.5, dy: baseSpeed * 3)
    }

    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}
