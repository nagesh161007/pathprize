//
//  SignUpBusinessView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation
import SwiftUI

struct SignUpBusinessView: View {
    @EnvironmentObject var router: Router
    private var userType = UserType.business.rawValue
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var isEmailValid: Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email)
    }

    var isPasswordValid: Bool {
        let passwordPattern = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*()_+]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        return passwordPredicate.evaluate(with: password)
    }

    var doPasswordsMatch: Bool {
        return password == confirmPassword
    }

    var isSignUpButtonEnabled: Bool {
        return isEmailValid && isPasswordValid && doPasswordsMatch
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Registration")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("Create your Step Quest profile and get access to the best of our products, inspiration & community.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.vertical, 10)

            VStack(alignment: .leading, spacing: 20) {
                // Email field
                Text("YOUR EMAIL")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                TextField("Email Address", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Password field
                Text("YOUR PASSWORD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Confirm Password field
                Text("CONFIRM PASSWORD")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondaryText)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

            }
            .padding(.vertical)

            // Sign Up button
            Button(action: {
                Task {
                    do {
                        try await AuthManager.shared.signUp(email: email, password: password, userType: userType)
                        router.navigate(to: .shopsOnboarding)
                    } catch {
                        // Handle errors (e.g., display an alert)
                        print("Sign up failed: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Join Us")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSignUpButtonEnabled ? .accent : Color.gray)
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
            .disabled(!isSignUpButtonEnabled)

            Spacer()

            // Disclaimer text
            Text("By creating an account, you agree with GoFit's Privacy Policy & Terms of Use")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
}

struct SignUpBusinessView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpBusinessView()
    }
}
