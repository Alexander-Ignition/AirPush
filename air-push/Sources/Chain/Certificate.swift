import Foundation

public struct Certificate {
    public let name: String
    public let identity: SecIdentity
    public let certificate: SecCertificate

    public var credential: URLCredential {
        URLCredential(
            identity: identity,
            certificates: [certificate],
            persistence: .none)
    }
}

