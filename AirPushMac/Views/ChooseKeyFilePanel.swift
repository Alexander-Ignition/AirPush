//
//  ChooseKeyFilePanel.swift
//  AirPushMac
//
//  Created by Anton Glezman on 01.11.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import Foundation

final class ChooseKeyFilePanel {

    typealias Handler = (URL?) -> Void

    private lazy var panel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["p8", "pem"]
        panel.message = "Choose the key file to use for delivering notifications"
        return panel
    }()

    func beginSheetModal(
        for sheetWindow: NSWindow,
        completionHandler handler: @escaping Handler
    ) {
        panel.beginSheetModal(for: sheetWindow) { [weak self] response in
            guard response == .OK else { return }
            handler(self?.panel.url)
        }
    }
}
