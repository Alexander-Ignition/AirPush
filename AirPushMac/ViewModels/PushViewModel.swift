//
//  PushViewModel.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 16.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import APNs
import Chain
import Foundation

struct Payload: RawRepresentable  {
    let rawValue: String
}

extension Payload {
    static let preview = Payload(rawValue: """
    {
       "aps" : {
          "alert" : {
             "title" : "Game Request",
             "subtitle" : "Five Card Draw",
             "body" : "Bob wants to play poker",
          },
          "category" : "GAME_INVITATION"
       },
       "gameID" : "12345678"
    }
    """)
}

enum AuthenticationMethod: Int {
    case certificate = 0
    case jwt = 1
}

final class PushViewModel: ObservableObject {

    private var jwtStorage: JWTStorage
    let undoManager = UndoManager()
    let client = PushClient(
        configuration: .ephemeral,
        operationQueue: .main)

    @Published var result: Result<PushStatus, Error>?
    @Published var isLoading: Bool = false
    @Published var certificate: Certificate? {
        didSet { undo(\.certificate, oldValue) }
    }
    @Published var push = PushNotification(deviceToken: "", body: Payload.preview.rawValue) {
        didSet { undo(\.push, oldValue) }
    }
    @Published var authenticationMethod: AuthenticationMethod = .certificate
    
    
    init(jwtStorage: JWTStorage) {
        self.jwtStorage = jwtStorage
    }
    
    // MARK: - Actions

    func send() {
        if authenticationMethod == .jwt {
            do {
                push.headers.authorization = try jwtStorage.getJWT()
            } catch {
                result = .failure(error)
                return
            }
        } else {
            push.headers.authorization = nil
        }
        isLoading = true
        client.send(push, certificate: nil) { [weak self] result in
            self?.isLoading = false
            self?.result = result.mapError { $0 }
        }
    }

    // MARK: - Private

    private func undo<T>(_ keyPath: ReferenceWritableKeyPath<PushViewModel, T>, _ oldValue: T) {
        undoManager.registerUndo(withTarget: self, handler: { $0[keyPath: keyPath] = oldValue })
    }
}

// MARK: - RestorableState

extension PushViewModel {

    func encode(with coder: NSCoder) {
        do {
            let data = try JSONEncoder().encode(push)
            coder.encode(data)
        } catch {
            coder.failWithError(error)
        }
    }

    func decode(with coder: NSCoder) {
        do {
            guard let data = coder.decodeData() else { return }
            push = try JSONDecoder().decode(PushNotification.self, from: data)
        } catch {
            coder.failWithError(error)
        }
    }
}
