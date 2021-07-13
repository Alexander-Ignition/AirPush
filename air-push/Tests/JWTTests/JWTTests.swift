@testable import JWT
import XCTest
import Foundation

final class JWTTests: XCTestCase {
    
    let privateKeyPem = """
        -----BEGIN EC PRIVATE KEY-----
        MHcCAQEEIPUN/VTab4e8raSJ/VK4UzsCNvQWHPBMG6EZu63UnfGhoAoGCCqGSM49
        AwEHoUQDQgAEVHFZcTmp+GQyB2HcjQAnHiaP4iUO3J3SsmgJA9LthcLvhmC/kjrr
        bTFTVe1Ou4ID79DA5B5XdGEC19N/31xfsw==
        -----END EC PRIVATE KEY-----
        """
    let publicKeyPem = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEVHFZcTmp+GQyB2HcjQAnHiaP4iUO
        3J3SsmgJA9LthcLvhmC/kjrrbTFTVe1Ou4ID79DA5B5XdGEC19N/31xfsw==
        -----END PUBLIC KEY-----

        """
    
    func testGenerateJWT() throws {
        let jwtGenerator = JWT(
            keyId: "ABC123DEFG",
            issuer: "DEF123GHIJ",
            issuedAt: Date(),
            privateKey: privateKeyPem
        )
        let jwt = try jwtGenerator.generate()
        
        let isValid = try JWT.verify(jwt: jwt, publicKey: publicKeyPem)
        XCTAssertTrue(isValid)
    }
    
    func testVirifyJWT() throws {
        let jwt = """
            eyJhbGciOiJFUzI1NiIsImtpZCI6IkFCQzEyM0RFRkcifQ.\
            eyJpc3MiOiJERUYxMjNHSElKIiwiaWF0IjoxNjA1OTg3Mjc5fQ.\
            DfFurtqqIZDKJrTvBj7NAfZX64oefoUwqrK9tFiAraHIcpUobFaT3VGN-OkNnkB0TQeh5rL-noNuM6yTsVBtIQ
            """
        
        let isValid = try JWT.verify(jwt: jwt, publicKey: publicKeyPem)
        XCTAssertTrue(isValid)
    }
}
