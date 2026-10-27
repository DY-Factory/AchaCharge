//
//  WidgetSharedState.swift
//  Controllers
//
//  위젯이 그릴 컨트롤러 상태를 App Group 에 쓰고 타임라인을 다시 읽게 한다. (앱 → 위젯 단방향)
//

import Foundation
import WidgetKit
import ControllerKit

enum WidgetSharedState {
    /// 상태가 그대로면 이 간격 안에는 타임라인을 다시 읽히지 않는다. (WidgetKit 갱신 예산 절약)
    private static let reloadInterval: TimeInterval = 15 * 60
    private static var lastReload: (isConnected: Bool, batteryLevel: Float, batteryState: Int, date: Date)?

    /// 미연결이면 연결 여부만 쓴다. 마지막으로 알던 잔량·기기 이름·갱신 시각은 남겨 위젯이 "Last: 42%"로 보여 준다.
    static func save(isConnected: Bool,
                     batteryLevel: Float = 0,
                     batteryState: Int = BatteryState.unknown.rawValue,
                     vendorName: String = "") {
        let defaults = UserDefaults.shared
        defaults.setValue(isConnected, forKey: StringKey.CONTROLLER_CONNECTED)
        if isConnected {
            defaults.setValue(batteryLevel, forKey: StringKey.BATTERY_LEVEL)
            defaults.setValue(batteryState, forKey: StringKey.BATTERY_STATE)
            defaults.setValue(vendorName, forKey: StringKey.VENDOR_NAME)
            defaults.setValue(Date().timeIntervalSince1970, forKey: StringKey.LAST_UPDATED)
        }

        if let last = lastReload,
           last.isConnected == isConnected,
           last.batteryState == batteryState,
           abs(last.batteryLevel - batteryLevel) < 0.01,
           Date().timeIntervalSince(last.date) < reloadInterval {
            return
        }
        lastReload = (isConnected, batteryLevel, batteryState, Date())
        WidgetCenter.shared.reloadTimelines(ofKind: StringKey.WIDGET_KIND)
    }
}
