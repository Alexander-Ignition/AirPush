import Foundation

public struct KeychainError: Error {
    public let status: OSStatus
    public let message: String?

    public init(status: OSStatus, message: String?) {
        self.status = status
        self.message = message
    }

    public init(status: OSStatus) {
        self.status = status
        self.message = SecCopyErrorMessageString(status, nil) as String?
    }
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? { message }
}

extension KeychainError: CustomNSError {
    public static let errorDomain = "com.air-push.KeychainError"

    public var errorCode: Int { Int(status) }

    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        return userInfo
    }
}
