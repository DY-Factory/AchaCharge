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
                    // 이름은 bottom 진행 바 라벨에 한 번만 표시한다 (leading 은 폭이 좁아 잘림)
                    Image(systemName: "gamecontroller.fill")
                        .font(.title3)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        LiveActivityFormat.percentLabel(context.state)
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
                LiveActivityFormat.percentLabel(context.state)
                    .foregroundColor(LiveActivityFormat.batteryColor(context.state.batteryLevel))
            } minimal: {
                // 공간이 아이콘 하나뿐이라 충전 중에는 번개, 아니면 잔량 아이콘
                Image(systemName: context.state.batteryState == 1 ? "bolt.fill" : LiveActivityFormat.batteryIconName(for: context.state))
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
                    .minimumScaleFactor(0.7)

                ProgressView(value: Double(state.batteryLevel))
                    .tint(LiveActivityFormat.batteryColor(state.batteryLevel))
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Image(systemName: LiveActivityFormat.batteryIconName(for: state))
                LiveActivityFormat.percentLabel(state)
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

    /// "82%" 텍스트. 충전 중(batteryState == 1)이면 번개 아이콘을 붙인다.
    static func percentLabel(_ state: ControllerActivityAttributes.ContentState) -> Text {
        let text = Text(percentText(state.batteryLevel))
        return state.batteryState == 1 ? text + Text(" \(Image(systemName: "bolt.fill"))") : text
    }

    /// 배터리 잔량에 맞는 SF Symbol 이름을 반환한다.
    /// (충전 중 표시는 percentLabel 의 번개로 한다. battery.100.bolt 는 잔량과 무관하게 가득 찬 모양이라 쓰지 않음)
    static func batteryIconName(for state: ControllerActivityAttributes.ContentState) -> String {
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
