//
//  ControllerModel.swift
//  Controllers
//
//  Created by 강동영 on 5/10/25.
//

import SwiftUI
import ControllerKit

final class ControllerModel: ObservableObject {
    @Published var isConnected: Bool = false {
        didSet {
            UserDefaults.shared.setValue(isConnected, forKey: StringKey.CONTROLLER_CONNECTED)
        }
    }
    @Published var batteryLevel: Float = 0.0
    @Published var vendorName: String = ""
    
    private let manager = GameControllerManager.shared
    
    init() {
        UserDefaults.shared.setValue(false, forKey: StringKey.CONTROLLER_CONNECTED)
        addControllerObservers()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    public func updateControllerInfo() {
        guard let info = manager.getControlelrInfo() else {
            batteryLevel = 0.0
            return
        }

        NSLog("batteryLevel: \(info.batteryLevel)")
        vendorName = info.vendorName
        batteryLevel = info.batteryLevel
        UserDefaults.shared.setValue(info.batteryLevel, forKey: StringKey.BATTERY_LEVEL)

        // 활성화된 Live Activity 가 있으면 배터리 정보를 갱신한다.
        LiveActivityManager.shared.update(batteryLevel: info.batteryLevel,
                                          batteryState: info.batteryState.rawValue)
    }
}

// MARK: - Live Activity
extension ControllerModel {
    /// 컨트롤러 연결 시 배터리 Live Activity 를 시작한다. (프리미엄 구독자 전용)
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
    }
}

// MARK: - GameControllerDelegate Method
extension ControllerModel: GameControllerDelegate {
    func didConnectedController() {
        isConnected = true
        updateControllerInfo()
        startLiveActivity()
    }

    func didDisConnectedController() {
        isConnected = false
        updateControllerInfo()
        LiveActivityManager.shared.end()
    }
}
