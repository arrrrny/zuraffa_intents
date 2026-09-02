// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// This Package.swift provides Swift Package Manager support for zuraffa_intents (iOS).
// See: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors

import PackageDescription

let package = Package(
    name: "zuraffa_intents",
    platforms: [
        .iOS("15.6")
    ],
    products: [
        .library(
            name: "zuraffa-intents",
            targets: ["zuraffa_intents"]),
        .library(
            name: "zuraffa-intents-models",
            type: .static,
            targets: ["zuraffa_intents_models"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "zuraffa_intents_models",
            dependencies: [],
            path: "Sources/zuraffa_intents_models"
        ),
        .target(
            name: "zuraffa_intents",
            dependencies: [
                "zuraffa_intents_models"
            ],
            path: "Sources/zuraffa_intents"
        ),
    ]
)
