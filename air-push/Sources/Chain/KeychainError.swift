import Foundation

public enum KeychainError: Error {
    case status(OSStatus)
    case message(String)
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .status(let code):
            return SecCopyErrorMessageString(code, nil) as String?
        case .message(let string):
            return string
        }
    }
}

extension KeychainError: CustomNSError {
    public static let errorDomain = "com.air-push.KeychainError"

    public var errorCode: Int {
        switch self {
        case .status(let code):
            return Int(code)
        case .message:
            return -1
        }
    }

    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        return userInfo
    }
}
