// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "MusicCloneCore", platforms: [.macOS("15.2")], targets: [
    .target(name: "MusicCloneCore", path: "MusicCloneApp", exclude: ["Assets.xcassets", "Preview Content", "Views", "Info.plist", "MusicCloneApp.entitlements"], sources: ["Models", "Network", "ViewModels"]),
    .testTarget(name: "MusicCloneCoreTests", dependencies: ["MusicCloneCore"], path: "CoreTests")
])
