//
//  ControllersWidget.swift
//  ControllersWidget
//
//  Created by 강동영 on 2023/06/07.
//

import WidgetKit
import SwiftUI
import ControllerKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ControllerEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (ControllerEntry) -> ()) {
        // 위젯 갤러리에서는 실제 상태 대신 샘플을 보여 준다.
        completion(context.isPreview ? .sample : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ControllerEntry>) -> ()) {
        // 상태가 바뀌면 앱이 타임라인을 다시 읽게 하므로(WidgetSharedState) 여기서는 30분마다 다시 확인만 한다.
        let entry = currentEntry()
        completion(Timeline(entries: [entry], policy: .after(entry.date.addingTimeInterval(30 * 60))))
    }

    /// 위젯 프로세스에서 컨트롤러를 직접 읽을 수 있으면 그 값을, 아니면 앱이 App Group 에 남긴 값을 쓴다.
    private func currentEntry() -> ControllerEntry {
        let defaults = UserDefaults.shared
        let updated = defaults.double(forKey: StringKey.LAST_UPDATED)
        var entry = ControllerEntry(date: Date(),
                                    isConnected: defaults.bool(forKey: StringKey.CONTROLLER_CONNECTED),
                                    batteryLevel: defaults.float(forKey: StringKey.BATTERY_LEVEL),
                                    isCharging: defaults.integer(forKey: StringKey.BATTERY_STATE) == BatteryState.charging.rawValue,
                                    vendorName: defaults.string(forKey: StringKey.VENDOR_NAME),
                                    lastUpdated: updated > 0 ? Date(timeIntervalSince1970: updated) : nil)
        if let info = GameControllerManager.shared.getBatteryInfo(), info.state != BatteryState.unknown.rawValue {
            entry.isConnected = true
            entry.batteryLevel = info.level
            entry.isCharging = info.state == BatteryState.charging.rawValue
            entry.lastUpdated = entry.date
        }
        return entry
    }
}

struct ControllerEntry: TimelineEntry {
    let date: Date
    var isConnected: Bool
    var batteryLevel: Float
    var isCharging: Bool
    var vendorName: String?
    var lastUpdated: Date?

    static var sample: ControllerEntry {
        ControllerEntry(date: Date(), isConnected: true, batteryLevel: 0.76, isCharging: false,
                        vendorName: "DualSense Wireless Controller", lastUpdated: Date())
    }

    var percentText: String {
        "\(Int(batteryLevel * 100))%"
    }

    var nameText: Text {
        if let vendorName, !vendorName.isEmpty { return Text(verbatim: vendorName) }
        return Text("widget.controller")
    }

    /// "5분 전 갱신"
    var updatedText: Text? {
        lastUpdated.map { Text("widget.updated \(Text($0, style: .relative))") }
    }

    /// 미연결일 때 마지막으로 알던 잔량 "마지막: 42%"
    var lastLevelText: Text? {
        lastUpdated == nil ? nil : Text("widget.last \(percentText)")
    }
}

// MARK: - Views

struct ControllersWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ControllerEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { Color(UIColor.systemBackground) }
        } else if family == .systemSmall || family == .systemMedium {
            content.padding()
        } else {
            content
        }
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            if #available(iOS 16.0, *) {
                AccessoryWidgetView(entry: entry)
            }
        }
    }
}

/// 잔량 링과 가운데 퍼센트. 미연결이면 흐린 컨트롤러 아이콘만 그린다.
private struct BatteryRingView: View {
    let entry: ControllerEntry

    var body: some View {
        ZStack {
            ProgressBar(progress: entry.isConnected ? entry.batteryLevel : 0, lineWidth: 8, color: color)
            if entry.isConnected {
                VStack(spacing: 0) {
                    Image(systemName: entry.isCharging ? "bolt.fill" : "gamecontroller.fill")
                        .font(.caption)
                    Text(verbatim: entry.percentText)
                        .font(.title2.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            } else {
                Image(systemName: "gamecontroller")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }

    /// 충전 알림 기준값 이하면 빨간 링으로 보여 준다.
    private var color: Color {
        guard entry.isConnected else { return .gray }
        return entry.batteryLevel * 100 <= Float(UserDefaults.shared.batteryNotificationThreshold) ? .red : .green
    }
}

private struct SmallWidgetView: View {
    let entry: ControllerEntry

    var body: some View {
        VStack(spacing: 6) {
            BatteryRingView(entry: entry)
                .frame(width: 84, height: 84)
            if entry.isConnected {
                entry.updatedText?
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("widget.notConnected")
                    .font(.caption.bold())
                entry.lastLevelText?
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

private struct MediumWidgetView: View {
    let entry: ControllerEntry

    var body: some View {
        HStack(spacing: 16) {
            BatteryRingView(entry: entry)
                .frame(width: 100, height: 100)
            VStack(alignment: .leading, spacing: 4) {
                entry.nameText
                    .font(.headline)
                if entry.isConnected {
                    Text(verbatim: entry.percentText)
                        .font(.largeTitle.bold())
                    Group {
                        if entry.isCharging {
                            Label("widget.charging", systemImage: "bolt.fill")
                        } else {
                            Text("widget.notCharging")
                        }
                    }
                    .font(.subheadline)
                } else {
                    Text("widget.notConnected")
                        .font(.title3.bold())
                    entry.lastLevelText?
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                entry.updatedText?
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)
            Spacer(minLength: 0)
        }
    }
}

@available(iOS 16.0, *)
private struct AccessoryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ControllerEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        default:
            inline
        }
    }

    @ViewBuilder private var circular: some View {
        if entry.isConnected {
            Gauge(value: Double(entry.batteryLevel)) {
                Image(systemName: "gamecontroller.fill")
            } currentValueLabel: {
                VStack(spacing: 0) {
                    if entry.isCharging {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 9))
                    }
                    Text(verbatim: entry.percentText)
                        .minimumScaleFactor(0.5)
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "gamecontroller")
                    Text(verbatim: "—")
                }
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label { entry.nameText } icon: { Image(systemName: "gamecontroller.fill") }
                .font(.headline)
            if entry.isConnected {
                HStack(spacing: 2) {
                    Text(verbatim: entry.percentText)
                    if entry.isCharging {
                        Image(systemName: "bolt.fill")
                    }
                }
                Gauge(value: Double(entry.batteryLevel)) { EmptyView() }
                    .gaugeStyle(.accessoryLinearCapacity)
            } else {
                Text("widget.notConnected")
                entry.lastLevelText?
                    .foregroundColor(.secondary)
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var inline: some View {
        if entry.isConnected {
            Label {
                entry.isCharging
                    ? Text(verbatim: entry.percentText) + Text(Image(systemName: "bolt.fill"))
                    : Text(verbatim: entry.percentText)
            } icon: {
                Image(systemName: "gamecontroller.fill")
            }
        } else {
            Label("widget.notConnected", systemImage: "gamecontroller")
        }
    }
}

struct ControllersWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: StringKey.WIDGET_KIND, provider: Provider()) { entry in
            ControllersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget.name")
        .description("widget.description")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOS 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline]
        }
        return [.systemSmall, .systemMedium]
    }
}

struct ControllersWidget_Previews: PreviewProvider {
    static var previews: some View {
        ControllersWidgetEntryView(entry: .sample)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
