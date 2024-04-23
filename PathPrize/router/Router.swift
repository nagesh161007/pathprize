//
//  Router.swift
//  PathPrize
//
//  Created by nagesh sairam on 4/22/24.
//

import Foundation
import SwiftUI

class Router: ObservableObject {
    static let shared = Router()
    @Published var navPath = NavigationPath()

    func navigate(to destination: NavigationDestination) {
        navPath.append(destination)
    }
    
    func replace(to destination: NavigationDestination) {
        navPath.removeLast(navPath.count)
        navPath.append(destination)
    }

    func navigateBack() {
        navPath.removeLast()
    }

    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}

enum NavigationDestination: Hashable {
    case landingView
    case registrationChoiceView
    case signUpUserView
    case signUpBusinessView
    case onboardingView
    case homeView
}
