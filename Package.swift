// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIDotAppDotLOL",
    platforms: [
        .iOS("16.1"),
    ],
    products: [
        .library(
            name: "UIDotAppDotLOL",
            targets: ["UIDotAppDotLOL"]),
    ],
    dependencies: [ 
    ],
    targets: [
        .target(
            name: "UIDotAppDotLOL",
            dependencies: [],
            path: "Sources/"
        ),
    ]
)
