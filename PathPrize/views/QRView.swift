//
//  QRView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/27/24.
//

import Foundation
import SwiftUI
import VisionKit

struct QRView: View {
    @State private var isShowingScanner = true
    @State private var scannedText = ""
    @State private var showResult = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    DataScannerRepresentable(
                        shouldStartScanning: $isShowingScanner,
                        scannedText: $scannedText,
                        dataToScanFor: [.barcode(symbologies: [.qr])]
                    )
                    .onChange(of: scannedText) { newValue in
                        print(newValue)
                        if !newValue.isEmpty {
                            showResult = true  // Activate navigation link when text is scanned
                        }
                    }
                    .frame(maxHeight: .infinity).cornerRadius(30)

                    Button(action: {
                        isShowingScanner.toggle()
                    }) {
                        Text("Tap to Scan Again")
                            .padding()
                            .background(.accent)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .cornerRadius(10)
                    }
                    
                NavigationLink(
                    destination: ResultView(scannedText: scannedText),
                    isActive: $showResult,
                    label: {
                        EmptyView()
                    }
                )
                
                } else if !DataScannerViewController.isSupported {
                    Text("Sorry, QR code scanning is not supported on this device.")
                        .foregroundColor(.gray)
                } else {
                    Text("Please grant camera access to scan QR codes.")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .navigationTitle("QR Code Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
