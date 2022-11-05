// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaywallCraft",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v13),
    ],
    products: [
        .library(
            name: "PaywallCraftCore",
            targets: ["PaywallCraftCore"]
        ),
        .library(
            name: "PaywallCraftResources",
            targets: ["PaywallCraftResources"]
        ),
        .library(
            name: "PaywallCraftUI",
            targets: ["PaywallCraftUI"]
        ),
    ],
    dependencies: [
      .package(url: "https://github.com/dDomovoj/Cascade.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/NotificationCraft.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/AnalyticsCraft.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/Stored.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/Utils.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/UIBase.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/UICommon.git", branch: "master"),
      .package(url: "https://github.com/dDomovoj/CallbacksCraft.git", branch: "master"),

      .package(url: "https://github.com/eddiekaiger/SwiftyAttributes", branch: "master"),
      .package(url: "https://github.com/sparrowcode/PermissionsKit", .upToNextMajor(from: "9.0.1")),
      .package(url: "https://github.com/layoutBox/PinLayout", .upToNextMajor(from: "1.10.3")),
      .package(url: "https://github.com/dDomovoj/StackCraft.git", .upToNextMajor(from: "0.3.3")),
      .package(url: "https://github.com/RevenueCat/purchases-ios.git", .upToNextMajor(from: "4.5.2")),
      .package(url: "https://github.com/ashleymills/Reachability.swift", branch: "master"),
      .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "9.1.0")),
      .package(url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", .upToNextMajor(from: "1.42.0"))
    ],
    targets: [

        .target(
            name: "PaywallCraftCore",
            dependencies: [
              "PaywallCraftUI",
              "PaywallCraftResources",

              .product(name: "Cascade", package: "Cascade"),
              .product(name: "NotificationCraft", package: "NotificationCraft"),
              .product(name: "NotificationCraftSystem", package: "NotificationCraft"),
              .product(name: "AnalyticsCraft", package: "AnalyticsCraft"),
              .product(name: "Stored", package: "Stored"),
              .product(name: "Utils", package: "Utils"),

              .product(name: "NotificationPermission", package: "PermissionsKit"),
              .product(name: "LocationWhenInUsePermission", package: "PermissionsKit"),
              .product(name: "LocationAlwaysPermission", package: "PermissionsKit"),
              .product(name: "MotionPermission", package: "PermissionsKit"),
              .product(name: "PhotoLibraryPermission", package: "PermissionsKit"),
              
              .product(name: "SwiftyAttributes", package: "SwiftyAttributes"),
              .product(name: "StackCraft", package: "StackCraft"),
              .product(name: "RevenueCat", package: "purchases-ios"),
              .product(name: "Reachability", package: "Reachability.swift"),
              .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
              .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
              .product(name: "Branch", package: "ios-branch-deep-linking-attribution"),
            ],
            linkerSettings: [
              .linkedFramework("UIKit"),
              .linkedFramework("NotificationCenter"),
              .linkedFramework("StoreKit"),
              .linkedFramework("AdSupport"),
              .linkedFramework("AppTrackingTransparency"),
              .linkedFramework("SafariServices"),
            ]
        ),


        .target(
            name: "PaywallCraftResources",
            dependencies: [

            ],
            linkerSettings: [
              .linkedFramework("UIKit"),
            ]
        ),


        .target(
            name: "PaywallCraftUI",
            dependencies: [
              "PaywallCraftResources",

              .product(name: "UIBase", package: "UIBase"),
              .product(name: "UICommon", package: "UICommon"),
              .product(name: "CallbacksCraft", package: "CallbacksCraft"),

              .product(name: "PinLayout", package: "PinLayout"),
            ],
            linkerSettings: [
              .linkedFramework("UIKit"),
            ]
        ),

    ],
    swiftLanguageVersions: [.v5]
)
