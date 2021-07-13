//
//  NSAlert+PushError.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 18.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import APNs
import Cocoa

extension NSAlert {

    convenience init(pushError: Error) {
        switch pushError {
        case PushError.status(let status, let userInfo):
            self.init(error: pushError)
            self.messageText = "\(status.status): \(status.localizedString)"
            self.informativeText = userInfo?.reason ?? ""
            self.showsHelp = true
        default:
            self.init(error: pushError)
        }
    }
}
