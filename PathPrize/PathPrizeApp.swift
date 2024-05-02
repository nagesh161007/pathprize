//
//  PathPrizeApp.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/18/24.
//

import SwiftUI

@main
struct PathPrizeApp: App {
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var router = Router.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                RootView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case .homeView:
                            HomePage().navigationBarBackButtonHidden(true)
                        case .landingView:
                            LandingView().navigationBarBackButtonHidden(true)
                        case .signUpUserView:
                            SignUpUserView()
                        case .signUpBusinessView:
                            SignUpBusinessView()
                        case .registrationChoiceView:
                            RegistrationChoiceView().navigationTitle("Choose")
                        case .onboardingView:
                            PersonalInfoView().navigationBarBackButtonHidden(true)
                        case .shopsOnboarding:
                            ShopsOnboarding().navigationBarBackButtonHidden(true)
                        case .businessHomeView:
                            BusinessHomeView().navigationBarBackButtonHidden(true)                        }
                    }
            }
            .environmentObject(authManager)
            .environmentObject(router)
        }
    }
}
