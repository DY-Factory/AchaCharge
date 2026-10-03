//
//  TesterView.swift
//  Controllers
//
//  Created by 강동영 on 5/22/25.
//

import SwiftUI
import ControllerKit

struct TesterView: View {
    @StateObject private var model = TesterModel()
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // 상태 정보 표시
                connectionStatusView
                
                // 컨트롤러 레이아웃
                VStack {
                    ZStack {
                        HStack(spacing: 100) {
                            ControllerButton(systemName: "line.horizontal.3", isPressed: model.buttonOptions)
                            ControllerButton(systemName: "ellipsis", isPressed: model.buttonMenu)
                        }
                        
                        VStack {
                            // 트리거 버튼 (L2, R2)
                            HStack(spacing: 400) {
                                TriggerButtonView(systemName: "l2.button.roundedtop.horizontal.fill", value: model.triggerL2)
                                TriggerButtonView(systemName: "r2.button.roundedtop.horizontal.fill", value: model.triggerR2)
                            }
                            
                            
                            // 어깨 버튼 (L1, R1)
                            HStack(spacing: 400) {
                                ControllerButton(systemName: "l1.button.roundedbottom.horizontal.fill", isPressed: model.buttonL1)
                                ControllerButton(systemName: "r1.button.roundedbottom.horizontal.fill", isPressed: model.buttonR1)
                            }
                        }
                        
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    // offset 은 레이아웃에 반영되지 않아 스틱이 카드 밖(iOS 26 탭바 아래)으로 나갔음.
                    // 음수 spacing 으로 겹치게 배치해 카드 높이에 포함시킨다.
                    VStack(spacing: -50) {
                        // 중앙 영역
                        // D-패드·얼굴 버튼을 양 끝(L1/R1 아래)에 두고, 가운데 남는 폭에 스틱 + PS 버튼이 겹쳐 들어간다.
                        HStack {
                            // D-패드
                            DPadView(xValue: model.dpadX, yValue: model.dpadY)
                            Spacer()
                            // 얼굴 버튼
                            VStack(spacing: 0) {
                                ControllerButton(systemName: "triangle.circle", size: 60, isPressed: model.buttonY)
                                HStack(spacing: 50) {
                                    ControllerButton(systemName: "square.circle", size: 60, isPressed: model.buttonX)
                                    ControllerButton(systemName: "circle.circle", size: 60, isPressed: model.buttonB)
                                }
                                ControllerButton(systemName: "x.circle", size: 60, isPressed: model.buttonA)
                            }
                        }
                        .padding(.horizontal, 24)

                        // 하단 버튼
                        HStack(spacing: 24) {
                            // 왼쪽 스틱 (옵션)
                            ThumbstickView(direction: .left, xValue: model.leftStickX, yValue: model.leftStickY)
                            ControllerButton(systemName: "playstation.logo", size: 60, isPressed: model.buttonHome)
                            // 오른쪽 스틱 (옵션)
                            ThumbstickView(direction: .right, xValue: model.rightStickX, yValue: model.rightStickY)
                        }
                    }
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.8)))
                .shadow(radius: 5)
            }
            .padding()
        }
        .lockedOrientation(.landscape)
        .onAppear {
            model.setupController()
        }
    }
    
    // 연결 상태 뷰
    private var connectionStatusView: some View {
        HStack {
            // 연결 상태 표시
            HStack {
                Circle()
                    .fill(model.isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(model.isConnected ? "\(model.vendorName) 연결됨" : "컨트롤러 연결 안됨")
                    .font(.subheadline)
            }
            
            Spacer()
            
            // 배터리 상태 표시
            if model.isConnected {
                HStack(spacing: 4) {
                    Image(systemName: batteryIconName)
                        .foregroundColor(batteryColor)
                    Text("\(Int(model.batteryLevel * 100))%")
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }
    
    
}

// MARK: ViewBuilder Method
extension TesterView {
    
}

// MARK: Private Method
extension TesterView {
    // 배터리 아이콘 선택
    private var batteryIconName: String {
        let level = model.batteryLevel
        if level <= 0.1 {
            return "battery.0"
        } else if level <= 0.25 {
            return "battery.25"
        } else if level <= 0.5 {
            return "battery.50"
        } else if level <= 0.75 {
            return "battery.75"
        } else {
            return "battery.100"
        }
    }
    
    // 배터리 색상
    private var batteryColor: Color {
        let level = model.batteryLevel
        if level <= 0.2 {
            return .red
        } else if level <= 0.4 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    TesterView()
}

extension View {
    func lockedOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(OrientationModifier(orientation: orientation))
    }
}

struct OrientationModifier: ViewModifier {
    var orientation: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content
            .onAppear {
                lockOrientation(orientation)
            }
            .onDisappear {
                lockOrientation(.all) // 다른 화면에선 회전 허용
            }
    }

    private func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

