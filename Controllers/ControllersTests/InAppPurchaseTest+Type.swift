//
//  InAppPurchaseTest+Type.swift
//  ControllersTests
//
//  Created by 강동영 on 3/1/24.
//

import Foundation

enum FetchingProductIDType: String {
    case success = "ProductIDs"
    case fail = "TestProductIDs"
}

enum TestProductIDs: CaseIterable {
    case year
    case month
    case week
    
    var identifier: String {
        switch self {
        case .year: "yearly.25percent"
        case .month: "monthly.10percent"
        case .week: "weekly"
        }
    }
}
