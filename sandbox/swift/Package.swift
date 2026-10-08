// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "LedgerKit",
    products: [
        .library(name: "LedgerKit", targets: ["LedgerKit"])
    ],
    targets: [
        .target(name: "LedgerKit"),
        .testTarget(
            name: "LedgerKitTests",
            dependencies: ["LedgerKit"],
            // The fixture is read from disk with a path relative to #filePath,
            // not through Bundle.module, so it is excluded from resource
            // processing rather than copied into a bundle.
            exclude: ["Fixtures"]
        ),
    ]
)
