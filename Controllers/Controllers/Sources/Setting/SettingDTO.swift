//
//  SettingDTO.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/28.
//

import Foundation

struct SettingItemDTO: Decodable {
    let sectionTypeCode: Int
    let typeImageName: String
    let title: String
    let isNewBadge: String
    let buttonTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case sectionTypeCode
        case typeImageName
        case title
        case isNewBadge
        case buttonTitle
    }
}
