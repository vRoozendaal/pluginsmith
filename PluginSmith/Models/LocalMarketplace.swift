import Foundation

struct LocalMarketplace: Codable {
    var name: String
    var version: String
    var description: String
    var owner: Owner
    var plugins: [PluginEntry]

    struct Owner: Codable {
        var name: String
    }

    struct PluginEntry: Codable {
        var name: String
        var description: String
        var version: String
        var author: Author
        var source: String
        var category: String
    }

    struct Author: Codable {
        var name: String
        var email: String?
    }

    static func empty() -> LocalMarketplace {
        LocalMarketplace(
            name: "local-desktop-app-uploads",
            version: "1.0.0",
            description: "Locally created plugins via PluginSmith",
            owner: Owner(name: "Local User"),
            plugins: []
        )
    }
}

struct PluginJSON: Codable {
    var name: String
    var description: String
    var version: String
    var author: Author?
    var keywords: [String]?

    struct Author: Codable {
        var name: String
        var email: String?
        var url: String?
    }
}
