//
//  ReedeemRewardView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/27/24.
//

import Foundation
import SwiftUI

struct ResultView: View {
    var scannedText: String
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
           VStack(spacing: 20) {
               Spacer()

               VStack(spacing: 10) {
                   Image(systemName: "gift.fill")
                       .font(.system(size: 56))
                       .foregroundColor(Color.accentColor)
                   
                   Text("Redeem Reward")
                       .font(.title2)
                       .bold()

                   Text(scannedText)
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(Color.blue.opacity(0.1))
                       .cornerRadius(10)
                       .multilineTextAlignment(.center)
                       .font(.body)
                       .foregroundColor(Color.black.opacity(0.7))
               }

               Spacer()

               Button("Redeem") {
                   Task {
                       await redeemReward()
                   }
               }
               .font(.headline)
               .foregroundColor(.white)
               .padding()
               .frame(width: 280, height: 50)
               .background(Color.green)  // Adjusted to signify a positive action
               .cornerRadius(25)
               .shadow(radius: 10)
               
               Spacer()
           }
           .padding()
           .alert(isPresented: $showAlert) {
               Alert(title: Text("Redemption Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
           }
           .navigationTitle("Redeem Reward")
           .navigationBarTitleDisplayMode(.inline)
       }


    func redeemReward() async {
        do {
            guard let qrCodeUUID = UUID(uuidString: scannedText) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid QR code format"])
            }
            try await RewardService.updateReward(qrCode: qrCodeUUID.uuidString)
            alertMessage = "Reward redeemed successfully!"
        } catch {
            alertMessage = "Failed to redeem reward: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
