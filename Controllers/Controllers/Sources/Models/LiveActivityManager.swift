//
//  LiveActivityManager.swift
//  Controllers
//
//  ActivityKit 을 래핑해 컨트롤러 배터리 Live Activity 의 시작/갱신/종료를 관리한다.
//  iOS 16.1+ 에서만 동작하며, 그 이하 버전에서는 모든 호출이 무시된다.
//

import Foundation
import ActivityKit

final class LiveActivityManager {

    static let shared = LiveActivityManager()
    private init() {}

    // MARK: - Public API (버전 무관 진입점)

    /// 컨트롤러 연결 시 Live Activity 를 시작한다. (프리미엄 구독자 전용)
    func start(vendorName: String, batteryLevel: Float, batteryState: Int) {
        if #available(iOS 16.1, *) {
            startActivity(vendorName: vendorName, batteryLevel: batteryLevel, batteryState: batteryState)
        }
    }

    /// 배터리 정보 변경 시 활성화된 Live Activity 를 갱신한다.
    func update(batteryLevel: Float, batteryState: Int) {
        if #available(iOS 16.1, *) {
            updateActivity(batteryLevel: batteryLevel, batteryState: batteryState)
        }
    }

    /// 컨트롤러 연결 해제 시 Live Activity 를 종료한다.
    func end() {
        if #available(iOS 16.1, *) {
            endActivity()
        }
    }

    // MARK: - ActivityKit 구현 (iOS 16.1+)

    /// 시스템의 Activity 목록을 기준으로 삼아, 앱이 재시작돼도 실행 중인 Activity 를 이어서 사용한다.
    @available(iOS 16.1, *)
    private var currentActivity: Activity<ControllerActivityAttributes>? {
        Activity<ControllerActivityAttributes>.activities.first { $0.activityState == .active }
    }

    @available(iOS 16.1, *)
    private func startActivity(vendorName: String, batteryLevel: Float, batteryState: Int) {
        // 구독자에게만 제공하는 기능
        guard StoreKitManager.shared.isSubscribed else { return }
        // 사용자가 Live Activity 를 허용한 경우에만 시작
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // 이미 활성화된 Activity 가 있으면 새로 만들지 않고 갱신만 한다.
        guard currentActivity == nil else {
            updateActivity(batteryLevel: batteryLevel, batteryState: batteryState)
            return
        }

        let attributes = ControllerActivityAttributes(vendorName: vendorName)
        let contentState = ControllerActivityAttributes.ContentState(
            batteryLevel: batteryLevel,
            batteryState: batteryState
        )

        do {
            if #available(iOS 16.2, *) {
                _ = try Activity.request(
                    attributes: attributes,
                    content: .init(state: contentState, staleDate: nil)
                )
            } else {
                _ = try Activity.request(
                    attributes: attributes,
                    contentState: contentState
                )
            }
            NSLog("LiveActivity 시작: \(vendorName)")
        } catch {
            NSLog("LiveActivity 시작 실패: \(error.localizedDescription)")
        }
    }

    @available(iOS 16.1, *)
    private func updateActivity(batteryLevel: Float, batteryState: Int) {
        guard let activity = currentActivity else { return }

        let contentState = ControllerActivityAttributes.ContentState(
            batteryLevel: batteryLevel,
            batteryState: batteryState
        )

        Task {
            if #available(iOS 16.2, *) {
                await activity.update(.init(state: contentState, staleDate: nil))
            } else {
                await activity.update(using: contentState)
            }
        }
    }

    @available(iOS 16.1, *)
    private func endActivity() {
        // 이전 실행에서 남은 Activity 까지 모두 종료한다.
        Task {
            for activity in Activity<ControllerActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
