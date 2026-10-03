//
//  FetchGameControllerOperation.swift
//  Controllers
//
//  Created by 강동영 on 2023/09/25.
//

import Foundation
import UserNotifications
import ControllerKit

class FetchGameControllerOperation: Operation {
    private let manager: GameControllerManager
    
    init(manager: GameControllerManager) {
        self.manager = manager
    }
    
    override func main() {
        guard
            let info = manager.getControlelrInfo(),
            info.controllerCount > 0
        else { return }

        let level = Int(info.batteryLevel * 100)

        // 백그라운드에서도 잠금화면 Live Activity 가 최신 배터리 정보를 반영하도록 갱신한다.
        LiveActivityManager.shared.update(batteryLevel: info.batteryLevel,
                                          batteryState: info.batteryState.rawValue)

        let threshold = UserDefaults.shared.batteryNotificationThreshold

        // 배터리가 사용자가 설정한 임계값 이하일 때만 알림을 발송한다.
        guard level <= threshold else {
            NSLog("filter: 배터리 \(level)% > 임계값 \(threshold)%, 알림 스킵")
            return
        }

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let appName = Bundle.main.displayName
        content.title = appName.localized
        content.body = "Battery is low %@".localized(with: ["\(level)%"])
        NSLog("filter: Push 성공, 배터리 레벨 : \(level)%, 임계값: \(threshold)%")

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "batterPush", content: content, trigger: trigger)
        center.add(request)
    }
}
