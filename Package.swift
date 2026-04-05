// swift-tools-version: 6.0
// テスト実行用パッケージ (xcodegen プロジェクトと併用)

import PackageDescription

let package = Package(
    name: "ekocci",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .target(
            name: "EkocciShared",
            path: "Shared"
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: ["EkocciShared"],
            path: "Tests/SharedTests"
        )
    ]
)
