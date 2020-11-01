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
    @ObservedObject var jwtStorage: JWTStorage

    let chooseCertificate: () -> Void
    let chooseKeyFile: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Device token:")
                TextField(
                    "The hexadecimal bytes of the device token for the target device",
                    text: $viewModel.push.deviceToken)
            }
            TabView(selection: $viewModel.authenticationMethod) {
                CertificateSelectionView(
                    certificate: $viewModel.certificate,
                    chooseCertificate: chooseCertificate)
                    .tabItem {
                        Text("Certificate")
                    }
                    .tag(AuthenticationMethod.certificate)
                
                KeySelectionView(
                    keyFile: $jwtStorage.keyFile,
                    keyId: $jwtStorage.keyId,
                    teamId: $jwtStorage.teamId,
                    topic: $viewModel.push.headers.topic,
                    chooseKeyFile: chooseKeyFile)
                    .tabItem {
                        Text("Key")
                    }
                    .tag(AuthenticationMethod.jwt)
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
    private static let jwtStorage = JWTStorage()
    
    static var previews: some View {
        PushView(
            viewModel: PushViewModel(jwtStorage: jwtStorage),
            jwtStorage: jwtStorage,
            chooseCertificate: { print("certs") },
            chooseKeyFile: { print("keys") })
    }
}
