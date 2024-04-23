//
//  LandingView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("StepQuest")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 5)
            
            Image("landing-icon") // Ensure your image asset is correctly named
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.vertical, 24)
            
            Text("Embark on a Journey to Health")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Join StepQuest and turn your daily walks into adventures. Sign up and start your quest towards a healthier lifestyle today!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            NavigationLink(destination: RegistrationChoiceView()) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(.accent)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Text("Already have an account?")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding()
            
            NavigationLink(destination: LoginView()) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(.accent)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
