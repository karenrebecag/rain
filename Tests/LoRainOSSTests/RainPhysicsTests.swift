import CoreGraphics
import Testing
@testable import LoRainOSS

private func close(_ a: CGFloat, _ b: CGFloat) -> Bool { abs(a - b) < 0.001 }

struct RainPhysicsTests {
    @Test func straightDownWhenAngleIsZero() {
        let v = RainPhysics.velocity(angleDegrees: 0, speed: 100)
        #expect(close(v.dx, 0))
        #expect(close(v.dy, -100))
    }

    @Test func angledVelocityKeepsSpeed() {
        let v = RainPhysics.velocity(angleDegrees: 30, speed: 100)
        #expect(close(v.dx, 50))
        #expect(close(v.dy, -86.6025))
    }

    @Test func streakRotationMatchesFallDirection() {
        #expect(close(RainPhysics.rotation(angleDegrees: 30), .pi / 6))
    }

    @Test func spawnRangeCoversDriftToTheRight() {
        let range = RainPhysics.spawnXRange(width: 1000, height: 1000, angleDegrees: 45)
        #expect(close(range.lowerBound, -1000))
        #expect(close(range.upperBound, 1000))
    }

    @Test func spawnRangeCoversDriftToTheLeft() {
        let range = RainPhysics.spawnXRange(width: 1000, height: 1000, angleDegrees: -45)
        #expect(close(range.lowerBound, 0))
        #expect(close(range.upperBound, 2000))
    }

    @Test func spawnRangeIsScreenWidthWhenStraight() {
        let range = RainPhysics.spawnXRange(width: 1000, height: 1000, angleDegrees: 0)
        #expect(range == 0...1000)
    }

    @Test func spawnsSeveralDropsPerFrameAtHighRates() {
        let result = RainPhysics.spawn(ratePerSecond: 283, delta: 1.0 / 120, carry: 0)
        #expect(result.count == 2)
        #expect(abs(result.carry - 0.3583) < 0.001)
    }

    @Test func carryAddsUpToTheExactRateOverOneSecond() {
        var carry = 0.0
        var total = 0
        for _ in 0..<120 {
            let result = RainPhysics.spawn(ratePerSecond: 283, delta: 1.0 / 120, carry: carry)
            total += result.count
            carry = result.carry
        }
        #expect(total == 283)
    }

    @Test func zeroOrNegativeRateSpawnsNothing() {
        #expect(RainPhysics.spawn(ratePerSecond: 0, delta: 1, carry: 0).count == 0)
        #expect(RainPhysics.spawn(ratePerSecond: -5, delta: 1, carry: 0.9).count == 0)
    }
}
