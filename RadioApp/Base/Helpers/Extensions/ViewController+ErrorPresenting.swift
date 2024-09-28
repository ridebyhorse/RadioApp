//
//  ViewController+ErrorPresenting.swift
//  RadioApp
//
//  Created by Мария Нестерова on 28.09.2024.
//

import UIKit

extension ViewController: ErrorPresenting {
    func showError(
        isAlert: Bool,
        title: String,
        message: String?,
        actionTitle: String?,
        action: ((UIView) -> Void)?
    ) {
        let errorView = ErrorView()
        errorView.title = title
        errorView.message = message
        errorView.actionTitle = actionTitle
        errorView.action = action
        
        view.addSubview(errorView)
        if isAlert {
            errorView.layer.cornerRadius = 24
            errorView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(30)
                $0.height.equalToSuperview().dividedBy(3)
            }
        } else {
            errorView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        errorView.animation.play()
    }
    
    func hideError() {
        guard let errorViewIndex = view.subviews.firstIndex(where: { $0 is ErrorView }) else { return }
        view.subviews[errorViewIndex].removeFromSuperview()
    }
}
