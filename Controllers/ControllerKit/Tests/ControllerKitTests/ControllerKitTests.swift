import XCTest
import GameController
@testable import ControllerKit

final class ControllerKitTests: XCTestCase {
    private final class SpyDelegate: GameControllerDelegate {
        var connected = 0
        var disconnected = 0
        func didConnectedController() { connected += 1 }
        func didDisConnectedController() { disconnected += 1 }
    }

    /// ControllerModel 과 TesterModel 처럼 두 구독자가 동시에 연결/해제 이벤트를 받아야 한다.
    func testAllDelegatesReceiveConnectionEvents() {
        let first = SpyDelegate()
        let second = SpyDelegate()
        GameControllerManager.shared.addDelegate(first)
        GameControllerManager.shared.addDelegate(second)

        NotificationCenter.default.post(name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.post(name: .GCControllerDidDisconnect, object: nil)

        XCTAssertEqual([first.connected, second.connected], [1, 1])
        XCTAssertEqual([first.disconnected, second.disconnected], [1, 1])
    }
}
