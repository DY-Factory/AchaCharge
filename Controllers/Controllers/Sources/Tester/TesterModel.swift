//
//  TesterModel.swift
//  Controllers
//
//  Created by 강동영 on 5/26/25.
//

import SwiftUI
import ControllerKit

final class TesterModel: ObservableObject {
    // 연결 상태
    @Published var isConnected: Bool = false {
        didSet {
            UserDefaults.shared.setValue(isConnected, forKey: StringKey.CONTROLLER_CONNECTED)
        }
    }
    @Published var batteryLevel: Float = 0.0
    @Published var vendorName: String = ""
    
    // 버튼 상태
    @Published var buttonA: Bool = false
    @Published var buttonB: Bool = false
    @Published var buttonX: Bool = false
    @Published var buttonY: Bool = false
    
    // 어깨 버튼 상태
    @Published var buttonL1: Bool = false
    @Published var buttonR1: Bool = false
    
    // 트리거 값
    @Published var triggerL2: Float = 0.0
    @Published var triggerR2: Float = 0.0
    
    // D-패드 및 스틱 값
    @Published var dpadX: Float = 0.0
    @Published var dpadY: Float = 0.0
    @Published var leftStickX: Float = 0.0
    @Published var leftStickY: Float = 0.0
    @Published var rightStickX: Float = 0.0
    @Published var rightStickY: Float = 0.0
    
    // 기타 버튼
    @Published var buttonOptions: Bool = false
    @Published var buttonMenu: Bool = false
    @Published var buttonHome: Bool = false
    
    private let manager = GameControllerManager.shared
    
    init() {
        manager.addDelegate(self)
        manager.inputDelegate = self
        setupController()
        // Tester 탭을 처음 열기 전에 이미 연결된 컨트롤러가 있으면 연결 상태를 바로 반영한다.
        if manager.getControlelrInfo() != nil {
            didConnectedController()
        }
    }
    
    func setupController() {
        manager.setupControllerInputHandlers()
    }
    
    // MARK: - 버튼 상태 업데이트 함수
    
    private func updateFaceButtonState(button: FaceButton, pressed: Bool) {
        switch button {
        case .a:
            buttonA = pressed
        case .b:
            buttonB = pressed
        case .x:
            buttonX = pressed
        case .y:
            buttonY = pressed
        }
    }
    
    private func updateShoulderButtonState(button: ShoulderButton, pressed: Bool) {
        switch button {
        case .l1:
            buttonL1 = pressed
        case .r1:
            buttonR1 = pressed
        }
    }
    
    private func updateTriggerValue(button: TriggerButton, value: Float) {
        switch button {
        case .l2:
            triggerL2 = value
        case .r2:
            triggerR2 = value
        }
    }
    
    private func updateAuxiliaryButtonState(button: AuxiliaryButton, pressed: Bool) {
        switch button {
        case .options:
            buttonOptions = pressed
        case .menu:
            buttonMenu = pressed
        case .home:
            buttonHome = pressed
        }
    }
    
    private func resetAllButtonStates() {
        // 버튼 초기화
        buttonA = false
        buttonB = false
        buttonX = false
        buttonY = false
        buttonL1 = false
        buttonR1 = false
        triggerL2 = 0.0
        triggerR2 = 0.0
        dpadX = 0.0
        dpadY = 0.0
        leftStickX = 0.0
        leftStickY = 0.0
        rightStickX = 0.0
        rightStickY = 0.0
        buttonOptions = false
        buttonMenu = false
        buttonHome = false
    }
}

// MARK: GameControllerDelegate Method
extension TesterModel: GameControllerDelegate {
    func didConnectedController() {
        isConnected = true
        if let controller = manager.getControlelrInfo() {
            vendorName = controller.vendorName
            batteryLevel = controller.batteryLevel
        }
    }
    
    func didDisConnectedController() {
        isConnected = false
        resetAllButtonStates()
    }
}

// MARK: ControllerInputDelegate Method
extension TesterModel: ControllerInputDelegate {
    func didUpdateControllerInput(input: ControllerInput) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch input {
            case .faceButton(let button, let pressed):
                self.updateFaceButtonState(button: button, pressed: pressed)
                
            case .shoulder(let button, let pressed):
                self.updateShoulderButtonState(button: button, pressed: pressed)
                
            case .trigger(let button, let value):
                self.updateTriggerValue(button: button, value: value)
                
            case .dpad(let x, let y):
                self.dpadX = x
                self.dpadY = y
                
            case .thumbstick(let x, let y, let isLeft):
                if isLeft {
                    self.leftStickX = x
                    self.leftStickY = y
                } else {
                    self.rightStickX = x
                    self.rightStickY = y
                }
                
            case .auxiliary(let button, let pressed):
                self.updateAuxiliaryButtonState(button: button, pressed: pressed)
                
            default:
                break
            }
        }
    }
}
