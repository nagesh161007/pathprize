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
                   LoadingView()
                } else if authManager.isAuthenticated {
                    if(authManager.isBusiness){
                        BusinessHomeView().navigationBarBackButtonHidden(true)
                    } else {
                        HomePage().navigationBarBackButtonHidden(true)
                    }
                } else {
                    LandingView()
                }
        }
   }
}
