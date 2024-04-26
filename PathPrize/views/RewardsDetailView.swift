//
//  RewardsDetailView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/26/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct RewardDetailView: View {
    let rewardId: Int?
    @State private var reward: RewardModel?
    @State private var isLoading = true
    @State private var qrCodeImage: Image?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...")
            } else if let reward = reward {
                VStack {
                    Text(reward.name)
                        .font(.title).padding()
                    
                    qrCodeImage?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    Text("Expires: \(reward.expiresAt, formatter: itemFormatter)")
                        .font(.title).padding()
                    
                    Text("Get to Shop to Redeem or Online")
                        .font(.title).padding()
                    
                }
            }
        }
        .navigationTitle("Reward Details").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadRewardDetails()
        }
    }

    private func loadRewardDetails() {
        guard let rewardId = rewardId else { return }
        
        Task {
            do {
                reward = try await RewardService.getRewardById(id: rewardId)
                generateQRCode(from: "\(reward?.qrCode ?? UUID())")
                isLoading = false
            } catch {
                print("Error fetching reward: \(error)")
            }
        }
    }

    private func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let uiImage = UIImage(cgImage: cgimg)
                qrCodeImage = Image(uiImage: uiImage)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
