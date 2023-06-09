// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// TODO: - Enable when swift-tools 5.8.0 become available an github actions

let swiftSettings: [SwiftSetting] = [
//    .enableUpcomingFeature("BareSlashRegexLiterals"),
//    .enableUpcomingFeature("ConciseMagicFile"),
//    .enableUpcomingFeature("ExistentialAny"),
//    .enableUpcomingFeature("ForwardTrailingClosures"),
//    .enableUpcomingFeature("ImplicitOpenExistentials"),
//    .enableUpcomingFeature("StrictConcurrency"),
//    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"]),
]

let package = Package(
    name: "swiftui-pager",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible
        // to other packages.
        .library(
            name: "SwiftUIPager",
            targets: ["SwiftUIPager"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            .upToNextMajor(from: "0.9.1")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a
        // test suite.
        // Targets can depend on other targets in this package, and on products in packages this
        // package depends on.
        .target(
            name: "SwiftUIPager",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SwiftUIPagerTests",
            dependencies: [
                .target(name: "SwiftUIPager"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
    ]
)
