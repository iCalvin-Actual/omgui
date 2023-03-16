// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "omgui",
    platforms: [
        .iOS("16.1"),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "omgui",
            targets: ["omgui"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", exact: "2.0.1"),
    ],
    targets: [
        .target(
            name: "omgui",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ]),
        .testTarget(
            name: "omguiTests",
            dependencies: ["omgui"]),
    ]
)
