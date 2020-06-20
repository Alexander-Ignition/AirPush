import Foundation

public enum PushError: Error {
    /// Failed status with user info.
    case status(PushStatus, UserInfo?)

    /// Network error.
    case network(URLError)
}

extension PushError {
    public struct UserInfo: Error, Codable {
        /// Error reason.
        public let reason: String
        /// Error timestamp.
        public let timestamp: Int?
    }
}

// MARK: - CustomStringConvertible

extension PushError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .status(let status, let userInfo):
            return "\(status), \(String(describing: userInfo))"
        }
    }
}
