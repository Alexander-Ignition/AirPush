import Foundation

/// APNs Connections.
public enum PushConnection: String, Hashable, Codable, CaseIterable {
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

// MARK: - CustomStringConvertible

extension PushConnection: CustomStringConvertible {
    public var description: String { rawValue }
}

// MARK: - CustomDebugStringConvertible

extension PushConnection: CustomDebugStringConvertible {
    public var debugDescription: String { "\(rawValue): \(host)" }
}
