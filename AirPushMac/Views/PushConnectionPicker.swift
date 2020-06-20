//
//  PushConnectionPicker.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 18.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import APNs
import SwiftUI

extension PushConnection: Identifiable {
    public var id: String { rawValue }
}

struct PushConnectionPicker: View {
    @Binding var selection: PushConnection

    var body: some View {
        Picker(selection: $selection, label: Text("Connection:   ")) {
            ForEach(PushConnection.allCases) { connection in
                Text(connection.host).tag(connection)
            }
        }.pickerStyle(RadioGroupPickerStyle())
    }
}

struct PushConnectionPicker_Previews: PreviewProvider {
    static var previews: some View {
        PushConnectionPicker(
            selection: .constant(.development)
        ).padding()
    }
}
