# ARCHITECTURE.md

> AchaCharge의 아키텍처 의사결정 기록(ADR-lite). "왜 이렇게 했는지"와 "어떤 트레이드오프를 받아들였는지"를 명문화합니다. 새 결정사항이 생기면 "결정 #N" 형식으로 아래에 추가하세요. 줄 번호는 쉽게 어긋나므로 파일·심볼 이름으로 참조합니다.

## 한눈에 보기

| 항목 | 선택 | 위치/근거 |
|---|---|---|
| UI 프레임워크 | SwiftUI (메인·위젯) + UIKit 일부 화면 | [MainTabView.swift](Controllers/Controllers/Sources/MainTabView.swift), [SettingViewController.swift](Controllers/Controllers/Sources/Setting/SettingViewController.swift) |
| 네비게이션 | SwiftUI `TabView` 3탭 | `MainTabView.TabType` |
| 상태 관리 | 화면별 `ObservableObject` + Manager delegate | [ControllerModel.swift](Controllers/Controllers/Sources/Controller/ControllerModel.swift), [TesterModel.swift](Controllers/Controllers/Sources/Tester/TesterModel.swift) |
| DI | 싱글톤 Manager, 컨테이너 없음 | `GameControllerManager.shared`, `StoreKitManager.shared`, `LiveActivityManager.shared` |
| 모듈 구조 | 단일 .xcodeproj / 4 타깃 + 로컬 SPM 패키지 `ControllerKit` | [ControllerKit/Package.swift](Controllers/ControllerKit/Package.swift) |
| 영속화 | `UserDefaults` (App Group + standard) | [UserDefaults+.swift](Controllers/Controllers/Sources/Extensions/UserDefaults+.swift) |
| IAP | 구매: SwiftyStoreKit / 구독 판정·복원·가격: StoreKit 2 | [StoreKitManager.swift](Controllers/Controllers/Sources/Models/StoreKitManager.swift), [IAPOnboardingViewController.swift](Controllers/Controllers/Sources/Setting/IAPOnboardingViewController.swift) |
| 위젯 IPC | App Group `UserDefaults` 단방향 | [ControllersWidget.swift](Controllers/ControllersWidget/ControllersWidget.swift) |
| 컨트롤러 페어링·입력 | `GameController` 프레임워크 (ControllerKit으로 래핑) | [GameControllerManager.swift](Controllers/ControllerKit/Sources/Controller/GameControllerManager.swift) |
| 백그라운드 알림 | `BGAppRefreshTask` + 로컬 알림 + 사용자 설정 기준값 | [FetchGameControllerOperation.swift](Controllers/Controllers/Sources/Models/FetchGameControllerOperation.swift) |
| 잠금화면 노출 | ActivityKit Live Activity (iOS 16.1+) | [LiveActivityManager.swift](Controllers/Controllers/Sources/Models/LiveActivityManager.swift) |
| 광고 이용권 | AdMob 보상형 광고 → 기기 안에서 시간제 Pro | [RewardedPassManager.swift](Controllers/Controllers/Sources/Models/RewardedPassManager.swift) |
| 비구독자 광고·Pro 유도 | 앱 오프닝 광고(복귀 시) + 컨트롤러 연결 시 Pro 팝업 | [AppOpenAdManager.swift](Controllers/Controllers/Sources/Models/AppOpenAdManager.swift), [ProPromotionManager.swift](Controllers/Controllers/Sources/Models/ProPromotionManager.swift) |

---

## 결정 #1 — UI 프레임워크: SwiftUI 메인 + UIKit 잔존 화면

**결정**: 메인 앱 UI는 SwiftUI로 작성한다. 기존 UIKit 화면(설정, 결제 안내)은 `UIViewControllerRepresentable`로 감싸 유지하며, 신규 화면은 SwiftUI로 작성한다.

**경과**:
- 초기: 메인 앱 UIKit + 위젯 SwiftUI (iOS 14 시점 SwiftUI 성숙도 부족, WidgetKit은 SwiftUI 전용)
- PR #9 (`refactor/#8-uikit--swiftui`)에서 메인/탭 화면을 SwiftUI로 전환, develop에 머지

