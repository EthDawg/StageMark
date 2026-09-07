// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StageMark",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "StageMark", targets: ["StageMark"])],
    targets: [
        .executableTarget(name: "StageMark", linkerSettings: [.linkedFramework("Carbon")])
    ]
)
