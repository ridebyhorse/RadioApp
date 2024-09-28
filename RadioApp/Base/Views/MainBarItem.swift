//
//  MainBarItem.swift
//  RadioApp
//
//  Created by Мария Нестерова on 28.09.2024.
//

import UIKit

class MainBarItem: UIView {
    init(name: String?) {
        super.init(frame: .zero)
        let icon = UIImageView(image: .iconNoBg)
        icon.contentMode = .scaleAspectFit
        
        let greetingTitle = UILabel()
        greetingTitle.text = "Hello".localized
        greetingTitle.textColor = .white
        greetingTitle.font = .systemFont(ofSize: 25, weight: .medium)
        
        let nameTitle = UILabel()
        nameTitle.text = name
        nameTitle.textColor = .pinkApp
        nameTitle.font = .systemFont(ofSize: 30, weight: .medium)
        
        addSubview(icon)
        addSubview(greetingTitle)
        addSubview(nameTitle)
        
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(33)
            make.leading.bottom.equalToSuperview()
        }
        
        greetingTitle.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(8)
            make.bottom.equalTo(icon.snp.bottom).inset(1)
        }
        
        nameTitle.snp.makeConstraints { make in
            make.leading.equalTo(greetingTitle.snp.trailing).offset(5)
            make.bottom.equalTo(icon)
            make.trailing.top.equalToSuperview().inset(6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
