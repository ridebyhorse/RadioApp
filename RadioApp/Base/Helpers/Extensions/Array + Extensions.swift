//
//  Array + Extensions.swift
//  RadioApp
//
//  Created by realeti on 28.09.2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
