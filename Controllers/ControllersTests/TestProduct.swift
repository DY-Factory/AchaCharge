//
//  TestProduct.swift
//  ControllersTests
//
//  Created by 강동영 on 3/1/24.
//

import Foundation
import StoreKit

class TestProduct: SKProduct {
    private let _productIdentifier: String

    override var productIdentifier: String {
        return _productIdentifier
    }

    init(productIdentifier: String) {
        _productIdentifier = productIdentifier
        super.init()
    }
}
