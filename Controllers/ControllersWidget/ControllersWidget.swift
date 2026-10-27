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
                                    hasBatteryInfo: defaults.integer(forKey: StringKey.BATTERY_STATE) != BatteryState.unknown.rawValue,
                                    vendorName: defaults.string(forKey: StringKey.VENDOR_NAME),
                                    lastUpdated: updated > 0 ? Date(timeIntervalSince1970: updated) : nil)
        if let info = GameControllerManager.shared.getBatteryInfo(), info.state != BatteryState.unknown.rawValue {
            entry.isConnected = true
            entry.batteryLevel = info.level
            entry.isCharging = info.state == BatteryState.charging.rawValue
            entry.hasBatteryInfo = true
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
    /// 배터리 상태가 unknown(-1)인 컨트롤러(가상 게임패드, 일부 비공식 컨트롤러)는 잔량을 믿을 수 없다. 0%라도 state 가 있으면 진짜 값이다.
    var hasBatteryInfo = true
    var vendorName: String?
    var lastUpdated: Date?

    static var sample: ControllerEntry {
        ControllerEntry(date: Date(), isConnected: true, batteryLevel: 0.76, isCharging: false,
                        vendorName: "DualSense Wireless Controller", lastUpdated: Date())
    }

    /// 잔량을 그려도 되는 상태
    var showsLevel: Bool { isConnected && hasBatteryInfo }

    var percentText: String {
        "\(Int(batteryLevel * 100))%"
    }

    var nameText: Text {
        if let vendorName, !vendorName.isEmpty { return Text(verbatim: vendorName) }
        return Text("widget.controller")
    }

    /// 좁은 곳(잠금 화면 직사각형)용 이름. "DualSense Wireless Controller" → "DualSense"
    var shortNameText: Text {
        guard let vendorName else { return nameText }
        let short = [" Wireless Controller", " Controller"].reduce(vendorName) { name, suffix in
            name.hasSuffix(suffix) ? String(name.dropLast(suffix.count)) : name
        }
        return short.isEmpty ? nameText : Text(verbatim: short)
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
        } else if family.isSystem {
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
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            if #available(iOS 15.0, *), family == .systemExtraLarge {
                LargeWidgetView(entry: entry)
            } else
            if #available(iOS 16.0, *) {
                AccessoryWidgetView(entry: entry)
            }
        }
    }
}

private extension WidgetFamily {
    var isSystem: Bool {
        if #available(iOS 15.0, *), self == .systemExtraLarge { return true }
        return self == .systemSmall || self == .systemMedium || self == .systemLarge
    }
}

/// 잔량 링과 가운데 퍼센트. 미연결이면 흐린 컨트롤러 아이콘만 그린다.
private struct BatteryRingView: View {
    let entry: ControllerEntry
    var lineWidth: CGFloat = 8
    var iconFont: Font = .caption
    var percentFont: Font = .title2.bold()

    var body: some View {
        ZStack {
            ProgressBar(progress: entry.showsLevel ? entry.batteryLevel : 0, lineWidth: lineWidth, color: color)
            if entry.showsLevel {
                VStack(spacing: 0) {
                    Image(systemName: entry.isCharging ? "bolt.fill" : "gamecontroller.fill")
                        .font(iconFont)
                    Text(verbatim: entry.percentText)
                        .font(percentFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            } else {
                Image(systemName: entry.isConnected ? "gamecontroller.fill" : "gamecontroller")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }

    /// 충전 알림 기준값 이하면 빨간 링으로 보여 준다.
    private var color: Color {
        guard entry.showsLevel else { return .gray }
        return entry.batteryLevel * 100 <= Float(UserDefaults.shared.batteryNotificationThreshold) ? .red : .green
    }
}

private struct SmallWidgetView: View {
    let entry: ControllerEntry

    var body: some View {
        VStack(spacing: 6) {
            BatteryRingView(entry: entry)
                .frame(width: 84, height: 84)
            if entry.showsLevel {
                entry.updatedText?
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if entry.isConnected {
                Text("widget.noBatteryInfo")
                    .font(.caption.bold())
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
                if entry.showsLevel {
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
                } else if entry.isConnected {
                    Text("widget.noBatteryInfo")
                        .font(.title3.bold())
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

/// large·extraLarge 공용. 큰 링 아래에 이름·상태·갱신 시각을 쌓는다.
private struct LargeWidgetView: View {
    let entry: ControllerEntry

    var body: some View {
        VStack(spacing: 12) {
            entry.nameText
                .font(.title3.bold())
            BatteryRingView(entry: entry, lineWidth: 16, iconFont: .title3, percentFont: .system(size: 44, weight: .bold))
                .frame(width: 190, height: 190)
            Group {
                if entry.showsLevel {
                    if entry.isCharging {
                        Label("widget.charging", systemImage: "bolt.fill")
                    } else {
                        Text("widget.notCharging")
                    }
                } else if entry.isConnected {
                    Text("widget.noBatteryInfo")
                } else {
                    Text("widget.notConnected")
                    entry.lastLevelText?
                        .foregroundColor(.secondary)
                }
            }
            .font(.headline)
            entry.updatedText?
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        if entry.showsLevel {
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
            Label { entry.shortNameText } icon: { Image(systemName: "gamecontroller.fill") }
                .font(.headline)
            if entry.showsLevel {
                HStack(spacing: 2) {
                    Text(verbatim: entry.percentText)
                    if entry.isCharging {
                        Image(systemName: "bolt.fill")
                    }
                }
                Gauge(value: Double(entry.batteryLevel)) { EmptyView() }
                    .gaugeStyle(.accessoryLinearCapacity)
            } else if entry.isConnected {
                Text("widget.noBatteryInfo")
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
        if entry.showsLevel {
            Label {
                entry.isCharging
                    ? Text(verbatim: entry.percentText) + Text(Image(systemName: "bolt.fill"))
                    : Text(verbatim: entry.percentText)
            } icon: {
                Image(systemName: "gamecontroller.fill")
            }
        } else if entry.isConnected {
            Label("widget.noBatteryInfo", systemImage: "gamecontroller.fill")
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
        var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
        if #available(iOS 15.0, *) { families.append(.systemExtraLarge) }
        if #available(iOS 16.0, *) { families += [.accessoryCircular, .accessoryRectangular, .accessoryInline] }
        return families
    }
}

struct ControllersWidget_Previews: PreviewProvider {
    static var previews: some View {
        ControllersWidgetEntryView(entry: .sample)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
