//
//  LoginView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/21/24.
//

import Foundation

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""

    
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

    var isLoginButtonEnabled: Bool {
        return isEmailValid && isPasswordValid
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("Access your Step Quest profile to continue your journey towards a healthier lifestyle.")
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
            }
            .padding(.vertical)

            // Login button
            Button(action: loginAction) {
                Text("Login")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isLoginButtonEnabled ? Color.accentColor : Color.gray)
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
            .disabled(!isLoginButtonEnabled)

            Spacer()

        }
        .padding(.horizontal)
    }
    
    private func loginAction() {
        print("login Action here")
        Task {
            do {
                guard let user = await AuthManager.shared.login(email: email, password: password) else {
                    print("Login failed: Credentials were incorrect or user does not exist.")
                    return
                }
                
                print(user.userMetadata)
                print(user.userMetadata["user_type"])
                
                let isUser =  user.userMetadata["user_type"] == "USER"
               
                
                if(isUser){
                    let profileResponse: UserProfile = try await supabase
                        .from("profiles")
                        .select()
                        .eq("id", value: user.id)
                        .single()
                        .execute().value
                    
                    print(profileResponse)
                    
                    let onboardingState = profileResponse.onboardingState
                    
                    // Now you have the user's onboarding state
                    print("Onboarding state: \(onboardingState)")
                    
                    // Update the user's onboarding state or navigate based on it
                    if onboardingState == "ACCOUNT_CREATED" {
                        DispatchQueue.main.async {
                            Router.shared.navigate(to: .onboardingView)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("redirecting to Home page")
                            Router.shared.navigate(to: .homeView)
    //                        Router.shared.navigateToRoot()
                        }
                    }
                } else {
                    print(user.id)
                    let businessResponse: Business = try await supabase
                        .from("business")
                        .select()
                        .eq("id", value: user.id)
                        .single()
                        .execute().value
                    
                    print("business Response")
                    print(businessResponse)
                    
                    let onboardingState = businessResponse.onboardingState
                    
                    // Now you have the user's onboarding state
                    print("Onboarding state: \(onboardingState)")
                    
                    // Update the user's onboarding state or navigate based on it
                    if onboardingState == "ACCOUNT_CREATED" {
                        DispatchQueue.main.async {
                            Router.shared.navigate(to: .shopsOnboarding)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print("redirecting to Home page")
                            Router.shared.navigate(to: .businessHomeView)
    //                        Router.shared.navigateToRoot()
                        }
                    }
                }
                
            } catch {
                // Handle errors
                print("Login Error")
                print("Error: \(error)")
            }
        }
    }

    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
