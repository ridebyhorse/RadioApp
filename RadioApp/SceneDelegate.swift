//
//  SceneDelegate.swift
//  RadioApp
//
//  Created by Мария Нестерова on 28.07.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var router: RootRouter?

    var window: UIWindow?
    private var isShowingHomeVC: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        router = RootBuilder.makeRootRouter(windowScene)
        router?.startFlow()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        StorageManager.shared.saveContext()
    }
}

