# ARCHITECTURE.md

> AchaCharge의 아키텍처 의사결정 기록(ADR-lite). "왜 이렇게 했는지"와 "어떤 트레이드오프를 받아들였는지"를 명문화합니다. 새 결정사항이 생기면 "결정 #N" 형식으로 아래에 추가하세요.

## 한눈에 보기

| 항목 | 선택 | 위치/근거 |
|---|---|---|
| UI 프레임워크 | UIKit (메인) + SwiftUI (위젯) | [AppDelegate.swift](Controllers/Controllers/Applications/AppDelegate.swift), [ControllersWidget.swift](Controllers/ControllersWidget/ControllersWidget.swift) |
| 네비게이션 | TabBarController + 탭별 NavigationController | [SceneDelegate.swift:105-126](Controllers/Controllers/Applications/SceneDelegate.swift) |
| 상태 관리 | `didSet` + 싱글톤 Manager + `NotificationCenter` | [ViewController.swift:87-95](Controllers/Controllers/Sources/Controller/ViewController.swift) |
| DI | 수동 주입 (SceneDelegate 조립) + 싱글톤 | [SceneDelegate.swift:99-127](Controllers/Controllers/Applications/SceneDelegate.swift) |
| 모듈 구조 | 단일 .xcodeproj / 3 타깃 | `Controllers.xcodeproj` |
| 영속화 | `UserDefaults` + App Group만 | [Extensions/UserDefaults+.swift:12](Controllers/Controllers/Sources/Extensions/UserDefaults+.swift) |
| IAP | StoreKit 1 (`SKPaymentQueue`) | [StoreKitManager.swift](Controllers/Controllers/Sources/Models/StoreKitManager.swift) |
| 위젯 IPC | App Group `UserDefaults` 단방향 | [ControllersWidget.swift:16,26,35,52](Controllers/ControllersWidget/ControllersWidget.swift) |
| 컨트롤러 페어링 | `GameController` 프레임워크 | [GameControllerManager.swift:9](Controllers/Controllers/Sources/Models/GameControllerManager.swift) |

---

## 결정 #1 — UI 프레임워크: UIKit (메인) + SwiftUI (위젯)

**결정**: 메인 앱은 UIKit, 위젯은 SwiftUI.

**근거**:
- iOS 14 deployment target — 초기 개발 시점 SwiftUI 성숙도 부족
- WidgetKit은 SwiftUI 전용이라 위젯 타깃은 강제로 SwiftUI

**트레이드오프**:
- 두 UI 프레임워크를 한 코드베이스에서 유지 → 컨벤션·테마·컴포넌트 중복 우려
- 신규 iOS API(@Observable, NavigationStack 등) 사용 불가

