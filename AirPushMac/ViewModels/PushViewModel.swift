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

final class PushViewModel: ObservableObject {

    let undoManager = UndoManager()
    let client = PushClient(
        configuration: .ephemeral,
        operationQueue: .main)

    @Published var result: PushResult?
    @Published var isLoading: Bool = false
    @Published var certificate: Certificate? {
        didSet { undo(\.certificate, oldValue) }
    }
    @Published var push = PushNotification(deviceToken: "", body: "") {
        didSet { undo(\.push, oldValue) }
    }

    // MARK: - Actions

    func send() {
        isLoading = true
        client.send(push, certificate: nil) { [weak self] result in
            self?.isLoading = false
            self?.result = result
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
