import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settings: SettingsStore
    let onPickFireflyColor: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("Show rain effect", isOn: $settings.isRaining)
                Toggle("Floats above windows", isOn: $settings.floatsAboveWindows)

                labeledSlider("Raindrops per second", value: $settings.rainIntensity, range: 0...600, format: "%.0f")
                labeledSlider("Rain speed", value: $settings.rainSpeed, range: 100...1200, format: "%.0f")
                labeledSlider("Rain angle", value: $settings.rainAngle, range: -45...45, format: "%.0f°")
                labeledSlider("Raindrops opacity", value: $settings.rainOpacity, range: 0.05...1, format: "%.2f")

                Picker("FPS", selection: $settings.fps) {
                    Text("30").tag(30)
                    Text("60").tag(60)
                    Text("120").tag(120)
                }
                .pickerStyle(.segmented)

                Divider()
                Text("Fireflies").font(.headline)
                Stepper("Count: \(settings.fireflyCount)", value: $settings.fireflyCount, in: 0...30)
                labeledSlider("Height on screen", value: $settings.fireflyHeightPercent, range: 0.05...0.6, format: "%.2f")
                labeledSlider("Speed", value: $settings.fireflySpeed, range: 10...150, format: "%.0f")
                HStack {
                    Text("Firefly color")
                    Spacer()
                    Button(action: onPickFireflyColor) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(settings.fireflyColor)
                            .frame(width: 36, height: 18)
                            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(.secondary.opacity(0.5)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Choose firefly color")
                }

                Divider()
                Toggle("Hover dock effect", isOn: $settings.dockHoverTrackingEnabled)
                Text("Fireflies react when your mouse is over the Dock. It polls the pointer position, which costs a little CPU.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()
                Button("Quit lo-rain-oss", role: .destructive, action: onQuit)
            }
            .padding(16)
        }
        .frame(width: 300, height: 460)
    }

    private func labeledSlider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
        }
    }
}
