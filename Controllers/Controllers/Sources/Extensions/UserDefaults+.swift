//
//  UserDefaults+.swift
//  Controllers
//
//  Created by 강동영 on 2023/06/28.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.arex.achaCharge"
        return UserDefaults(suiteName: appGroupId)!
    }

    /// 충전 알림이 발송되는 배터리 임계값 (%). 설정값이 없으면 기본 20% 를 반환한다.
    var batteryNotificationThreshold: Int {
        get {
            let value = integer(forKey: StringKey.BATTERY_NOTIFICATION_THRESHOLD)
            return value == 0 ? 20 : value
        }
        set {
            setValue(newValue, forKey: StringKey.BATTERY_NOTIFICATION_THRESHOLD)
        }
    }
}
