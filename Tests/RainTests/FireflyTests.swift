import AppKit
import SpriteKit
import Testing
@testable import Rain

private let tallBounds = CGRect(x: 0, y: 0, width: 1000, height: 10_000)

struct FireflyTests {
    // Flee velocity is speed * 3 upward; 5 s of fleeing must cover ~600 pt even though the
    // random direction timer (max 3.5 s) expires mid-flight.
    @Test func fleeSurvivesTheDirectionChangeTimer() {
        let firefly = Firefly(color: .yellow, speed: 40)
        firefly.position = CGPoint(x: 500, y: 10)

        firefly.update(delta: 0.1, bounds: tallBounds, dockHoverPoint: CGPoint(x: 500, y: 0), dockHoverRadius: 90)
        for _ in 0..<49 {
            firefly.update(delta: 0.1, bounds: tallBounds, dockHoverPoint: nil, dockHoverRadius: 90)
        }

        #expect(firefly.position.y > 590)
    }

    @Test func setSpeedAppliesImmediately() {
        let firefly = Firefly(color: .yellow, speed: 1)
        firefly.position = CGPoint(x: 500, y: 5000)
        firefly.setSpeed(100)

        firefly.update(delta: 0.1, bounds: tallBounds, dockHoverPoint: nil, dockHoverRadius: 90)

        let moved = hypot(firefly.position.x - 500, firefly.position.y - 5000)
        #expect(moved >= 4 && moved <= 10.001)
    }

    // Dragging the speed slider fires setSpeed on every tick; re-rolling the heading each
    // time made fireflies jitter. Speed must scale, heading must stay.
    @Test func setSpeedKeepsTheHeading() {
        let firefly = Firefly(color: .yellow, speed: 40)
        firefly.position = CGPoint(x: 500, y: 5000)
        firefly.update(delta: 0.01, bounds: tallBounds, dockHoverPoint: nil, dockHoverRadius: 90)
        let before = CGVector(dx: firefly.position.x - 500, dy: firefly.position.y - 5000)

        firefly.setSpeed(80)
        let start = firefly.position
        firefly.update(delta: 0.01, bounds: tallBounds, dockHoverPoint: nil, dockHoverRadius: 90)
        let after = CGVector(dx: firefly.position.x - start.x, dy: firefly.position.y - start.y)

        // SKNode stores positions as Float, so ~0.0005 pt of rounding at y = 5000 is expected.
        #expect(abs(after.dx - before.dx * 2) < 0.002)
        #expect(abs(after.dy - before.dy * 2) < 0.002)
    }
}

struct WeatherSceneTests {
    private func makeScene() -> (WeatherScene, SettingsStore) {
        let store = SettingsStore(defaults: UserDefaults(suiteName: "rain.tests.\(UUID().uuidString)")!)
        return (WeatherScene(size: CGSize(width: 1000, height: 1000), settings: store), store)
    }

    private func count<T>(_ type: T.Type, in scene: SKScene) -> Int {
        scene.children.filter { $0 is T }.count
    }

    @Test func fireflyCountFollowsTheSettingLive() {
        let (scene, store) = makeScene()
        store.fireflyCount = 3
        #expect(count(Firefly.self, in: scene) == 3)
        store.fireflyCount = 1
        #expect(count(Firefly.self, in: scene) == 1)
    }

    @Test func dropsFallOutInsteadOfFreezingWhenRainStops() {
        let (scene, store) = makeScene()
        store.fireflyCount = 0
        stride(from: 1.0, through: 2.0, by: 0.1).forEach { scene.update($0) }
        #expect(count(Raindrop.self, in: scene) > 0)

        store.isRaining = false
        stride(from: 2.1, through: 6.0, by: 0.1).forEach { scene.update($0) }
        #expect(count(Raindrop.self, in: scene) == 0)
    }
}
