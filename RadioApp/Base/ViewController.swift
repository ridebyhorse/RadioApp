//
//  ViewController.swift
//  RadioApp
//
//  Created by Мария Нестерова on 29.07.2024.
//

import UIKit

class ViewController: UIViewController {
    private let storageManager = StorageManager.shared
    private let authenticationManager = AuthenticationManager.shared
    
    var playerIsHidden: Bool = false
    var playerVolumeIsHidden: Bool = false
    private var name: String? { didSet { configureNavigationBarItems() } }
    private lazy var profileImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBarItems()
        configureTabBarAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUserData()
        
        if let homeController = tabBarController as? HomeController {
            homeController.playerIsHidden = playerIsHidden
            homeController.volumeIsHidden = playerVolumeIsHidden
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let homeController = tabBarController as? HomeController {
            homeController.playerIsHidden = !playerIsHidden
            homeController.volumeIsHidden = !playerVolumeIsHidden
        }
    }
    
    private func configureNavigationBarItems() {
        setRightBarButtonItem()
        setLeftBarButtonItem()
    }
    
    private func setRightBarButtonItem() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.didTapProfilePic)
            )
        )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    private func setLeftBarButtonItem() {
        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = .init(
                image: .backButton.withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(didTapBackButton)
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: MainBarItem(name: name))
        }
    }
    
    func setUserData() {
        profileImageView.image = storageManager.getUserImage().getMasked()
        name = authenticationManager.getCurrentUser()?.displayName
    }
    
    private func configureTabBarAttributes() {
        guard let homeController = tabBarController as? HomeController else { return }
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = homeController.normalTabBarAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = homeController.selectedTabBarAttributes
        homeController.tabBar.standardAppearance = appearance
        homeController.tabBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func didTapBackButton() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func didTapProfilePic() {
        let profileVC = Builder.createProfile()
        guard let topVC = navigationController?.topViewController else { return }
        if topVC as? ProfileViewController == nil {
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}
