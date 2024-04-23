//
//  AuthView.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/22/24.
//

import Foundation
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var router: Router
    
    var body: some View {
            Group {
                if authManager.isLoading {
                    ProgressView()
                } else if authManager.isAuthenticated {
                    HomePage().navigationBarBackButtonHidden(true).navigationTitle("Home Page")
                } else {
                    LandingView()
                }
        }
   }
}