**현재 구조**:
- `SceneDelegate`가 `UIHostingController(rootView: MainTabView())`를 루트로 설정
- SwiftUI: `ControllerView`, `TesterView`, `InfoView`, 위젯, Live Activity
- UIKit: `SettingViewController`(→ `SettingViewRepresentable`), `IAPOnboardingViewController`

**트레이드오프**:
- 최소 iOS 15 (1.1.0에서 14 → 15 상향) → `@Observable`(17+), `NavigationStack`(16+) 등은 사용 불가하거나 `#available` 가드 필요
- UIKit/SwiftUI 혼재로 스타일·컴포넌트가 중복됨 (DESIGN.md 참고)

---

## 결정 #2 — 네비게이션: SwiftUI `TabView` 3탭

**결정**: `MainTabView`의 `TabView` 하나로 화면을 나눈다. Coordinator, `NavigationView` 계층은 도입하지 않는다.

**구조**: `MainTabView.TabType` — `controlelr`(Controller) / `tester`(Tester) / `setting`(Setting). 탭 제목은 로컬라이즈 문자열, 아이콘은 SF Symbols.

**근거**:
- 화면이 3개이고 push 깊이가 거의 없음 → 별도 네비게이션 계층은 과설계
- 설정 화면 내부의 하위 화면(정보, 결제 안내)은 UIKit present로 처리

**트레이드오프**:
- 탭이 늘어나면 `TabType` switch가 커짐
- cross-tab 이동이 필요해지면 선택 상태(`selection`)를 바인딩으로 끌어올려야 함

**알려진 부채**: `TabType.controlelr` 오타 (정상 표기: `controller`). 별도 리팩토링 작업으로 분리.

---

## 결정 #3 — 상태 관리: 화면별 `ObservableObject` + Manager delegate

**결정**: 화면마다 `ObservableObject` 모델을 두고 `@Published`로 UI를 갱신한다. 컨트롤러 이벤트는 `GameControllerManager`가 delegate로 모델에 전달한다.

**흐름**:
```
GCController 알림 (.GCControllerDidConnect / DidDisconnect)
  → GameControllerManager (NotificationCenter 구독)
  → GameControllerDelegate (addDelegate, 다중) / ControllerInputDelegate (단일)
  → ControllerModel / TesterModel (@Published)
  → SwiftUI View (@StateObject)
```

**근거**:
- 도메인 상태가 단순함 (연결 여부, 배터리, 제조사 이름, 버튼 입력)
- 최소 iOS 15 → `@Observable`(iOS 17+) 불가, `ObservableObject`가 가장 가벼운 선택
- 별도 MVVM 계층이나 Combine 파이프라인은 이득이 작음

**트레이드오프**:
- 연결/해제 이벤트는 `addDelegate(_:)`로 여러 구독자에게 전달(weak `NSHashTable`). 입력 이벤트(`inputDelegate`)는 Tester만 쓰므로 단일 구독 유지
- 늦게 생성되는 모델(Tester 탭)은 init에서 `getControlelrInfo()`로 현재 연결 상태를 직접 반영해야 함. 해제 시 매니저가 `current`를 다시 계산하므로 연결된 컨트롤러가 없으면 nil
- 싱글톤 의존으로 단위 테스트 시 mocking이 까다로움

---

## 결정 #4 — 의존성 주입: 싱글톤 Manager, 컨테이너 없음

**결정**: DI 컨테이너 없이 전역 의존성은 싱글톤으로 노출한다.

| 싱글톤 | 역할 |
|---|---|
| `GameControllerManager.shared` (ControllerKit) | 연결 감지, 배터리 조회, 입력 매핑 |
| `StoreKitManager.shared` | 구독 여부, 상품 ID 로드, 결제 가능 여부 |
| `LiveActivityManager.shared` | Live Activity 시작/갱신/종료 |

