//
//  CertificateSelectionView.swift
//  AirPushMac
//
//  Created by Anton Glezman on 25.10.2020.
//  Copyright © 2020 Alexandr Ignatyev. All rights reserved.
//

import Chain
import SwiftUI

struct CertificateSelectionView: View {
    
    @Binding var certificate: Certificate?
    let chooseCertificate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Certificate:", action: chooseCertificate)
                Text(certificate?.name ?? "none")
            }
        }
        .padding()
    }
}

struct CertificateSelectionView_Previews: PreviewProvider {
    private static let cert = Binding<Certificate?>.constant(nil)
    
    static var previews: some View {
        CertificateSelectionView(
            certificate: cert,
            chooseCertificate: { print("certs") })
    }
}
