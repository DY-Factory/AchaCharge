//
//  ControllerInput.swift
//  ControllerKit
//
//  Created by 강동영 on 5/27/25.
//


public enum ControllerInput: Equatable {
    case dpad(x: Float, y: Float)
    case thumbstick(x: Float, y: Float, isLeft: Bool)
    case touchpad(x: Float, y: Float)
    case faceButton(button: FaceButton, pressed: Bool)
    case shoulder(button: ShoulderButton, pressed: Bool)
    case trigger(button: TriggerButton, value: Float)
    case auxiliary(button: AuxiliaryButton, pressed: Bool)
    
    public static func == (lhs: ControllerInput, rhs: ControllerInput) -> Bool {
        switch (lhs, rhs) {
        case let (.dpad(x1, y1), .dpad(x2, y2)):
            return x1 == x2 && y1 == y2
        case let (.thumbstick(x1, y1, isLeft1), .thumbstick(x2, y2, isLeft2)):
            return x1 == x2 && y1 == y2 && isLeft1 == isLeft2
        case let (.touchpad(x1, y1), .touchpad(x2, y2)):
            return x1 == x2 && y1 == y2
        case let (.faceButton(button1, pressed1), .faceButton(button2, pressed2)):
            return button1 == button2 && pressed1 == pressed2
        case let (.shoulder(button1, pressed1), .shoulder(button2, pressed2)):
            return button1 == button2 && pressed1 == pressed2
        case let (.trigger(button1, value1), .trigger(button2, value2)):
            return button1 == button2 && value1 == value2
        case let (.auxiliary(button1, pressed1), .auxiliary(button2, pressed2)):
            return button1 == button2 && pressed1 == pressed2
        default:
            return false
        }
    }
}

public enum FaceButton: String {
    case a, b, x, y
}

public enum ShoulderButton: String {
    case l1, r1
}

public enum TriggerButton: String {
    case l2, r2
}

public enum AuxiliaryButton: String {
    case options, menu, home
}
