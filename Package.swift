// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftdecl",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
                    name: "swiftdecl",
                    dependencies: [
                        .product(name: "ArgumentParser", package: "swift-argument-parser"),
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftParser", package: "swift-syntax")
                    ]
                ),
        .testTarget(name: "FunctionVisitorTests",
                    dependencies: [
                        .product(name: "ArgumentParser", package: "swift-argument-parser"),
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftParser", package: "swift-syntax"),
                        .byName(name: "swiftdecl")
                    ]
               ),
        .testTarget(name: "FunctionSummarizerTests",
                    dependencies: [
                        .product(name: "ArgumentParser", package: "swift-argument-parser"),
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftParser", package: "swift-syntax"),
                        .byName(name: "swiftdecl")
                    ]
               )
        //.target(name: "swiftdecl", dependencies: ["ArgumentParser", "SwiftSyntax"]),
    ]
)
