//
//  ViewController.swift
//  RadioApp
//
//  Created by Мария Нестерова on 29.07.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        //right
        navigationItem.rightBarButtonItem = .init(
            image: .mockPic.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapProfilePic)
        )
        //left
        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = .init(
                image: .backButton.withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(didTapBackButton)
            )
        } else {
            navigationItem.leftBarButtonItem = createCustomItem()
        }
    }
    
    private func createCustomItem() -> UIBarButtonItem {
        let icon = UIImageView(image: .iconNoBg)
        icon.contentMode = .scaleAspectFit
        
        let greetingTitle = UILabel()
        greetingTitle.text = "Hello"
        greetingTitle.textColor = .white
        greetingTitle.font = .systemFont(ofSize: 25, weight: .medium)
        
        let nameTitle = UILabel()
        nameTitle.text = "Mark"
        nameTitle.textColor = .pinkApp
        nameTitle.font = .systemFont(ofSize: 30, weight: .medium)
        
        let container = UIView()
        container.addSubview(icon)
        container.addSubview(greetingTitle)
        container.addSubview(nameTitle)
        
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(33)
        }
        
        greetingTitle.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.bottom.equalTo(icon.snp.bottom).inset(1.8)
        }
        
        nameTitle.snp.makeConstraints { make in
            make.leading.equalTo(greetingTitle.snp.trailing).offset(5)
            make.bottom.equalTo(icon)
        }
        
        container.snp.makeConstraints { make in
            make.leading.bottom.equalTo(icon)
            make.trailing.top.equalTo(nameTitle).inset(-6)
        }
        
        return UIBarButtonItem(customView: container)
    }
    
    @objc private func didTapBackButton() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func didTapProfilePic() {
        //go to ProfileVC
    }
}