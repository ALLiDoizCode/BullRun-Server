import PackageDescription

let package = Package(
    name: "BullRun-Server",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 4),
        .Package(url: "https://github.com/BrettRToomey/Jobs.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

