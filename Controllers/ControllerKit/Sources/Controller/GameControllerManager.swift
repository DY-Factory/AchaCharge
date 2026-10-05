//
//  GameControllerManager.swift
//  Controllers
//
//  Created by 강동영 on 2023/05/29.
//

import GameController

public protocol GameControllerDelegate: AnyObject {
    func didConnectedController()
    func didDisConnectedController()
}

public protocol ControllerInputDelegate: AnyObject {
    func didUpdateControllerInput(input: ControllerInput)
}

public final class GameControllerManager {
    public static let shared: GameControllerManager = .init()
    
    /// 연결/해제 이벤트 구독자. 여러 모델(Controller, Tester)이 동시에 받을 수 있도록 weak 컬렉션으로 보관한다.
    private let delegates = NSHashTable<AnyObject>.weakObjects()
    public weak var inputDelegate: ControllerInputDelegate?

    private init() {
        addObserver()
    }

    public func addDelegate(_ delegate: GameControllerDelegate) {
        delegates.add(delegate)
    }

    private var allDelegates: [GameControllerDelegate] {
        delegates.allObjects.compactMap { $0 as? GameControllerDelegate }
    }
    
    public var controllers: [GCController] = []
    private var current: Controller?
    
    public func getControlelrInfo() -> Controller? {
        return current
    }
    
    public func getBatteryInfo() -> (level: Float, state: Int)? {
        guard let current = current else { return nil }
        
        print("current gamepad's batteryLevel = \(current.batteryLevel)")
        print("current gamepad's batteryState = \(current.batteryState)")
        
        return (current.batteryLevel, current.batteryState.rawValue)
    }
    
    public func setupControllerInputHandlers() {
        guard let controller = GCController.current, let gamepad = controller.extendedGamepad else {
            return
        }
        
        // 전체 입력 핸들러 설정
        gamepad.valueChangedHandler = { [weak self] gamepad, element in
            guard let self = self else { return }
            if let input = self.mapControllerElement(element) {
                self.inputDelegate?.didUpdateControllerInput(input: input)
            }
        }
        
        // 개별 버튼 핸들러 설정
        setupFaceButtonHandlers(gamepad)
        setupShoulderButtonHandlers(gamepad)
        setupTriggerHandlers(gamepad)
        setupDirectionalInputHandlers(gamepad)
    }
    
