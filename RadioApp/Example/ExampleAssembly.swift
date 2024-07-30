//
//  ExampleAssembly.swift
//  RadioApp
//
//  Created by Мария Нестерова on 30.07.2024.
//

import UIKit

final class ExampleAssembly: ModuleAssembly {
    func build() -> UIViewController {
        let controller = ExampleController()
        let presenter = ExamplePresenter()
        let router = ExampleRouter()
        
        presenter.view = controller
        presenter.router = router
        controller.presenter = presenter
        router.controller = controller
        
        controller.hidesBottomBarWhenPushed = true
        
        return controller
    }
}