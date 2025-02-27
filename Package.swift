// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pushlytic",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Pushlytic",
            targets: ["Pushlytic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift", exact: "1.21.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Pushlytic",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
            ]
        ),
        .testTarget(
            name: "PushlyticTests",
            dependencies: ["Pushlytic"]),
    ]
)