    private func setupFaceButtonHandlers(_ gamepad: GCExtendedGamepad) {
        // A 버튼
        gamepad.buttonA.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .faceButton(button: .a, pressed: pressed))
        }
        
        // B 버튼
        gamepad.buttonB.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .faceButton(button: .b, pressed: pressed))
        }
        
        // X 버튼
        gamepad.buttonX.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .faceButton(button: .x, pressed: pressed))
        }
        
        // Y 버튼
        gamepad.buttonY.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .faceButton(button: .y, pressed: pressed))
        }
    }
    
    private func setupShoulderButtonHandlers(_ gamepad: GCExtendedGamepad) {
        // L1 버튼
        gamepad.leftShoulder.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .shoulder(button: .l1, pressed: pressed))
        }
        
        // R1 버튼
        gamepad.rightShoulder.pressedChangedHandler = { [weak self] _, value, pressed in
            self?.inputDelegate?.didUpdateControllerInput(input: .shoulder(button: .r1, pressed: pressed))
        }
    }
    
    private func setupTriggerHandlers(_ gamepad: GCExtendedGamepad) {
        // L2 트리거
        gamepad.leftTrigger.valueChangedHandler = { [weak self] _, value, _ in
            self?.inputDelegate?.didUpdateControllerInput(input: .trigger(button: .l2, value: value))
        }
        
        // R2 트리거
        gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, _ in
            self?.inputDelegate?.didUpdateControllerInput(input: .trigger(button: .r2, value: value))
        }
    }
    
    private func setupDirectionalInputHandlers(_ gamepad: GCExtendedGamepad) {
        // D-패드
        gamepad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.inputDelegate?.didUpdateControllerInput(input: .dpad(x: xValue, y: yValue))
        }
        
        // 왼쪽 스틱
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.inputDelegate?.didUpdateControllerInput(input: .thumbstick(x: xValue, y: yValue, isLeft: true))
        }
        
        // 오른쪽 스틱
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.inputDelegate?.didUpdateControllerInput(input: .thumbstick(x: xValue, y: yValue, isLeft: false))
        }
    }
    
    private func mapControllerElement(_ element: GCControllerElement) -> ControllerInput? {
        switch element {
        case let button as GCControllerButtonInput:
            return mapButtonInput(button)
            
        case let dpad as GCControllerDirectionPad:
            if let gamepad = GCController.current?.extendedGamepad {
                if dpad === gamepad.dpad {
                    return .dpad(x: dpad.xAxis.value, y: dpad.yAxis.value)
                } else if dpad === gamepad.leftThumbstick {
                    return .thumbstick(x: dpad.xAxis.value, y: dpad.yAxis.value, isLeft: true)
                } else if dpad === gamepad.rightThumbstick {
                    return .thumbstick(x: dpad.xAxis.value, y: dpad.yAxis.value, isLeft: false)
                }
            }
            return nil
            
        case let trigger as GCControllerAxisInput:
            if let gamepad = GCController.current?.extendedGamepad {
                if trigger === gamepad.leftTrigger {
                    return .trigger(button: .l2, value: trigger.value)
                } else if trigger === gamepad.rightTrigger {
                    return .trigger(button: .r2, value: trigger.value)
                }
            }
            return nil
            
        default:
            return nil
        }
    }
    
    private func mapButtonInput(_ button: GCControllerButtonInput) -> ControllerInput? {
        guard let gamepad = GCController.current?.extendedGamepad else { return nil }
        
        if button === gamepad.buttonA {
            return .faceButton(button: .a, pressed: button.isPressed)
        } else if button === gamepad.buttonB {
            return .faceButton(button: .b, pressed: button.isPressed)
        } else if button === gamepad.buttonX {
            return .faceButton(button: .x, pressed: button.isPressed)
        } else if button === gamepad.buttonY {
            return .faceButton(button: .y, pressed: button.isPressed)
        } else if button === gamepad.leftShoulder {
            return .shoulder(button: .l1, pressed: button.isPressed)
        } else if button === gamepad.rightShoulder {
            return .shoulder(button: .r1, pressed: button.isPressed)
        } else if button === gamepad.buttonMenu {
            return .auxiliary(button: .menu, pressed: button.isPressed)
        } else if button === gamepad.buttonOptions {
            return .auxiliary(button: .options, pressed: button.isPressed)
        } else if button === gamepad.buttonHome {
            return .auxiliary(button: .home, pressed: button.isPressed)
        }
        
        return nil
    }
    deinit {
        removeObserver()
    }
}

// MARK: - Private Method
extension GameControllerManager {
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didConnectedController),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDisConnectedController),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    @objc
    private func didConnectedController() {
        NSLog("Connected Game Controller !!)")
        if let controller = getCurrentController() {
            NSLog("Connected Controller's count: \(controller.controllerCount)")
            NSLog("current Controller's vendorName: \(controller.vendorName)")
            NSLog("current Controller's batteryLevel: \(controller.batteryLevel * 100)%")
            NSLog("current Controller's batteryState: \(controller.batteryState), \(controller.batteryState.description)")
            current = controller
            setupControllerInputHandlers()
        }
        
        allDelegates.forEach { $0.didConnectedController() }
    }
    
    private func getCurrentController() -> Controller? {
        guard let controller = GCController.current else {
            return nil
        }
        
        let count = GCController.controllers().count
        let batteryLevel = controller.battery?.batteryLevel ?? 0.0
        let rawValue = (controller.battery?.batteryState ?? .unknown).rawValue
        let state = BatteryState(rawValue: rawValue)
        let vendorName = controller.vendorName ?? "Game Controller"
        
        return Controller(controllerCount: count,
                          batteryLevel: batteryLevel,
                          batteryState: state ?? .unknown,
                          vendorName: vendorName)
    }
    
    @objc
    private func didDisConnectedController() {
        NSLog("Disconnected Game Controller !!)")
        // 남은 컨트롤러가 없으면 nil 이 되어, 해제 후 이전 컨트롤러 정보가 남지 않는다.
        current = getCurrentController()
        allDelegates.forEach { $0.didDisConnectedController() }
    }
}

// MARK: - User Interaction
extension GameControllerManager {}

public struct Controller {
    public let controllerCount: Int
    public let batteryLevel: Float
    public let batteryState: BatteryState
    public let vendorName: String
}

public enum BatteryState: Int, CustomStringConvertible {
    case unknown = -1
    case discharging = 0
    case charging = 1
    case full = 2
    
    public var description: String {
        switch self {
        case .discharging:
            "discharging"
        case .charging:
            "charging"
        case .full:
            "full"
        case .unknown:
            "unknown"
        }
    }
}

