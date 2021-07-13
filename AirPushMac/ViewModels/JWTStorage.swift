//
//  JWTStorage.swift
//  AirPushMac
//
//  Created by Anton Glezman on 01.11.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import Foundation
import JWT

final class JWTStorage: ObservableObject {
    
    @Published var keyFile: URL? {
        didSet {
            isChanged = keyFile != oldValue
        }
    }
    
    @Published var keyId: String? {
        didSet {
            isChanged = keyId != oldValue
        }
    }
    
    @Published var teamId: String? {
        didSet {
            isChanged = teamId != oldValue
        }
    }
    
    private var isChanged: Bool = true
    private var lastUpdateDate = Date()
    private var lastToken: String!
    
    
    func getJWT() throws -> String {
        if isChanged || Date().timeIntervalSince(lastUpdateDate) > 3600 {
            try updateJWT()
        }
        return lastToken
    }
    
    private func updateJWT() throws {
        guard let keyFile = keyFile, let keyId = keyId, let teamId = teamId else {
            throw JWTStorageError.requiredFieldsEmpty
        }
        let key = try String(contentsOf: keyFile)
        lastUpdateDate = Date()
        let jwtGenerator = JWT(keyId: keyId, issuer: teamId, issuedAt: lastUpdateDate, privateKey: key)
        lastToken = try jwtGenerator.generate()
        isChanged = false
    }
}

enum JWTStorageError: LocalizedError {
    case requiredFieldsEmpty
    
    var errorDescription: String? {
        switch self {
        case .requiredFieldsEmpty:
            return "Required fields for key authentication are not filled"
        }
    }
}
