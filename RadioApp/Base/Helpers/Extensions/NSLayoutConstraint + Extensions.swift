//
//  NSLayoutConstraint + Extensions.swift
//  RadioApp
//
//  Created by realeti on 27.09.2024.
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
