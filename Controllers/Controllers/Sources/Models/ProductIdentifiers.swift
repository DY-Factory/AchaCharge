//
//  ProductIdentifiers.swift
//  Controllers
//
//  Created by 강동영 on 2023/10/05.
//

import Foundation

struct ProductIdentifiers {
    /// Name of the resource file containing the product identifiers.
    let name = "ProductIDs"
    /// Filename extension of the resource file containing the product identifiers.
    let fileExtension = "plist"
}

extension ProductIdentifiers {
    var identifiers: [String]? {
        guard let path = Bundle.main.path(forResource: self.name, ofType: self.fileExtension) else { return nil }
        return NSArray(contentsOfFile: path) as? [String]
    }
}
