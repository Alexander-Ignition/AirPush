import Foundation
import CryptorECC

public struct JWTHeader: Encodable {
    public let alg = "ES256"
    public let kid: String
    
    public init(keyId: String) {
        kid = keyId
    }
}

public struct JWTPayload: Encodable {
    public let iss: String
    public let iat: Int
    
    public init(issuer: String, issuedAt: Date) {
        iss = issuer
        iat = Int(issuedAt.timeIntervalSince1970)
    }
}

public struct JWT {
    
    private let header: JWTHeader
    private var payload: JWTPayload
    private let encoder = JSONEncoder()
    private let key: String
    
    /// Initalize a JWT struct for authorization APNs requests
    ///
    /// - Parameters:
    ///   - keyId: Key identifier
    ///   - issuer: Issuer - Apple Developer Team Id
    ///   - issuedAt: The date of creation jwt
    ///   - privateKey: The private key for signing jwt. The key must be in PEM format (.pem or .p8 file)
    public init(keyId: String, issuer: String, issuedAt: Date, privateKey: String) {
        header = JWTHeader(keyId: keyId)
        payload = JWTPayload(issuer: issuer, issuedAt: issuedAt)
        self.key = privateKey
    }
    
    /// Update issuedAt token filed
    public mutating func updateIssuedAt(date: Date = Date()) {
        payload = JWTPayload(issuer: payload.iss, issuedAt: date)
    }
    
    /// Generate and sign a JSON Web Token
    ///
    /// - Returns: JWT string
    public func generate() throws -> String {
        let headerPart = (try encoder.encode(header)).base64URLEncodedString()
        let payloadPart = (try encoder.encode(payload)).base64URLEncodedString()
        let body = "\(headerPart).\(payloadPart)"
        
        let privKey = try ECPrivateKey(key: key)
        let signature = try body.sign(with: privKey).asn1
        
        return "\(body).\(signature.base64URLEncodedString())"
    }
    
    /// Verify JWT signature
    ///
    /// - Parameters:
    ///   - jwt: JWT string
    ///   - publicKey: Public key for signature verification. The key must be in PEM format
    /// - Returns: A boolean value indicating whether the token contains a valid signature or not
    static func verify(jwt: String, publicKey: String) throws -> Bool {
        let parts = jwt.split(separator: ".")
        let pubKey = try ECPublicKey(key: publicKey)
        let body = "\(parts[0]).\(parts[1])"
        
        guard let signature = Data.decodeBase64url(String(parts[2])) else {
            return false
        }
        let ecSignature = try ECSignature(asn1: signature)
        
        return ecSignature.verify(plaintext: body, using: pubKey)
    }
}

extension Data {
    
    /// Returns a base64url encoded string.
    public func base64URLEncodedString() -> String {
        let s = self.base64EncodedString()
        return s
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    /// Returns Data decoded from base64url string.
    public static func decodeBase64url(_ str: String) -> Data? {
        var base64string = str
        base64string = base64string.replacingOccurrences(of: "-", with: "+")
        base64string = base64string.replacingOccurrences(of: "_", with: "/")
        let missingPadding = base64string.count % 4
        if missingPadding > 0 {
            base64string += String(repeating: "=", count: 4 - missingPadding)
        }
        let data = Data(base64Encoded: base64string)
        return data
    }
}
