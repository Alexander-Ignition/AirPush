import Foundation

public enum Keychain {
    public enum Subject {
        case contains(String)
        case start(String)
        case end(String)
        case whole(String)
    }

    public static func macth(_ subject: Subject) throws -> Certificate {
        var query: [CFString: Any] = [
            kSecMatchLimit: kSecMatchLimitOne,
            kSecClass: kSecClassIdentity,
        ]

        switch subject {
        case .contains(let string):
            query[kSecMatchSubjectContains] = string
        case .start(let string):
            query[kSecMatchSubjectStartsWith] = string
        case .end(let string):
            query[kSecMatchSubjectEndsWith] = string
        case .whole(let string):
            query[kSecMatchSubjectWholeString] = string
        }

        let indentity: SecIdentity = try withPointer {
            SecItemCopyMatching(query as CFDictionary, &$0)
        }
        let certificate: SecCertificate = try withPointer {
            SecIdentityCopyCertificate(indentity, &$0)
        }
        let name: String = try withPointer {
            SecCertificateCopyCommonName(certificate, &$0)
        }

        return Certificate(
            name: name,
            identity: indentity,
            certificate: certificate)
    }
}

func withPointer<T, U>(_ block: (inout T?) -> OSStatus) throws -> U {
    var value: T?
    let status = block(&value)
    guard status == errSecSuccess else {
        throw KeychainError.status(status)
    }
    guard let result = value as? U else {
        let message = "Unexpected result type: \(String(describing: value)) instead of \(U.self)"
        throw KeychainError.message(message)
    }
    return result
}
