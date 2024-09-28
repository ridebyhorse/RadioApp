//
//  RootBuilder.swift
//  RadioApp
//
//  Created by Мария Нестерова on 06.08.2024.
//

import UIKit

final class RootBuilder {
    static func makeRootRouter(_ scene: UIWindowScene) -> RootRouter {
        RootRouter(UIWindow(windowScene: scene), builder: RootBuilder())
    }
    
    func buildOnboarding() -> OnboardingRouter {
        let builder = OnboardingAssembly()
        return OnboardingRouter(builder: builder)
    }
    
    func buildAuthorization() -> AuthorizationRouter {
        let builder = AuthorizationAssembly()
        return AuthorizationRouter(builder: builder)
    }
    
    func buildHome() -> HomeRouter {
        let builder = HomeAssembly()
        return HomeRouter(builder: builder)
    }
}
