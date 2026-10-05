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
        VStack {
            if !model.isConnected {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
            }

            Spacer()

            ZStack {
                Image(systemName: "gamecontroller.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 130)
                    .foregroundColor(.primary)

                if model.isConnected {
                    ProgressBarView(
                        progress: $model.batteryLevel,
                        isAnimating: true
                    )
                    .frame(width: 400, height: 400)
                }
            }

            Text(model.isConnected
                 ? "\(Int((model.batteryLevel) * 100)) %"
                 : "Not connected..".localized)
                .font(.system(size: 25, weight: .bold))
                .padding(.top, 36)

            Text(model.vendorName)
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 57)

            Button(action: onRefresh) {
                Label("Refresh".localized, systemImage: "arrow.clockwise")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.primary)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 1)
                    )
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            model.updateControllerInfo()
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

