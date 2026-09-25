# lo-rain-oss

Open-source, clean-room reimplementation of [lo-rain](https://lo.cafe/lo-rain)'s desktop weather
effect for macOS: animated rain and fireflies drawn as a transparent overlay across your
screens, controlled from a menu bar icon.

Not affiliated with lo.cafe. No code or assets from the original app are included — the behavior
was inferred from its public bundle metadata (`Info.plist`, exported symbol names) and
reimplemented from scratch with SpriteKit, using original code and procedurally-drawn shapes
instead of the original's texture/particle files.

## Features

- Rain drawn as a transparent overlay per screen
- Configurable raindrops per second, speed, angle, opacity, color and FPS (30/60/120)
- Splash effect where raindrops land
- Fireflies: count, color, speed and how high they roam on screen
- Fireflies react to the mouse hovering the Dock (optional — polls the pointer, so it costs a
  bit of CPU when on). The Dock's frame is computed from `com.apple.dock` preferences, so no
  Accessibility or Screen Recording permission is needed
- Overlay can float above or stay below your other windows
- Menu bar popover for all settings, persisted across launches
- No trial, no license check, no telemetry — everything is free

## Requirements

- macOS 12+
- Swift 5.9+ (Xcode 15+ or the Swift toolchain from swift.org)

## Run

```bash
swift run LoRainOSS
```

## Test

```bash
swift test
```

## Build a release binary

```bash
swift build -c release
.build/release/LoRainOSS
```

## License

MIT — see [LICENSE](LICENSE).
