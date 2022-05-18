// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CKKeychain",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "CKKeychain",
            targets: ["CKKeychain"]
        )
    ],
    targets: [
        .target(
            name: "CKKeychain"
        )
    ]
)
