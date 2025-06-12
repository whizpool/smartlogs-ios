// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SmartLogs",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "SmartLogs",
            targets: ["SmartLogs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ZipArchive/ZipArchive", from: "2.4.2")
    ],
    targets: [
        .target(
            name: "SmartLogs",
            dependencies: [
                .product(name: "SSZipArchive", package: "ZipArchive")
            ],
            path: "Classes",
            exclude: [],
            resources: [
                .process(".")
            ],
            swiftSettings: [
                .define("SPM")
            ]
        )
    ]
)

