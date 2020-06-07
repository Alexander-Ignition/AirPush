import Foundation

/// APNs Connections.
public enum PushConnection: String {
    /// Development server.
    case development

    /// Production server.
    case production
}

extension PushConnection {
    public var url: URL { URL(string: "https://\(host)")! }

    public var host: String {
        switch self {
        case .development:
            return "api.development.push.apple.com:443"
        case .production:
            return "api.push.apple.com:443"
        }
    }
}

// MARK: - Codable

extension PushConnection: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        switch string {
        case "development":
            self = .development
        case "production":
            self = .production
        default:
            self = .development
        }
    }
}