**현재 상태**: SwiftUI 전환이 `develop`에 머지됨 (#9, 2025-05). 메인 앱은 SwiftUI, 설정 화면만 UIKit(`SettingViewRepresentable`). 1.1.0부터 최소 iOS 15. 본 결정과 결정 #2, #3 재작성 필요.

**참고**:
- [AppDelegate.swift:8](Controllers/Controllers/Applications/AppDelegate.swift)
- [MainTabBarController.swift:10](Controllers/Controllers/Sources/MainTabBarController.swift)
- [ControllersWidget.swift:9](Controllers/ControllersWidget/ControllersWidget.swift)

---

## 결정 #2 — 네비게이션: TabBar + 탭별 NavigationController

**결정**: `MainTabBarController`(UITabBarController) 안에 각 탭마다 `UINavigationController`를 둔다. 별도의 Coordinator 패턴은 도입하지 않는다.

**구조**:
- 탭 정의: [MainTabBarController.swift:16-24](Controllers/Controllers/Sources/MainTabBarController.swift)의 `TabType` enum (`controlelr`, `setting`)
- 조립: [SceneDelegate.swift:105-126](Controllers/Controllers/Applications/SceneDelegate.swift)의 `configureTabBarController()`

**근거**:
- 화면 수 2개 + push 깊이 얕음 → Coordinator 도입은 과설계
- iOS 표준 패턴이라 신규 참여자 학습 비용 낮음

**트레이드오프**:
- 화면이 늘어나면 `TabType` enum이 비대해질 수 있음
- A → B → A 같은 cross-tab navigation은 직접 코드 작성 필요

**알려진 부채**: `TabType.controlelr` 오타 (정상 표기: `controller`). 별도 리팩토링 작업으로 분리.

---

## 결정 #3 — 상태 관리: `didSet` + 싱글톤 Manager + `NotificationCenter`

**결정**: ViewController 내부 상태는 프로퍼티 + `didSet` 옵저버로 UI 동기화. 전역 도메인 상태는 싱글톤 Manager가 보유하고 `NotificationCenter`로 broadcast.

**예시**:
```swift
// ViewController.swift:87-95
private var isConnected: Bool = false {
    didSet {
        loadingView.isHidden = isConnected
        circularProgressBarView.isHidden = !isConnected
        UserDefaults.shared.setValue(isConnected, forKey: StringKey.CONTROLLER_CONNECTED)
    }
}
```

```swift
// GameControllerManager.swift:23-54
func addDidConnect(observer: Any, selector: Selector) {
    NotificationCenter.default.addObserver(...)
}
```

**근거**:
- 도메인 상태가 매우 단순 (배터리 레벨 1개 + 연결 여부 1개)
- Combine·MVVM 도입은 학습 비용 대비 이득 작음
- GameController 프레임워크가 이미 `NotificationCenter` 기반 이벤트를 발행 → 자연스러운 매칭

**트레이드오프**:
- `didSet` 옵저버 체인이 길어지면 디버깅 어려움
- 비동기 흐름 합성이 필요해지면 Combine/async 도입 검토 필요
- 단위 테스트 시 싱글톤 mocking이 까다로움

---

## 결정 #4 — 의존성 주입: 수동 주입 + 싱글톤

**결정**: 별도 DI 컨테이너 없이 `SceneDelegate`에서 수동 조립. 전역 의존성은 싱글톤(`GameControllerManager.shared`)으로 노출.

**조립 지점**: [SceneDelegate.swift:99-127](Controllers/Controllers/Applications/SceneDelegate.swift)

**근거**:
- 타입 수 적음 → 컨테이너 오버헤드 불필요
- iOS 14에서 사용 가능한 무거운 외부 DI 라이브러리(Swinject 등) 회피

**트레이드오프**:
- 의존성 그래프가 코드 곳곳에 흩어짐 → 신규 참여자가 한눈에 파악 어려움
- 싱글톤은 테스트 격리에 불리

**도입 기준 (향후)**: Manager 수가 5개를 넘거나 테스트 커버리지 확대 시 DI 패턴 재검토.

---

## 결정 #5 — 모듈 구조: 단일 .xcodeproj / 3 타깃

**결정**: Tuist·SPM 멀티 모듈 미사용. 하나의 `Controllers.xcodeproj`에 다음 3개 타깃을 둔다.

| 타깃 | 설명 |
|---|---|
| `Controllers` | iOS 메인 앱 |
| `ControllersWidget` | 홈 화면 위젯 |
| `ControllersTests` | 단위 테스트 |

**근거**:
- 코드 규모가 작아 모듈 분리 이득 < 빌드 설정 복잡도 증가 비용
- 외부 의존성이 없어 빌드 시간이 짧음

**트레이드오프**:
- macOS 타깃 추가 시(`Feature/macOSTarget`) 공유 코드 분리 필요해질 수 있음
- 향후 모듈화 시점에 마이그레이션 비용 발생

**과거 흔적**: 커밋 `30e02ec`에 "ControlerKit add to dependency" 기록 — 모듈화 시도가 있었으나 현재 코드에는 미반영.

---

## 결정 #6 — 데이터 영속화: `UserDefaults` + App Group만 사용

**결정**: 영속 저장은 App Group `UserDefaults`(`group.arex.achaCharge`)로 한정. CoreData·Realm·Keychain 미도입.

**구현**: [Extensions/UserDefaults+.swift:12](Controllers/Controllers/Sources/Extensions/UserDefaults+.swift)

```swift
extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = "group.arex.achaCharge"
        return UserDefaults(suiteName: appGroupId)!
    }
}
```

**저장하는 데이터**:
- `StringKey.BATTERY_LEVEL`: 배터리 잔량(Float)
- `StringKey.CONTROLLER_CONNECTED`: 연결 여부(Bool)

**근거**:
- 저장 데이터가 두 개의 원시 값 → CoreData·Realm은 과설계
- App Group을 쓰면 위젯과 자동 공유 (결정 #8 참고)

**트레이드오프**:
- 복잡한 객체 그래프·관계·쿼리 불가능
- 민감 정보 저장 시 Keychain 별도 도입 필요 (현재 민감 정보 미저장)

**재검토 기준**: 구독 영수증·결제 기록 등 보안이 필요한 데이터가 추가되면 Keychain 도입.

---

## 결정 #7 — IAP: StoreKit 1 (`SKPaymentQueue`)

**결정**: StoreKit 1 API(`SKProductsRequest`, `SKPaymentQueue`, `SKPaymentTransactionObserver`) 사용. StoreKit 2 미채택.

**핵심 클래스**:
- [StoreKitManager.swift](Controllers/Controllers/Sources/Models/StoreKitManager.swift) — 상품 조회·결제 요청
- [StoreObserver.swift](Controllers/Controllers/Sources/Models/StoreObserver.swift) — 트랜잭션 옵저버
- [AppDelegate.swift:66-68](Controllers/Controllers/Applications/AppDelegate.swift)의 `addStoreKitQueue()` — 앱 시작 시 옵저버 등록

**상품 ID**: `com.Arex.Controller.month` (월 구독) — [ProductIDs.plist](Controllers/Controllers/ProductIDs.plist)

**근거**:
- iOS 14 deployment target → StoreKit 2(iOS 15+) 사용 불가 (1.1.0에서 iOS 15로 상향되어 이 제약은 해소됨)
- 구매·복원·트랜잭션 완료는 SwiftyStoreKit(StoreKit 1 래퍼)로 처리

**트레이드오프**:
- `async/await` 기반 StoreKit 2 대비 콜백/delegate 패턴이 장황함
- 영수증 검증을 직접 구현해야 함 (`hotfix/1.0.12-iapverify` 브랜치에서 진행 중)

**재검토 기준**: deployment target이 iOS 15 이상으로 상향되면 StoreKit 2 마이그레이션 검토. → 1.1.0에서 충족됨. 마이그레이션은 별도 작업으로 미정.

---

## 결정 #8 — 위젯 IPC: App Group `UserDefaults` 단방향(앱 → 위젯)

**결정**: 앱과 위젯의 데이터 공유는 App Group `UserDefaults` 하나만 사용. 위젯 → 앱 통신, Push, Local Notification은 사용하지 않는다.

**위젯 측 읽기**: [ControllersWidget.swift:16,26,35,52](Controllers/ControllersWidget/ControllersWidget.swift)
```swift
let level = UserDefaults.shared.value(forKey: StringKey.BATTERY_LEVEL) as? Float
let isConnected = UserDefaults.shared.value(forKey: StringKey.CONTROLLER_CONNECTED) as? Bool
```

**근거**:
- 공유 데이터가 단순 두 값뿐 → 가장 가벼운 IPC 메커니즘 선택
- 위젯 갱신은 `TimelineProvider`가 주기적으로 폴링하므로 push 불필요

**제약**:
- 위젯이 직접 GameController에 접근할 수 없음 → 앱이 백그라운드에서 상태 업데이트 필수
- 백그라운드 갱신은 `BGTaskScheduler` (`com.controller.battery`)로 처리

**과거 흔적**: 커밋 `ba362d5` "위젯에서 Push 발송하는 부분 제거" — 이전에 위젯이 로컬 노티를 보내던 구조를 제거. **다시 도입하지 말 것.**

---

## 결정 #9 — 컨트롤러 페어링: `GameController` 프레임워크

**결정**: Sony DualSense를 비롯한 게임 컨트롤러 연결은 Apple `GameController` 프레임워크가 자동 처리하도록 위임. AccessorySetupKit·CoreBluetooth 직접 사용 안 함.

**구현**: [GameControllerManager.swift:9](Controllers/Controllers/Sources/Models/GameControllerManager.swift)
```swift
import GameController

final class GameControllerManager {
    static let shared = GameControllerManager.init()
    // GCController.controllers() + .GCControllerDidConnect 옵저버
}
```

**근거**:
- iOS가 시스템 설정에서 DualSense 페어링을 처리 → 앱이 BLE 핸드셰이크에 관여할 필요 없음
- GameController 프레임워크가 배터리 정보(`GCDeviceBattery`) API 제공

**트레이드오프**:
- 미지원 컨트롤러(Xbox 등)는 시스템이 매핑을 제공해야 동작
- 페어링 UX를 앱 내부에서 커스터마이징 불가

**향후 검토**: `Feature/AccesorySetupKit` 브랜치에서 macOS 컨텍스트나 더 풍부한 페어링 UX가 필요한 경우 AccessorySetupKit 도입 검토 중.

---

## 알려진 부채 / 향후 결정 후보

다음 항목은 의사결정이 보류되었거나 명시적으로 미해결인 상태입니다. 작업이 시작될 때 신규 "결정 #N"으로 승격하세요.

- **macOS 타깃 분기 전략**: 조건부 컴파일(`#if os(macOS)`) vs 별도 타깃 vs 공유 코드 모듈화 — `Feature/macOSTarget`에서 진행 중
- **AccessorySetupKit 도입 여부**: 결정 #9 참조
- **StoreKit 2 마이그레이션**: 결정 #7 참조 — 선결 조건(iOS 15 상향)은 1.1.0에서 충족
- **영수증 검증 책임자**: 클라이언트 단독 vs 서버 사이드 — `hotfix/1.0.12-iapverify`에서 진행 중
- **SwiftUI 전환 완료 후 컨벤션**: `refactor/#8-uikit--swiftui` 머지됨(#9) — 결정 #1, #2, #3 재작성 필요
- **Localization 도입**: DESIGN.md 로드맵 참조 — 도입 시 본 문서에도 결정 추가
- **폴더 일관성**: `Sources/Controller/` 안에 ViewController와 커스텀 뷰가 혼재 → 추후 `DesignSystem/`, `Scenes/` 등으로 분리 검토
- **enum 오타 `TabType.controlelr`** — 별도 리팩토링 작업

---

*기준 브랜치: `claude/happy-chaum-c8de73` · 최종 갱신: 2026-05-20*
