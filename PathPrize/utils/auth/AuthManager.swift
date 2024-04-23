//
//  AuthManager.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/22/24.
//

import Foundation
import Supabase

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true

    
    func test(){
        print("test")
    }
    
    init() {
           Task {
               await initializeAuthState()
               DispatchQueue.main.async {
                   self.isLoading = false
               }
               for await (event, session) in supabase.auth.authStateChanges {
                   DispatchQueue.main.async {
                       self.handleAuthStateChanged(event: event, session: session)
                   }
               }
           }
       }

       private func handleAuthStateChanged(event: AuthChangeEvent, session: Session?) {
           switch event {
           case .signedIn:
               if let user = session?.user {
                   self.currentUser = user
                   self.isAuthenticated = true
               }
           case .signedOut:
               self.currentUser = nil
               self.isAuthenticated = false
           default:
               break
           }
   }
    
    private func initializeAuthState() async {
        do {
            // Attempt to directly obtain the user from Supabase auth
            let user = try await supabase.auth.user()
            print(user)
            DispatchQueue.main.async {
                // Since `user` is non-optional, we directly assign it
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("Error retrieving user: \(error.localizedDescription)")
            DispatchQueue.main.async {
                // Handle the error case by setting the user as nil and not authenticated
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }

    func signUp(email: String, password: String, userType: String) async throws {
        do {
            let result = try await supabase.auth.signUp(email: email, password: password, data: [
                "user_type": .string(userType),
                "onboarding_state": "ACCOUNT_CREATED"
              ])
            if let session = result.session {
                DispatchQueue.main.async {
                    // Assuming `session.user` is non-optional based on your error
                    // If `user` is not optional, there's no need to use `if let` to unwrap it
                    self.currentUser = session.user  // Directly assigning the user
                    self.isAuthenticated = true
                }
            } else {
                // Handle the case where there is no session or user
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Failed to sign up: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
    func login(email: String, password: String) async  -> User? {
        do {
            let result = try await supabase.auth.signIn(email: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user  // Direct assignment since User is non-optional
                self.isAuthenticated = true
            }
            return result.user
        } catch {
            DispatchQueue.main.async {
                print("Login failed: \(error.localizedDescription)")
                self.isAuthenticated = false
                self.currentUser = nil
            }
            return nil
        }
    }


    func signOut() async {
        do {
            try await supabase.auth.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
