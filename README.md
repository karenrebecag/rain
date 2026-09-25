# Rain for macOS

A small open-source menu bar app that draws gentle rain and glowing fireflies over your desktop.
The effect lives in a transparent, click-through overlay on every screen, so it never gets in the
way of what you're doing.

## Features

- Rain drawn as a transparent overlay on every screen, floating above your windows (or behind
  them, if you prefer)
- Raindrops per second, speed, angle, opacity and FPS (30/60/120), all adjustable live
- Soft splashes where the raindrops land
- Fireflies with adjustable count, color, speed and how high they roam
- Fireflies scatter when your pointer hovers the Dock (optional)
- Optional: keep the overlay out of screenshots and screen recordings
- Uses no CPU when there's nothing to draw
- Settings are remembered across launches
- No accounts, no license keys, no network access, no telemetry

The Dock's position is computed from the system Dock preferences, so the app needs no
Accessibility or Screen Recording permission.

## Requirements

- macOS 12 or later
- Swift 5.9+ (Xcode 15 or later, or the Swift toolchain from swift.org)

## Install

```bash
./scripts/make-app.sh --install
```

This builds `Rain.app`, signs it locally and copies it to `/Applications`. Rain lives in the menu
bar (the cloud icon); click it to open the settings.

## Develop

```bash
swift run Rain      # run without installing
swift test          # run the test suite
```

## License

MIT — see [LICENSE](LICENSE).
