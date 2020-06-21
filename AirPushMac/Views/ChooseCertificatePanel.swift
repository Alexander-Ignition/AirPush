//
//  ChooseCertificatePanel.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 20.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import Chain
import SecurityInterface

final class ChooseCertificatePanel {

    typealias Handler = (Certificate?) -> Void

    private var handler: Handler?

    private lazy var panel: SFChooseIdentityPanel = {
        let panel = SFChooseIdentityPanel.shared()!
        panel.setAlternateButtonTitle("Cancel")
        panel.setShowsHelp(true)
        return panel
    }()

    func beginSheetModal(
        for sheetWindow: NSWindow,
        completionHandler handler: @escaping Handler
    ) {
        self.handler = handler

        let identities = try! Keychain.identities()

        panel.beginSheet(
            for: sheetWindow,
            modalDelegate: self,
            didEnd: #selector(chooseIdentityPanelDidEnd(_:code:contextInfo:)),
            contextInfo: nil,
            identities: identities,
            message: """
            Choose the identity to use for delivering notifications:
            (Issued by Apple in the Provisioning Portal)
            """)
    }

    @objc private func chooseIdentityPanelDidEnd(
        _ sheet: NSWindow,
        code: Int,
        contextInfo: UnsafeMutableRawPointer
    ) {
        guard code == NSApplication.ModalResponse.OK.rawValue else {
            return
        }
        let cert = panel.identity()
            .map { try! Certificate(identity: $0.takeRetainedValue()) }
        handler?(cert)
    }
}
