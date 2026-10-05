//
//  StoreKitManager.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/27.
//

import Foundation
import StoreKit

enum SubscriptionType: Int {
    case week = 0
    case month
    case yearly
    
    var identifier: String {
        switch self {
        case .week: "weekly"
        case .month: "monthly.10percent"
        case .yearly: "yearly.25percent"
        }
    }
}

public protocol InAppRequest: AnyObject {
    func start()
    func cancel()
}

final class StoreKitManager: NSObject {
    
    static let shared: StoreKitManager = StoreKitManager()
    var isSubscribed: Bool {
        return UserDefaults.standard.value(forKey: StringKey.IS_SUBSCRIBED) as? Bool ?? false
    }
    
    var productIDs: [String] = []
    private var transactionUpdatesTask: Task<Void, Never>?

    private var isAuthorizedForPayments: Bool {
        let result = SKPaymentQueue.canMakePayments()
        return result
    }
    
    private override init() {
        super.init()
        print(#function, "StoreKitManager")
        getProductIdentifiers()
    }
}

// MARK: - StoreKit Private Method
extension StoreKitManager {
    private func getProductIdentifiers() {
        guard let url = Bundle.main.url(forResource: "ProductIDs", withExtension: "plist") else { fatalError("Unable to resolve url for in the bundle.") }
        do {
            let data = try Data(contentsOf: url)
            let productIdentifiers = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String]
            print("productIdentifiers: \(productIdentifiers)")
            productIDs = productIdentifiers ?? []
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
    }
}

// MARK: - Subscription Status (StoreKit 2)
// 구매는 SwiftyStoreKit(StoreKit 1)로 하고, 구독 여부는 Apple이 서명한 현재 권한으로 판단한다.
// StoreKit 1로 산 구독도 StoreKit 2에서 그대로 조회된다.
extension StoreKitManager {
    /// 만료·환불된 구독은 currentEntitlements에 포함되지 않는다. 해지했어도 결제 기간이 남았으면 포함된다.
    func refreshSubscriptionStatus() async {
        var isActive = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, productIDs.contains(transaction.productID) {
                isActive = true
            }
        }
        UserDefaults.standard.setValue(isActive, forKey: StringKey.IS_SUBSCRIBED)
    }

    /// 갱신·환불처럼 앱 밖에서 생긴 변경을 받는다. 트랜잭션 finish는 SwiftyStoreKit이 처리한다.
    func observeTransactionUpdates() {
        transactionUpdatesTask = Task {
            for await _ in Transaction.updates {
                await refreshSubscriptionStatus()
            }
        }
    }

    func restoreSubscription() async {
        try? await AppStore.sync()
        await refreshSubscriptionStatus()
    }

    /// 상품 ID별 현지 통화 가격 (예: "$2.99", "€2,99")
    func displayPrices() async -> [String: String] {
        let products = (try? await Product.products(for: productIDs)) ?? []
        return Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0.displayPrice) })
    }
}
