// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimplifiedAuthKit",
    platforms: [
            .iOS(.v15)   //  minimum to iOS 15
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SimplifiedAuthKit",
            targets: ["SimplifiedAuthKit"]),
    ],
    dependencies: [
           // Firebase SDK (includes FirebaseAuth)
           .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.2.0"),
           
           // Google Sign-In SDK
           .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "9.0.0")
       ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SimplifiedAuthKit",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            cSettings: [
                // Suppress harmless GoogleSignIn warning:
                // "Umbrella header for module 'GoogleSignIn' does not include header 'GIDAppCheckError.h'"
                .unsafeFlags(["-Wno-incomplete-umbrella"])
            ]
        ),
        
                .testTarget(
                    name: "SimplifiedAuthKitTests",
                    dependencies: ["SimplifiedAuthKit"]
                ),
            ]
        )
