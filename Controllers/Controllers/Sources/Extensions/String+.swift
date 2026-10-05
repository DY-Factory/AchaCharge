//
//  String+.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/29.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: "", bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(with argument: [CVarArg] = []) -> String {
        return String(format: self.localized, arguments: argument)
    }
}
