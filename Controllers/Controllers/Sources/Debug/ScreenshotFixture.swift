//
//  ScreenshotFixture.swift
//  Controllers
//
//  DEBUG 빌드에서 실행 인자로 화면 상태를 만들어 스크린샷을 찍는다.
//  시뮬레이터에는 컨트롤러를 연결할 수 없어서, 연결된 상태를 흉내 낼 때 쓴다.
//
//  xcrun simctl launch <UDID> com.arex.achaCharge -ACScreenshot YES \
//      -ACMockBattery 0.42 -ACMockCharging YES -ACMockVendor "DualSense Wireless Controller" \
//      -ACTab controller|tester|setting -ACPaywall YES
//

#if DEBUG
import Foundation
import ControllerKit

enum ScreenshotFixture {
    /// 실행 인자는 UserDefaults 의 argument 도메인으로 들어온다.
    private static let arguments = UserDefaults.standard

    /// 켜져 있으면 시작 흐름(알림 권한·광고 동의·ATT·광고·Pro 팝업)을 건너뛴다.
    static var isEnabled: Bool {
        arguments.bool(forKey: "ACScreenshot")
    }

    /// `-ACMockBattery` 를 주면 그 잔량으로 컨트롤러가 연결된 것처럼 보인다. 없으면 미연결 상태다.
    /// 음수(-1)면 배터리 정보를 주지 않는 컨트롤러다.
    /// argument 도메인은 `-1` 을 값이 아닌 키로 읽어서, 이 값만 실행 인자에서 직접 꺼낸다.
    static var mockController: MockController? {
        let launchArguments = ProcessInfo.processInfo.arguments
        guard isEnabled,
              let index = launchArguments.firstIndex(of: "-ACMockBattery"),
              index + 1 < launchArguments.count,
              let level = Float(launchArguments[index + 1]) else { return nil }
        return MockController(batteryLevel: max(level, 0),
                              hasBatteryInfo: level >= 0,
                              isCharging: arguments.bool(forKey: "ACMockCharging"),
                              vendorName: arguments.string(forKey: "ACMockVendor") ?? "DualSense Wireless Controller")
    }

    /// 시작 탭: controller, tester, setting
    static var initialTab: String? {
        isEnabled ? arguments.string(forKey: "ACTab") : nil
    }

    /// 켜져 있으면 실행하자마자 구매 화면을 띄운다.
    static var showsPaywall: Bool {
        isEnabled && arguments.bool(forKey: "ACPaywall")
    }

    struct MockController {
        let batteryLevel: Float
        let hasBatteryInfo: Bool
        let isCharging: Bool
        let vendorName: String
    }

    /// 위젯도 같은 상태를 그리도록 App Group 에 쓰고 타임라인을 다시 읽게 한다.
    static func writeWidgetState() {
        guard let mock = mockController else {
            WidgetSharedState.save(isConnected: false)
            return
        }
        let state: BatteryState = !mock.hasBatteryInfo ? .unknown : (mock.isCharging ? .charging : .discharging)
        WidgetSharedState.save(isConnected: true, batteryLevel: mock.batteryLevel,
                               batteryState: state.rawValue, vendorName: mock.vendorName)
    }
}
#endif
