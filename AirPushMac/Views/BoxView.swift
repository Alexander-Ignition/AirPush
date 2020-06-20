//
//  BoxView.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 19.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import SwiftUI

struct BoxView: NSViewRepresentable {
    let title: String
    let titlePosition: NSBox.TitlePosition
    let contentView: NSView

    // MARK: - Init

    @inlinable init<Content>(
        title: String,
        titlePosition: NSBox.TitlePosition = .atTop,
        @ViewBuilder content: () -> Content
    ) where Content: View  {
        self.title = title
        self.titlePosition = titlePosition
        self.contentView = NSHostingView(rootView: content())
    }

    @inlinable init<Content>(
        @ViewBuilder content: () -> Content
    ) where Content: View  {
        self.title = ""
        self.titlePosition = .noTitle
        self.contentView = NSHostingView(rootView: content())
    }

    // MARK: - NSViewRepresentable

    func makeNSView(context: Context) -> NSBox {
        let box = NSBox()
        return box
    }

    func updateNSView(_ nsView: NSBox, context: Context) {
        nsView.title = title
        nsView.titlePosition = titlePosition
        nsView.contentView = contentView
    }
}

struct BoxView_Previews: PreviewProvider {
    static var previews: some View {
        BoxView(title: "Box title") {
            Text("Content").lineLimit(1)
        }
        .padding()
    }
}
