//
//  LoadingView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/22/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.accentColor // Sets the accent color as the background for the entire view
                .edgesIgnoringSafeArea(.all) // Extends the background color to the edges of the display

            VStack {
                Spacer()

                Text("StepQuest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Ensures text color is set against the accent background
                    .padding(.bottom, 5)
                
                Image("landing-icon") // Make sure to replace "logo" with the actual asset name if different
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 250)
                    .padding(.vertical)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
                
                Text("Healthy living made intresting")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                

                Spacer()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

