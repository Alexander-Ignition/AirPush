//
//  MainWindowController.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 19.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import APNs
import Cocoa
import Combine
import SwiftUI

final class MainWindowController: NSWindowController {

    @IBOutlet private var sendButton: NSButton!
    @IBOutlet private var connectionButton: NSPopUpButton!

    private lazy var viewModel = PushViewModel()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - NSWindowController

    override func windowDidLoad() {
        super.windowDidLoad()

        let minSize = window!.minSize
        let pushView = PushView(
            viewModel: viewModel,
            certificates: { [weak self] in self?.certificates(nil) }
        ).frame(minWidth: minSize.width, minHeight: minSize.height)
        contentViewController = NSHostingController(rootView: pushView)

        viewModel.$isLoading
            .map { !$0 }
            .assign(to: \.isEnabled, on: sendButton)
            .store(in: &subscriptions)

        viewModel.$push
            .map { PushConnection.allCases.firstIndex(of: $0.connection)! }
            .sink { [weak self] in self?.connectionButton?.selectItem(at: $0) }
            .store(in: &subscriptions)

        viewModel.$result
            .compactMap { $0 }
            .sink { [weak self] in self?.showResult($0) }
            .store(in: &subscriptions)
    }

    // MARK: - Actons

    @IBAction func send(_ sender: Any?) {
        viewModel.send()
    }

    @IBAction func connection(_ sender: Any?) {
        let index = connectionButton.indexOfSelectedItem
        let connection = PushConnection.allCases[index]
        viewModel.push.connection = connection
    }

    @IBAction func certificates(_ sender: Any?) {
        //
    }

    // MARK: - Private

    private func showResult(_ result: PushResult) {
        print(result)
        guard let window = self.window else { return }

        switch result {
        case .failure(let error):
            Sounds.basso?.play()
            let alert = NSAlert(pushError: error)
            alert.beginSheetModal(for: window)
        default:
            break
        }
    }
}

// MARK: - NSWindowDelegate

extension MainWindowController: NSWindowDelegate {

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        viewModel.undoManager
    }

    func window(_ window: NSWindow, willEncodeRestorableState state: NSCoder) {
        viewModel.encode(with: state)
    }

    func window(_ window: NSWindow, didDecodeRestorableState state: NSCoder) {
        viewModel.decode(with: state)
    }
}

enum Sounds {
    static var basso: NSSound? { NSSound(named: "Basso") } // error
    static var hero: NSSound? { NSSound(named: "Hero") }
}
