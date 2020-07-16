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

    let chooseCertificate: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Device token:")
                TextField(
                    "The hexadecimal bytes of the device token for the target device",
                    text: $viewModel.push.deviceToken)
            }
            HStack {
                Button("Certificate:", action: chooseCertificate)
                Text(viewModel.certificate?.name ?? "none")
            }
            HStack {
                ProgressIndicator(isAnimating: viewModel.isLoading)
                Button("Send", action: send)
                    .disabled(viewModel.isLoading)
            }
            JsonEditor(text: $viewModel.push.body)
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
            chooseCertificate: { print("certs") })
    }
}
