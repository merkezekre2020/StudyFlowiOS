// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StudyFlowiOS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "StudyFlowiOS", targets: ["StudyFlowiOS"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "StudyFlowiOS",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
