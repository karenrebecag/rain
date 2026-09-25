// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LoRainOSS",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "LoRainOSS",
            path: "Sources/LoRainOSS"
        ),
        .testTarget(
            name: "LoRainOSSTests",
            dependencies: ["LoRainOSS"],
            path: "Tests/LoRainOSSTests"
        )
    ]
)
