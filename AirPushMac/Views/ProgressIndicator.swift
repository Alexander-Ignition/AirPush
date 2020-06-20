//
//  ProgressIndicator.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 18.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
    let isAnimating: Bool

    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.isDisplayedWhenStopped = false
        indicator.controlSize = .small
        indicator.style = .spinning
        return indicator
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        if isAnimating {
            nsView.startAnimation(nil)
        } else {
            nsView.stopAnimation(nil)
        }
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressIndicator(isAnimating: true)
            ProgressIndicator(isAnimating: false)
        }
    }
}
