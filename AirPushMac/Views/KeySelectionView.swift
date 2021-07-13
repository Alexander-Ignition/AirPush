//
//  KeySelectionView.swift
//  AirPushMac
//
//  Created by Anton Glezman on 25.10.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import SwiftUI

struct KeySelectionView: View {
    
    @Binding var keyFile: URL?
    @Binding var keyId: String?
    @Binding var teamId: String?
    @Binding var topic: String?
    let chooseKeyFile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Key file:", action: chooseKeyFile)
                Text(keyFile?.lastPathComponent ?? "none")
            }
            HStack {
                Text("Key ID:")
                TextField("", text: $keyId.bound)
            }
            HStack {
                Text("Team ID:")
                TextField("", text: $teamId.bound)
            }
            HStack {
                Text("Topic (Bundle Id):")
                TextField("", text: $topic.bound)
            }
        }
        .padding()
    }
}

struct KeySelectionView_Previews: PreviewProvider {
    private static let file = Binding<URL?>.constant(nil)
    private static let text = Binding<String?>.constant(nil)
    
    static var previews: some View {
        KeySelectionView(
            keyFile: file,
            keyId: text,
            teamId: text,
            topic: text,
            chooseKeyFile: { print("certs") })
    }
}


extension Optional where Wrapped == String {
    var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}
