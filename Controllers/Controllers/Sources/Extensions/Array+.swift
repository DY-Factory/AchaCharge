//
//  Array+.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/28.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
