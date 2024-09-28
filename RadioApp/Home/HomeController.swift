//
//  HomeController.swift
//  RadioApp
//
//  Created by Мария Нестерова on 29.07.2024.
//

import UIKit
import SnapKit

final class HomeController: UITabBarController {
    private let presenter: HomePresenter
    private let audioPlayerVC = Builder.createAudioPlayer()
    
    private let bar = UIView()
    private var buttons = [UIButton]()
    
    let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 20, weight: .medium),
        .foregroundColor: UIColor.gray
    ]
    
    let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 20, weight: .medium),
        .foregroundColor: UIColor.white
    ]
    
    var playerIsHidden: Bool {
        get { audioPlayerVC.view.isHidden }
        set { audioPlayerVC.view.isHidden = newValue }
    }
    
    var volumeIsHidden: Bool {
        get {
            if let volumeView = audioPlayerVC.view.subviews.first(where: { $0 is VerticalVolumeView }) as? VerticalVolumeView {
                return volumeView.isHidden
            }
            return false
        }
        set {
            if let volumeView = audioPlayerVC.view.subviews.first(where: { $0 is VerticalVolumeView }) as? VerticalVolumeView {
                volumeView.isHidden = newValue
            }
        }
    }
    let indicator: UIImageView = {
        let view = UIImageView(image: .highlight, contentMode: .scaleAspectFit, renderingMode: .alwaysOriginal, isHidden: false)
        view.frame.size = CGSize(width: 15, height: 15)
        
        return view
    }()
    
    init(presenter: HomePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tabBar.addSubview(indicator)
        self.delegate = self
        additionalSafeAreaInsets.bottom = 30
        setupAudioPlayer()
    }
    
    private func configure() {
        let popularVC = Builder.createPopular()
        popularVC.tabBarItem.title = "Popular".localized
        popularVC.view.backgroundColor = .darkBlueApp
        
        let favoriteVC = Builder.createFavorite()
        favoriteVC.tabBarItem.title = "Favorites".localized
        favoriteVC.view.backgroundColor = .darkBlueApp
        
        let allStationsVC = Builder.createAllStations()
        allStationsVC.tabBarItem.title = "All Stations".localized
        allStationsVC.view.backgroundColor = .darkBlueApp
        
        viewControllers = [popularVC, favoriteVC, allStationsVC]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animate(index: selectedIndex)
    }
    
    private func animate(index: Int) {
        let buttons = tabBar.subviews
            .filter({ String(describing: $0).contains("Button") })
        
        guard index < buttons.count else { return }
        let selectedButton = buttons[index]
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                let point = CGPoint(
                    x: selectedButton.center.x,
                    y: selectedButton.frame.maxY + 20
                )
                print(point)
                self.indicator.center = point
            },
            completion: nil
        )
    }
}

// MARK: - Set AudioPlayer
private extension HomeController {
    func setupAudioPlayer() {
        addChild(audioPlayerVC)
        view.addSubview(audioPlayerVC.view)
        audioPlayerVC.didMove(toParent: self)
        
        audioPlayerVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HomeController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard
            let items = tabBar.items,
            let index = items.firstIndex(of: item)
        else {
            return
        }

        animate(index: index)
    }
}
