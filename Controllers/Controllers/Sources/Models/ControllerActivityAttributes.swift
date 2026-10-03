//
//  ControllerActivityAttributes.swift
//  Controllers
//
//  게임 컨트롤러 배터리 상태를 표시하는 Live Activity 의 속성 정의.
//  앱 타깃과 위젯 익스텐션 타깃 양쪽에서 공유한다.
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct ControllerActivityAttributes: ActivityAttributes {

    /// Live Activity 의 동적 콘텐츠 (배터리 변화에 따라 갱신된다)
    public struct ContentState: Codable, Hashable {
        /// 배터리 잔량 (0.0 ~ 1.0)
        var batteryLevel: Float
        /// 배터리 상태 (BatteryState rawValue: -1 unknown / 0 discharging / 1 charging / 2 full)
        var batteryState: Int
    }

    /// 컨트롤러 제조사 이름 (예: DualSense Wireless Controller) — Activity 생성 시 고정된다.
    var vendorName: String
}
