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
    func placeholder(in context: Context) -> SimpleEntry {
        if let info = GameControllerManager.shared.getBatteryInfo(), info.state != -1 {
            return SimpleEntry(date: Date(), batteryLevel: info.level)
        } else {
            let level = UserDefaults.shared.value(forKey: StringKey.BATTERY_LEVEL) as? Float
            return SimpleEntry(date: Date(), batteryLevel: level ?? 0.0)
        }
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if let info = GameControllerManager.shared.getBatteryInfo(), info.state != -1 {
            let entry = SimpleEntry(date: Date(), batteryLevel: info.level)
            completion(entry)
        } else {
            let level = UserDefaults.shared.value(forKey: StringKey.BATTERY_LEVEL) as? Float
            let entry = SimpleEntry(date: Date(), batteryLevel: level ?? 0.0)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let isConnected = UserDefaults.shared.value(forKey: StringKey.CONTROLLER_CONNECTED) as? Bool ?? false
        print("filter", #function, "isConnected: \(isConnected)")
        if isConnected {
            if let info = GameControllerManager.shared.getBatteryInfo(), info.state != -1 {
                let level = info.level
                
                let currentDate = Date()
                for _ in 0 ..< 25 {
                    let entryDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
                    let entry = SimpleEntry(date: entryDate, batteryLevel: level)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                print("filter", "entries.count: \(entries.count)")
                completion(timeline)
            } else {
                let level = (UserDefaults.shared.value(forKey: StringKey.BATTERY_LEVEL) as? Float) ?? 0
                
                let currentDate = Date()
                for _ in 0 ..< 25 {
                    let entryDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
                    let entry = SimpleEntry(date: entryDate, batteryLevel: level)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                print("filter", "entries.count: \(entries.count)")
                completion(timeline)
            }
        } else {
            let currentDate = Date()
            for _ in 0 ..< 25 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, batteryLevel: 0.0)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            print("filter", "entries.count: \(entries.count)")
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let batteryLevel: Float
}

struct ControllersWidgetEntryView : View {
    var entry: Provider.Entry
    let size: CGFloat = 100.0

    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "gamecontroller.fill")
                Text("\(Int(entry.batteryLevel * 100))%")
            }
            
            VStack {
                // 위젯은 onAppear 가 실행되지 않아 @State 로 갱신하면 항상 초기값(0.8)이 그려졌음 → 엔트리 값을 직접 사용
                ProgressBar(progress: .constant(entry.batteryLevel))
                    .frame(width: size, height: size)
                    .padding(40.0)
                
                Spacer()
            }
        }
    }
}

struct ControllersWidget: Widget {
    let kind: String = "ControllersWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ControllersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("연결 및 배터리 상태 확인")
        .description("배터리 상태를 확인하세요 !")
    }
}

struct ControllersWidget_Previews: PreviewProvider {
    static var previews: some View {
        ControllersWidgetEntryView(entry: SimpleEntry(date: Date(), batteryLevel: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
