import Foundation

public struct Certificate {
    public let name: String
    public let identity: SecIdentity
    public let certificate: SecCertificate

    public init(identity: SecIdentity) throws {
        let certificate: SecCertificate = try withPointer {
            SecIdentityCopyCertificate(identity, &$0)
        }
        let name: String = try withPointer {
            SecCertificateCopyCommonName(certificate, &$0)
        }
        self.name = name
        self.identity = identity
        self.certificate = certificate
    }

    public var credential: URLCredential {
        URLCredential(
            identity: identity,
            certificates: [certificate],
            persistence: .none)
    }
}
