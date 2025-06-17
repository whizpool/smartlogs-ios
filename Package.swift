// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SmartLogs",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SmartLogs",
            targets: ["SmartLogs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ZipArchive/ZipArchive", exact: "2.4.2")
    ],
    targets: [
            .target(
                name: "SmartLogs",
                dependencies: [
                    .product(name: "ZipArchive", package: "ZipArchive")
                ],
                path: "Classes",
                swiftSettings: [
                    .define("SPM")
                ]
            )
        ]
)

