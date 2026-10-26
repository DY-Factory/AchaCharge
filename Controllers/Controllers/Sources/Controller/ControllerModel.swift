//
//  ControllerModel.swift
//  Controllers
//
//  Created by 강동영 on 5/10/25.
//

import SwiftUI
import StoreKit
import ControllerKit

final class ControllerModel: ObservableObject {
    @Published var isConnected: Bool = false {
        didSet {
            UserDefaults.shared.setValue(isConnected, forKey: StringKey.CONTROLLER_CONNECTED)
        }
    }
    @Published var batteryLevel: Float = 0.0
    @Published var vendorName: String = ""
    @Published var isCharging: Bool = false
    
    private let manager = GameControllerManager.shared
    
    init() {
        UserDefaults.shared.setValue(false, forKey: StringKey.CONTROLLER_CONNECTED)
        addControllerObservers()
        #if DEBUG
        applyScreenshotFixture()
        // -ACReviewTest YES: 누적 연결 횟수를 2로 맞추고 연결을 한 번 흉내 내 평가 요청 경로를 탄다.
        if UserDefaults.standard.bool(forKey: "ACReviewTest") {
            UserDefaults.standard.set(2, forKey: StringKey.CONTROLLER_CONNECT_COUNT)
            UserDefaults.standard.removeObject(forKey: StringKey.LAST_REVIEW_REQUEST_VERSION)
            countConnectionAndRequestReview()
        }
        #endif
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    public func updateControllerInfo() {
        #if DEBUG
        // 스크린샷용 모의 상태를 실제 조회(시뮬레이터에서는 항상 없음)로 덮어쓰지 않는다.
        if ScreenshotFixture.mockController != nil { return }
        #endif
        guard let info = manager.getControlelrInfo() else {
            batteryLevel = 0.0
            isCharging = false
            return
        }

        NSLog("batteryLevel: \(info.batteryLevel)")
        vendorName = info.vendorName
        batteryLevel = info.batteryLevel
        isCharging = info.batteryState == .charging
        UserDefaults.shared.setValue(info.batteryLevel, forKey: StringKey.BATTERY_LEVEL)

        // 활성화된 Live Activity 가 있으면 배터리 정보를 갱신한다.
        LiveActivityManager.shared.update(batteryLevel: info.batteryLevel,
                                          batteryState: info.batteryState.rawValue)
    }
}

// MARK: - Live Activity
extension ControllerModel {
    /// 컨트롤러 연결 시 배터리 Live Activity 를 시작한다. (구독자·광고 이용권 사용자 전용)
    private func startLiveActivity() {
        guard let info = manager.getControlelrInfo() else { return }
        LiveActivityManager.shared.start(vendorName: info.vendorName,
                                         batteryLevel: info.batteryLevel,
                                         batteryState: info.batteryState.rawValue)
    }
}

extension ControllerModel {
    private func addControllerObservers() {
        manager.addDelegate(self)
        // 컨트롤러가 연결된 채로 광고 이용권을 받으면 바로 Live Activity 를 띄운다.
        NotificationCenter.default.addObserver(forName: .proPassGranted, object: nil, queue: .main) { [weak self] _ in
            guard self?.isConnected == true else { return }
            self?.startLiveActivity()
        }
    }
}

// MARK: - GameControllerDelegate Method
extension ControllerModel: GameControllerDelegate {
    func didConnectedController() {
        #if DEBUG
        // 시뮬레이터가 알리는 가상 컨트롤러 대신 스크린샷용 모의 상태를 유지한다.
        if ScreenshotFixture.isEnabled { return }
        #endif
        isConnected = true
        updateControllerInfo()
        startLiveActivity()
        // 유료 기능을 쓰지 않는 사용자에게 앱 실행 후 첫 연결 때 Pro 소개 팝업을 띄운다.
        Task { @MainActor in
            ProPromotionManager.shared.controllerDidConnect()
        }
        countConnectionAndRequestReview()
    }

    func didDisConnectedController() {
        isConnected = false
        updateControllerInfo()
        LiveActivityManager.shared.end()
    }
}

// MARK: - Review Request
extension ControllerModel {
    /// 연결 횟수를 세고, 세 번째 연결부터 버전당 한 번 평가를 요청한다.
    private func countConnectionAndRequestReview() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: StringKey.CONTROLLER_CONNECT_COUNT) + 1
        defaults.set(count, forKey: StringKey.CONTROLLER_CONNECT_COUNT)
        let version = Bundle.main.versionString
        guard count >= 3, defaults.string(forKey: StringKey.LAST_REVIEW_REQUEST_VERSION) != version else { return }

        // 연결 직후 뜨는 Pro 팝업·시스템 팝업과 겹치지 않게 조금 기다린다.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard ProPromotionManager.shared.isLaunchFlowFinished,
                  !ProPromotionManager.shared.didPresentAlert,
                  !AppOpenAdManager.shared.isShowingAd,
                  !RewardedPassManager.shared.isShowingAd,
                  UIApplication.shared.applicationState == .active,
                  let topViewController = UIApplication.topViewController(),
                  topViewController.presentedViewController == nil,
                  !(topViewController is UIAlertController),
                  let windowScene = topViewController.view.window?.windowScene else {
                NSLog("Review request skipped (connect count: \(count))")
                return
            }
            defaults.set(version, forKey: StringKey.LAST_REVIEW_REQUEST_VERSION)
            NSLog("Review requested (connect count: \(count), version: \(version))")
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#if DEBUG
// MARK: - Screenshot Fixture
extension ControllerModel {
    /// 스크린샷용 실행 인자가 있으면 모의 컨트롤러 상태를 반영한다.
    private func applyScreenshotFixture() {
        guard ScreenshotFixture.isEnabled else { return }
        if let mock = ScreenshotFixture.mockController {
            isConnected = true
            vendorName = mock.vendorName
            batteryLevel = mock.batteryLevel
            isCharging = mock.isCharging
        }
        ScreenshotFixture.writeWidgetState()
    }
}
#endif
