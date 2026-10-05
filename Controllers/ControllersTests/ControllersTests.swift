//
//  ControllersTests.swift
//  ControllersTests
//
//  Created by 강동영 on 2023/08/09.
//

import XCTest

final class ControllersTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
    }

    func testPerformanceExample() throws {
        measure {}
    }

    func testFetchingProductIdentifiers() {
        let productType: [String] = TestProductIDs.allCases.map { $0.identifier }
        let identifiers = fetchingProductIdentifiers(with: .success)
        XCTAssertTrue(identifiers.count != 0)
        XCTAssertTrue(productType.count == identifiers.count)
        XCTAssertTrue(productType.contains(identifiers))
    }
    
    func testInvalidProductIdentifiers() {
        let productType: [String] = TestProductIDs.allCases.map { $0.identifier }
        let identifiers = fetchingProductIdentifiers(with: .fail)
        XCTAssertTrue(identifiers.count != 0)
        XCTAssertFalse(productType.count == identifiers.count)
        XCTAssertFalse(productType.contains(identifiers))
    }
    
    func testMonthRequestProduct() {
        let monthIdentifier: String = fetchingProductIdentifiers(with: .success).filter { $0 == TestProductIDs.month.identifier }.first!
        let testProduct = TestProduct(productIdentifier: monthIdentifier)
        
    }
    
    private func fetchingProductIdentifiers(with type: FetchingProductIDType) -> [String] {
        let productType: [String] = TestProductIDs.allCases.map { $0.identifier }
        let result = getProductIdentifiers(with: type)
        
        switch result {
        case .success(let identifiers):
            let productIdentifiers = Array(Set(identifiers))
            print("Test >> productIdentifiers: \(productIdentifiers)")
            print("Test >> productType's identifiers: \(productType)")
            return productIdentifiers
        case .failure(let error):
            print("\(error.localizedDescription)")
            return []
        }
    }
    
    private func getProductIdentifiers(with type: FetchingProductIDType) -> Result<[String], Error> {
        var productIDs: [String] = []
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "plist") else {
            fatalError("Unable to resolve url for in the bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let productIdentifiers = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String]
            productIDs = productIdentifiers ?? []
            
            return .success(productIDs)
        } catch let error as NSError {
            return .failure(error)
        }
    }
}
