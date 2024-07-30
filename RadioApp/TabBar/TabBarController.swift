//
//  TabBarController.swift
//  RadioApp
//
//  Created by Мария Нестерова on 29.07.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        //let popularVC = NavigationController(rootViewController: ViewController())
        let popularVC = NavigationController(rootViewController: PopularViewController())
        popularVC.tabBarItem.title = "Popular"
        popularVC.view.backgroundColor = .darkBlueApp

        let favoriteVC = NavigationController(rootViewController: ViewController())
        favoriteVC.tabBarItem.title = "Favorites"
        favoriteVC.view.backgroundColor = .lightBlueApp
        
        let allStationsVC = NavigationController(rootViewController: ViewController())
        favoriteVC.tabBarItem.title = "All Stations"
        allStationsVC.view.backgroundColor = .neonBlueApp
        
        viewControllers = [popularVC, favoriteVC, allStationsVC]
    }
}