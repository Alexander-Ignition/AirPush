//
//  PushView.swift
//  AirPushMac
//
//  Created by Alexander Ignatev on 19.06.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import APNs
import SwiftUI

struct PushView: View {
    @ObservedObject var viewModel: PushViewModel

    let certificates: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Device token:")
                TextField(
                    "The hexadecimal bytes of the device token for the target device",
                    text: $viewModel.push.deviceToken)
            }
            PushConnectionPicker(selection: $viewModel.push.connection)
            HStack {
                Button("Certificate:", action: certificates)
                Text(viewModel.certificate?.name ?? "none")
            }
            HStack {
                ProgressIndicator(isAnimating: viewModel.isLoading)
                Button("Send", action: send)
                    .disabled(viewModel.isLoading)
            }
            Spacer()
        }
        .padding()
    }

    func send() {
        Sounds.hero?.play()
        viewModel.send()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PushView(
            viewModel: PushViewModel(),
            certificates: { print("certs") })
    }
}
