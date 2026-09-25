import CoreGraphics
import Foundation

enum RainPhysics {
    static func velocity(angleDegrees: Double, speed: Double) -> CGVector {
        let angle = radians(angleDegrees)
        return CGVector(dx: sin(angle) * speed, dy: -cos(angle) * speed)
    }

    static func rotation(angleDegrees: Double) -> CGFloat {
        CGFloat(radians(angleDegrees))
    }

    // Angled drops drift sideways while falling, so they must be born past the edge they
    // drift away from or that side of the screen stays dry.
    static func spawnXRange(width: CGFloat, height: CGFloat, angleDegrees: Double) -> ClosedRange<CGFloat> {
        let drift = CGFloat(tan(radians(angleDegrees))) * height
        return min(0, -drift)...max(width, width - drift)
    }

    // Carries the fractional drop between frames so 283 drops/s at 120 fps spawns exactly 283.
    static func spawn(ratePerSecond: Double, delta: TimeInterval, carry: Double) -> (count: Int, carry: Double) {
        guard ratePerSecond > 0, delta > 0 else { return (0, 0) }
        let total = ratePerSecond * delta + carry
        let count = Int((total + 1e-9).rounded(.down))
        return (count, max(0, total - Double(count)))
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