**근거**:
- 타입 수가 적어 컨테이너 오버헤드가 불필요
- 외부 DI 라이브러리(Swinject 등) 회피

**트레이드오프**:
- 의존성이 코드 곳곳에서 직접 참조됨 → 테스트 격리에 불리

**도입 기준 (향후)**: Manager 수가 5개를 넘거나 테스트 커버리지를 넓힐 때 DI 패턴 재검토.

---

## 결정 #5 — 모듈 구조: 단일 .xcodeproj + 로컬 패키지 `ControllerKit`

**결정**: Tuist 미사용. 하나의 `Controllers.xcodeproj`에 4개 타깃을 두고, 앱·위젯·macOS가 공유하는 GameController 코드는 로컬 SPM 패키지 `ControllerKit`으로 분리한다.

| 타깃 / 패키지 | 설명 | 배포 타깃 |
|---|---|---|
| `Controllers` | iOS 메인 앱 | iOS 15.0 |
| `ControllersWidgetExtension` | 홈 화면 위젯 + Live Activity | iOS 15.0 |
| `Controllers-macOS` | macOS 앱 (템플릿 상태) | macOS 14.1 |
| `ControllersTests` | 단위 테스트 (IAP) | iOS 16.4 |
| `ControllerKit` (로컬 SPM) | `GameControllerManager`, `ControllerInput` | iOS 14.0 / macOS 14.1 |

**근거**:
- macOS 타깃 추가(`Feature/macOSTarget`)와 위젯에서 같은 컨트롤러 코드를 써야 해서 공유 모듈이 필요해짐
- 나머지 코드는 규모가 작아 추가 모듈 분리 이득이 작음

**트레이드오프**:
- 패키지 밖에서 쓰는 API는 `public` 선언 필요
- 앱 전용 코드(IAP, Live Activity)는 여전히 앱 타깃에 있어 macOS와 공유되지 않음

