//
//  RegistrationChoiceView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation

import SwiftUI

struct RegistrationChoiceView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
            VStack(spacing: 20) {
                Text("Registration")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            

                
                Text("Create your account and start your journey with us. Choose the type of account that best fits your needs.")
                    .multilineTextAlignment(.center)
                    .padding()

                NavigationLink(destination: SignUpUserView()) {
                    Text("Register as User")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentColor)
                        .cornerRadius(25)
                }
                .padding(.horizontal)

                Text("or")
                    .font(.headline)
                    .foregroundColor(.gray)

                NavigationLink(destination: SignUpBusinessView()) {
                    Text("Register as Business")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentColor)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
            }
            .padding()
        }
}

struct RegistrationChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationChoiceView()
    }
}
