// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-dyld-private",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v15),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "DyldPrivate",
            targets: ["DyldPrivate"]
        ),
        .library(
            name: "DyldPrivateC",
            targets: ["DyldPrivateC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/securevale/swift-confidential.git", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "DyldPrivateC"
        ),
        .target(
            name: "DyldPrivate",
            dependencies: [
                "DyldPrivateC",
                .product(name: "ConfidentialKit", package: "swift-confidential"),
            ]
        ),
        .testTarget(
            name: "DyldPrivateCTests",
            dependencies: ["DyldPrivateC"]
        ),
        .testTarget(
            name: "DyldPrivateTests",
            dependencies: ["DyldPrivate"]
        ),
    ]
)