**외부 의존성**: SwiftyStoreKit 0.16.4 (SPM, 결정 #7).

---

## 결정 #6 — 데이터 영속화: `UserDefaults` (App Group + standard)

**결정**: 영속 저장은 `UserDefaults`로 한정한다. CoreData·Realm·Keychain 미도입.

| 저장소 | 키 (`StringKey`) | 용도 |
|---|---|---|
| `UserDefaults.shared` (App Group `group.arex.achaCharge`) | `CONTROLLER_CONNECTED`, `BATTERY_LEVEL`, `BATTERY_NOTIFICATION_THRESHOLD` | 위젯과 공유하는 컨트롤러 상태, 알림 기준값 |
| `UserDefaults.standard` | `IS_SUBSCRIBED` | 구독 여부 (앱 전용) |

`UserDefaults+.swift`에 `shared` 인스턴스와 `batteryNotificationThreshold`(기본 20%) 같은 계산 프로퍼티를 둔다.

**근거**:
- 저장 데이터가 원시 값 몇 개뿐 → DB는 과설계
- App Group을 쓰면 위젯과 바로 공유 (결정 #8)

**트레이드오프**:
- 구독 여부는 StoreKit 2 판정 결과를 캐시한 평문 플래그. 앱 활성화마다 다시 계산되지만, 앱 자체를 변조하면 우회 가능 (결정 #7)
- 구독 여부가 `standard`에 있어 위젯에서는 읽을 수 없음

**재검토 기준**: 구독 상태를 위젯에 노출하거나 보안을 강화해야 하면 저장 위치·Keychain 도입 검토.

---

## 결정 #7 — IAP: 구매는 SwiftyStoreKit, 구독 판정은 StoreKit 2

**결정**: 구매는 SwiftyStoreKit(StoreKit 1)으로 처리하고, 구독 상태 판정·복원·가격 표시는 StoreKit 2로 처리한다. 서버 검증은 두지 않는다.

| 기능 | 구현 |
|---|---|
| 앱 시작 시 미완료 트랜잭션 정리 | `AppDelegate` — `SwiftyStoreKit.completeTransactions` |
| 구매 | `IAPOnboardingViewController` — `SwiftyStoreKit.purchaseProduct` |
| 구독 여부 판정 | `StoreKitManager.refreshSubscriptionStatus()` — `Transaction.currentEntitlements`. 앱 활성화 시와 `Transaction.updates` 수신 시 호출하고, 결과를 `isSubscribed`(`UserDefaults.standard`)에 저장 |
| 복원 | `StoreKitManager.restoreSubscription()` — `AppStore.sync()` 후 재판정 |
| 구독 화면 가격 | `StoreKitManager.displayPrices()` — `Product.displayPrice` (현지 통화) |
| 상품 ID | `StoreKitManager` — `ProductIDs.plist` 로드 |

**상품 ID**: `weekly`, `monthly.10percent`, `yearly.25percent` — [ProductIDs.plist](Controllers/Controllers/Supporting%20Files/ProductIDs.plist)

**근거**:
- 도입 당시 iOS 14 배포 타깃 → StoreKit 2(iOS 15+) 사용 불가. 1.1.0에서 iOS 15로 올라가 이 제약은 해소됨
- StoreKit 1의 장황한 트랜잭션 처리를 SwiftyStoreKit으로 줄임 (`[refactor] SwiftyStoreKit`)
- 구매 시점에 저장한 플래그만으로는 만료·환불을 알 수 없었고, `StoreObserver`가 결제 큐에 등록되지 않아 복원도 동작하지 않았음 → 판정을 `currentEntitlements`로 옮기고 `StoreObserver`는 삭제. StoreKit 1로 산 구독도 StoreKit 2에서 그대로 조회됨
- 서버 검증을 두지 않는 이유: 유료 기능(백그라운드 알림)이 기기 안에서만 동작한다. 앱을 변조하면 서버 판정도 무시할 수 있어 보안상 이득이 없고 운영 비용만 생김

**트레이드오프**:
- 구매(StoreKit 1)와 판정(StoreKit 2) 경로가 나뉨. 트랜잭션 finish는 SwiftyStoreKit이 담당
- 만료는 앱이 활성화될 때 반영됨. 만료 후 앱을 열지 않으면, 마지막으로 예약된 백그라운드 알림 1회는 나갈 수 있음
- `hotfix/1.0.12-iapverify`는 develop에 머지됐지만 그 검증 코드는 남아 있지 않음 → 이 결정이 대체
- SwiftyStoreKit은 사실상 유지보수가 멈춘 라이브러리

**재검토 기준**: SwiftyStoreKit이 최신 iOS에서 문제를 일으키면 구매도 StoreKit 2(`Product.purchase()`)로 옮기고 제거. 서버 기능(동기화 등)이 생기면 App Store Server API 검증 추가.

---

## 결정 #8 — 위젯 IPC: App Group `UserDefaults` 단방향(앱 → 위젯)

**결정**: 앱과 위젯의 데이터 공유는 App Group `UserDefaults`만 사용한다. 위젯은 알림을 보내거나 앱에 데이터를 쓰지 않는다.

**위젯 측 읽기** (`Provider.getTimeline`):
1. `CONTROLLER_CONNECTED`가 true면 `GameControllerManager.shared.getBatteryInfo()`로 직접 조회 시도
2. 조회 실패(배터리 상태 unknown) 시 `BATTERY_LEVEL` 저장값 사용
3. 30분 간격 엔트리로 타임라인 구성

**근거**:
- 공유 데이터가 단순 → 가장 가벼운 IPC
- 위젯 갱신은 `TimelineProvider`가 주기적으로 처리

**제약**:
- 위젯 프로세스에서는 컨트롤러 직접 조회가 실패할 수 있어 앱이 저장해 둔 값에 의존
- 앱의 백그라운드 갱신은 결정 #10의 BGTask로 처리

**과거 흔적**: 커밋 `ba362d5` "위젯에서 Push 발송하는 부분 제거" — 위젯이 알림을 보내던 구조를 제거. **다시 도입하지 말 것.** (앱의 백그라운드 로컬 알림은 결정 #10으로 별개)

---

## 결정 #9 — 컨트롤러 페어링·입력: `GameController` 프레임워크

**결정**: 컨트롤러 연결은 Apple `GameController` 프레임워크에 맡긴다. AccessorySetupKit·CoreBluetooth는 직접 사용하지 않는다. 래퍼는 `ControllerKit`의 `GameControllerManager`.

**제공 기능**:
- 연결/해제 감지 (`.GCControllerDidConnect` / `.GCControllerDidDisconnect`)
- 배터리 조회 (`GCDeviceBattery` → `getBatteryInfo()`, `getControlelrInfo()`)
- 입력 매핑 (`GCExtendedGamepad` → `ControllerInput` enum: 십자키, 스틱, 터치패드, A/B/X/Y, L1/R1, L2/R2, 옵션/메뉴/홈) — Tester 탭에서 사용

**근거**:
- iOS 시스템 설정이 DualSense 페어링을 처리 → 앱이 BLE에 관여할 필요 없음
- 배터리·입력 API를 프레임워크가 제공

**트레이드오프**:
- 미지원 컨트롤러는 시스템 매핑이 있어야 동작
- 페어링 UX를 앱에서 바꿀 수 없음

**향후 검토**: `Feature/AccesorySetupKit` 브랜치에서 AccessorySetupKit 도입 검토 중.

---

## 결정 #10 — 백그라운드 알림: BGAppRefreshTask + 로컬 알림 + 사용자 설정 기준값

**결정**: 구독자에 한해 백그라운드에서 배터리를 확인하고, 사용자가 정한 기준값 이하이면 로컬 알림을 보낸다. 서버 Push는 쓰지 않는다.

**흐름**:
1. `AppDelegate` — 알림 권한 요청, BGTask(`com.controller.battery`) 등록
2. `SceneDelegate.sceneDidEnterBackground` — 구독자일 때만 `scheduleAppRefresh()`
3. 작업 실행 → `FetchGameControllerOperation.main()`
   - 배터리 조회, Live Activity 갱신 (결정 #11)
   - `level <= UserDefaults.shared.batteryNotificationThreshold`일 때만 `UNUserNotificationCenter`에 알림 등록
4. 기준값은 설정 화면 "충전 알림 기준" 행에서 10/20/30/50% 중 선택 (기본 20%)

**근거**:
- 서버 없이 동작해야 함
- 기준값이 없으면 배터리가 충분해도 매번 알림이 가서 소음이 됨

**트레이드오프**:
- BGAppRefresh 실행 시점은 시스템이 정함 → 정확한 주기 보장 불가
- 기준값 이하가 유지되는 동안 매 실행마다 알림 (중복 억제 없음)

**테스트**: LLDB `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.controller.battery"]`

---

## 결정 #11 — Live Activity: ActivityKit 로컬 갱신, iOS 16.1+ 가드

**결정**: 잠금화면·Dynamic Island에 배터리를 표시하는 Live Activity를 구독자 전용으로 제공한다. 배포 타깃(iOS 15)은 올리지 않고 ActivityKit 코드는 가용성 가드로 감싼다. 갱신은 로컬(ActivityKit)만 사용한다.

**구성**:
- `ControllerActivityAttributes` — 고정 값 `vendorName`, 변하는 값 `batteryLevel`/`batteryState`. **앱 + 위젯 두 타깃 멤버십**
- `LiveActivityManager` (앱) — `start` / `update` / `end`. 구독 여부와 `areActivitiesEnabled` 확인. iOS 16.2+ API와 16.1 API 분기
- `ControllerLiveActivity` (위젯) — 잠금화면 뷰 + Dynamic Island compact/minimal/expanded
- `Info.plist` — `NSSupportsLiveActivities = YES`

**연동 지점**: `ControllerModel` (연결 시 start, 정보 갱신 시 update, 해제 시 end), `FetchGameControllerOperation` (백그라운드 update)

**근거**:
- 서버 없이 구현 가능, 이 앱의 가장 자연스러운 노출 지점
- 배포 타깃을 올리지 않고 신규 기능 제공

**트레이드오프**:
- 실행 중인 Activity는 메모리에 따로 들고 있지 않고 시스템 목록(`Activity<ControllerActivityAttributes>.activities`)에서 찾음 → 앱이 재시작돼도 이어서 갱신, 종료 시 남은 Activity까지 모두 정리
- 앱이 백그라운드에서 깨어나지 않으면 갱신되지 않음 (Push 갱신 미사용)

---

## 결정 #12 — 광고 이용권: AdMob 보상형 광고 + 기기 안 만료 시각

**결정**: 구독하지 않은 사용자도 보상형 광고를 끝까지 보면 `RewardedPassManager.passDuration` 동안 유료 기능(백그라운드 충전 알림, Live Activity)을 쓴다. 유료 기능 판정은 `PremiumAccess.isActive`(구독 중 ‖ 이용권 남음) 한 곳으로 모은다.

| 항목 | 구현 |
|---|---|
| 광고 SDK | Google Mobile Ads 13.x + UMP 3.x (SPM) |
| 광고 요청 순서 | UMP 동의 갱신·필요 시 동의 화면 → ATT 요청 → `MobileAds.start` → `RewardedAd.load` → 표시. 동의·ATT는 `AdConsentManager`가 맡고 앱 시작 때도 묻는다(결정 #13) |
| 이용권 저장 | 만료 시각을 `UserDefaults.standard`(`StringKey.PRO_PASS_EXPIRATION`)에 저장. 시청 중에는 다시 받을 수 없음(누적 없음) |
| 유료 기능 판정 | BGTask 실행·예약, Live Activity 시작·갱신, 앱 활성화 시 Live Activity 정리 모두 `PremiumAccess.isActive` |
| 광고 단위 | DEBUG는 Google 테스트 단위, Release는 AdMob 'pro_pass_rewarded'. 앱 ID는 Info.plist `GADApplicationIdentifier` |
| EU 동의 | AdMob '아차 충전 iOS - 유럽 규정' 메시지. 동의가 필요한 지역이면 구매 화면에 '광고 개인정보 설정' 링크 표시 |

**근거**:
- 결제하지 않는 사용자에게도 유료 기능을 맛보게 하고 광고 수익을 얻음. 가이드라인 3.2.2(x)는 광고 시청에 대한 보상을 허용
- 판정을 기기 안에서 하는 이유는 결정 #7의 서버 검증 미사용과 같음 (유료 기능이 기기 안에서만 동작)
- ATT 허용 여부와 관계없이 보상은 같음 → 허용은 맞춤 광고 단가에만 영향

**트레이드오프**:
- 광고 SDK가 기기 식별자·광고 데이터·대략적 위치·진단 정보를 수집 → App Store 개인정보 라벨(추적 포함)과 개인정보처리방침(dy-solution.kr)을 함께 갱신해야 함
- 기기 시계를 바꾸면 이용권을 늘릴 수 있음 (서버 시간 검증 없음)
- 이용권이 끝나도 실행 중인 Live Activity는 다음 갱신이나 앱 활성화 때 닫힘
- AdMob 앱 인증은 App Store의 개발자 웹사이트(마케팅 URL) 도메인에 있는 app-ads.txt로 확인됨 → 마케팅 URL이 비어 있으면 광고 게재가 제한됨

**재검토 기준**: 구독 전환율이 떨어지면 `passDuration`을 줄이거나 하루 시청 횟수를 제한. 광고 수익이 의미 없으면 SDK째 제거(개인정보 라벨·방침도 되돌림).

---

## 결정 #13 — 비구독자 광고: 앱 오프닝 광고 + 컨트롤러 연결 시 Pro 팝업

**결정**: 유료 기능을 쓰지 않는 사용자(`!PremiumAccess.isActive`)에게 두 가지를 보여 준다. 구독자·광고 이용권 사용자에게는 보이지 않으며, 이로써 "광고 제거"가 Pro 혜택이 된다.

| 항목 | 구현 |
|---|---|
| 앱 시작 흐름 | `SceneDelegate.runLaunchFlow` (실행당 1회): 알림 권한 답(최대 10초 대기) → 비구독자면 UMP 동의·ATT·SDK 시작 → 앱 오프닝 광고 미리 로드 → Pro 팝업 허용 |
| 앱 오프닝 광고 | 백그라운드에서 돌아올 때만(`sceneDidBecomeActive`에서 직전에 `sceneDidEnterBackground`를 거쳤는지로 판단). 마지막 노출 후 15분(`AppOpenAdManager.minimumInterval`, `UserDefaults.standard`에 저장), 불러온 지 4시간 지난 광고는 버림 |
| 앱 오프닝 광고를 건너뛰는 경우 | 약관 링크·광고 클릭으로 앱이 사용자를 밖으로 보낸 직후 1회(`skipNextAd()`), 다른 광고·팝업(`UIAlertController`)이 떠 있을 때 |
| Pro 팝업 | 앱 실행 후 첫 컨트롤러 연결 때 1회(날짜와 무관, 메모리 플래그). 앱 시작 흐름이 끝나고 다른 광고·팝업이 없을 때 표시. 구매 화면을 보고 있으면 생략 |
| 광고 단위 | 앱 오프닝 'app_open_foreground'. DEBUG는 Google 테스트 단위 |

**근거**:
- AdMob 정책상 앱 로드·복귀 시점에 전면(interstitial) 광고는 금지. 이 시점용 형식이 앱 오프닝 광고
- 컨트롤러를 연결한 순간이 백그라운드 충전 알림이 가장 와닿는 때. 기존에는 Pro 진입점이 설정 탭 한 곳뿐이었음
- 알림 권한 팝업이 떠 있으면 앱이 비활성이라 ATT 팝업이 무시됨 → 순서를 코드로 강제

**트레이드오프**:
- 배터리만 잠깐 확인하고 나가는 사용자에게 광고가 끼어듦 → 간격 15분으로 완화
- Pro 팝업은 컨트롤러를 켠 채 앱을 실행할 때마다 뜸(연결 이벤트가 실행 직후 옴)
- 알림 권한 팝업이 10초 안에 뜨지 않으면 다음 단계로 넘어감. 그 뒤에 뜨더라도 `AdConsentManager.prepare()`가 앱이 다시 활성화될 때까지 기다리므로 ATT와 겹치지 않음

**재검토 기준**: 리뷰·별점에서 광고 불만이 늘면 간격을 늘리거나 앱 오프닝 광고를 끔. 팝업이 성가시다는 의견이 많으면 하루 1회로 제한.

---

## 알려진 부채 / 향후 결정 후보

다음 항목은 의사결정이 보류되었거나 미해결 상태입니다. 작업이 시작될 때 신규 "결정 #N"으로 승격하세요.

- **macOS 타깃 분기 전략**: ControllerKit 공유까지는 완료. 앱 레이어는 `Feature/macOSTarget`에서 진행 중이며 develop에는 템플릿만 있음
- **AccessorySetupKit 도입 여부**: 결정 #9 참조
- **구매까지 StoreKit 2로 통합 + SwiftyStoreKit 제거**: 결정 #7 — 구독 판정·복원·가격 표시는 전환 완료, 구매만 남음
- **영수증 검증**: 현재 없음. 클라이언트 단독 vs 서버 사이드 결정 필요
- **테스트 실행 불가**: `Controllers` scheme TestAction에 `ControllersTests` 미등록 → CI test 단계 비활성화 상태
- **오타**: `TabType.controlelr`, `getControlelrInfo()` — 별도 리팩토링 작업

---

*기준: `develop` + PR #15 + `Feature/charge-alert-enhancements` 작업 트리 · 최종 갱신: 2026-10-04*
