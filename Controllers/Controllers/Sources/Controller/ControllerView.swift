//
//  ControllerView.swift
//  Controllers
//
//  Created by 강동영 on 5/20/24.
//

import SwiftUI
import ControllerKit

struct ControllerView: View {
    @StateObject private var model = ControllerModel()

    var body: some View {
        Group {
            if model.isConnected {
                connectedView
            } else {
                ConnectionGuideView(onRefresh: onRefresh)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            model.updateControllerInfo()
        }
    }

    /// 링 지름은 가용 영역에 맞춘다. 아래 글자 자리를 남기려고 높이는 덜 쓴다.
    private var connectedView: some View {
        GeometryReader { proxy in
            let diameter = min(min(proxy.size.width, 500) * 0.7, proxy.size.height * 0.55, 360)
            ScrollView {
                VStack(spacing: 16) {
                    ZStack {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: diameter * 0.45)
                            .foregroundColor(.primary)

                        if model.hasBatteryInfo {
                            ProgressBarView(
                                progress: $model.batteryLevel,
                                isAnimating: true,
                                lineWidth: max(diameter * 0.03, 6)
                            )
                        }
                    }
                    // 링이 없으면 아이콘 높이만큼만 차지한다.
                    .frame(width: diameter, height: model.hasBatteryInfo ? diameter : diameter * 0.5)

                    if model.hasBatteryInfo {
                        HStack(spacing: 6) {
                            Text("\(Int((model.batteryLevel) * 100)) %")
                            if model.isCharging {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.green)
                                    .accessibilityLabel("Charging".localized)
                            }
                        }
                        .font(.largeTitle.bold())
                    } else {
                        Text("No Battery Info".localized)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                    }

                    Text(model.vendorName)
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    if !model.hasBatteryInfo {
                        Text("Connect Guide Support Note".localized)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: onRefresh) {
                        Label("Refresh".localized, systemImage: "arrow.clockwise")
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
                .padding()
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
    }

    /// 새로고침 버튼 액션
    private func onRefresh() {
        model.updateControllerInfo()
    }
}


@available(iOS 17.0, *)
#Preview {
    ControllerView()
}

