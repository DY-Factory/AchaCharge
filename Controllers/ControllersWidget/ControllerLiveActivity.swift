//
//  ControllerLiveActivity.swift
//  ControllersWidget
//
//  잠금화면 및 Dynamic Island 에 게임 컨트롤러 배터리 상태를 표시하는 Live Activity.
//  iOS 16.1+ 에서만 동작한다.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct ControllerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ControllerActivityAttributes.self) { context in
            // 잠금화면 / 배너 표시
            LockScreenLiveActivityView(
                vendorName: context.attributes.vendorName,
                state: context.state
            )
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.6))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.vendorName)
                            .font(.caption)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "gamecontroller.fill")
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text(LiveActivityFormat.percentText(context.state.batteryLevel))
                            .font(.title3)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: LiveActivityFormat.batteryIconName(for: context.state))
                            .foregroundColor(LiveActivityFormat.batteryColor(context.state.batteryLevel))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: Double(context.state.batteryLevel)) {
                        Text(context.attributes.vendorName)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .tint(LiveActivityFormat.batteryColor(context.state.batteryLevel))
                }
            } compactLeading: {
                Image(systemName: "gamecontroller.fill")
            } compactTrailing: {
                Text(LiveActivityFormat.percentText(context.state.batteryLevel))
                    .foregroundColor(LiveActivityFormat.batteryColor(context.state.batteryLevel))
            } minimal: {
                Image(systemName: LiveActivityFormat.batteryIconName(for: context.state))
                    .foregroundColor(LiveActivityFormat.batteryColor(context.state.batteryLevel))
            }
        }
    }
}

// MARK: - 잠금화면 뷰
@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let vendorName: String
    let state: ControllerActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.title2)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 6) {
                Text(vendorName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                ProgressView(value: Double(state.batteryLevel))
                    .tint(LiveActivityFormat.batteryColor(state.batteryLevel))
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image(systemName: LiveActivityFormat.batteryIconName(for: state))
                Text(LiveActivityFormat.percentText(state.batteryLevel))
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundColor(LiveActivityFormat.batteryColor(state.batteryLevel))
        }
    }
}

// MARK: - 표시 포맷 헬퍼
@available(iOS 16.1, *)
enum LiveActivityFormat {
    /// 0.0 ~ 1.0 배터리 잔량을 "82%" 형태 문자열로 변환한다.
    static func percentText(_ level: Float) -> String {
        "\(Int(level * 100))%"
    }

    /// 배터리 잔량/상태에 맞는 SF Symbol 이름을 반환한다.
    static func batteryIconName(for state: ControllerActivityAttributes.ContentState) -> String {
        // batteryState == 1 (charging)
        if state.batteryState == 1 {
            return "battery.100.bolt"
        }
        switch state.batteryLevel {
        case ..<0.1:  return "battery.0"
        case ..<0.25: return "battery.25"
        case ..<0.5:  return "battery.50"
        case ..<0.75: return "battery.75"
        default:      return "battery.100"
        }
    }

    /// 배터리 잔량에 맞는 색상을 반환한다.
    static func batteryColor(_ level: Float) -> Color {
        switch level {
        case ..<0.2: return .red
        case ..<0.4: return .orange
        default:     return .green
        }
    }
}
