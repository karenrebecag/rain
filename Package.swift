// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Rain",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "Rain",
            path: "Sources/Rain"
        ),
        .testTarget(
            name: "RainTests",
            dependencies: ["Rain"],
            path: "Tests/RainTests"
        )
    ]
)
