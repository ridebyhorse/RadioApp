//
//  UIImage+Mask.swift
//  RadioApp
//
//  Created by Мария Нестерова on 28.09.2024.
//

import UIKit

extension UIImage {
    func getMasked() -> UIImage {
        let mask: UIImage = .mask
        let size = size
        let renderer = UIGraphicsImageRenderer(size: size)
        let maskedImage = renderer.image { context in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 1)
            mask.draw(in: CGRect(origin: .zero, size: size), blendMode: .destinationIn, alpha: 1)
        }
        
        return maskedImage
    }
}
