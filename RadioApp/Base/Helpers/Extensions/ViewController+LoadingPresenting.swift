//
//  ViewController+LoadingPresenting.swift
//  RadioApp
//
//  Created by Мария Нестерова on 28.09.2024.
//

extension ViewController: LoadingPresenting {
    func showLoading() {
        let loadingView = LoadingView()
        loadingView.animation.play()
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loadingView.backgroundColor = .darkBlueApp
    }
    
    func hideLoading() {
        guard let loadingViewIndex = view.subviews.firstIndex(where: { $0 is LoadingView }) else { return }
        view.subviews[loadingViewIndex].removeFromSuperview()
    }
}
