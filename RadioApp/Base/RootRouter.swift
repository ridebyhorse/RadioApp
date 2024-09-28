//
//  RootRouter.swift
//  RadioApp
//
//  Created by Мария Нестерова on 06.08.2024.
//

import UIKit

final class RootRouter {
    private let window: UIWindow
    private let builder: RootBuilder
    private let authenticationManager = AuthenticationManager.shared

    init(_ window: UIWindow, builder: RootBuilder) {
        self.window = window
        self.builder = builder
    }

    func startFlow() {
        let loading = ViewController()
        loading.showLoading()
        window.rootViewController = loading
        window.makeKeyAndVisible()
        authenticationManager.getAuthenticatedUser { [weak self] user in
            if user != nil {
                self?.startHome()
            } else {
                let onboarding = self?.builder.buildOnboarding()
                onboarding?.root = self
                onboarding?.showOnboarding(on: self?.window ?? UIWindow())
            }
        }
    }

    func startAuthorization() {
        let authorization = builder.buildAuthorization()
        authorization.root = self
        authorization.showAuthorization(on: window)
    }

    func startHome() {
        let home = builder.buildHome()
        home.root = self
        home.showHome(on: window)
    }
}
