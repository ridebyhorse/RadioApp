//
//  Builder.swift
//  RadioApp
//
//  Created by Мария Нестерова on 29.07.2024.
//

import UIKit

final class Builder {
    static func createPopular() -> UIViewController {
        let controller = PopularAssembly().build(router: PopularRouter())
        return NavigationController(rootViewController: controller)
    }

    static func createFavorite() -> UIViewController {
        let controller = FavoritesAssembly().build(router: FavoritesRouter())
        return NavigationController(rootViewController: controller)
    }

    static func createAllStations() -> UIViewController {
        let navigation = NavigationController()
        let builder = AllStationsAssembly()
        let router = AllStationsRouter(builder: builder, navigation: navigation)
        router.showAllStations()
        return navigation
    }
    
    static func createProfile() -> UIViewController {
        ProfileAssembly().build(router: ProfileRouter())
    }
    
    static func createAudioPlayer() -> UIViewController {
        AudioAssembly().build()
    }
}
