// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "createmlfairy",
    platforms: [
        // specify each minimum deployment requirement, 
        //otherwise the platform default minimum is used.
       .macOS(.v10_15),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "createmlfairy",
            dependencies: ["SwiftCLI"]),
        .testTarget(
            name: "createmlfairyTests",
            dependencies: ["createmlfairy"]),
    ]
)
