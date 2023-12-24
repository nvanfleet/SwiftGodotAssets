// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SwiftGodotAssets",
    platforms: [.macOS(.v13), .iOS("16.0")],
    products: [
        .library(name: "SwiftGodotAssets", type: .dynamic, targets: ["SwiftGodotAssets"]),
        .plugin(name: "SwiftGodotAssetsPlugin", targets: ["SwiftGodotAssetsPlugin"]),
    ],
    dependencies: [.package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")],
    targets: [
        .target(name: "SwiftGodotAssets", dependencies: ["SwiftGodot"], path: "Source/SwiftGodotAssets",
                plugins: ["SwiftGodotAssetsPlugin"]),
        .executableTarget(name: "AssetGenerator", path: "Source/Generator"),
        .plugin(name: "SwiftGodotAssetsPlugin", capability: .buildTool(), dependencies: ["AssetGenerator"],
                path: "Source/Plugins/SwiftGodotAssetsPlugin"),
    ]
)
