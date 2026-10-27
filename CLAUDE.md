# CLAUDE.md

> Claude Code가 본 저장소에서 작업할 때 자동으로 로드하는 컨텍스트 문서. 빌드/실행 명령, 코드베이스 컨벤션, 자주 쓰는 패턴을 기록합니다.

## 프로젝트 개요

**AchaCharge** ("아차! 충전 까먹었다")는 Game Controller의 배터리 충전 시기를 알려주는 iOS 앱입니다. 내부 Xcode 프로젝트명은 `Controllers`이며, 홈 화면 표시 이름은 ko `아차 충전 !` / en `Ah Charge!` / ja `忘れないで！` 입니다.

- **핵심 기능**: 컨트롤러 배터리 모니터링 · 버튼 입력 테스터 · 백그라운드 저전력 알림 · 홈 화면 위젯 · Live Activity · 월 구독(IAP) · 광고 시청 Pro 이용권
- **지원 OS**: 앱/위젯 iOS 15.0 이상 (1.1.0부터 — Xcode 27이 지원하는 최소값). 테스트 타깃 16.4, Live Activity 16.1+ 런타임 가드. macOS 타깃(14.1)은 템플릿만 존재
- **외부 의존성**: [SwiftyStoreKit](https://github.com/bizz84/SwiftyStoreKit) 0.16.4, Google Mobile Ads 13.x, Google UMP 3.x (모두 SPM) + 로컬 패키지 `ControllerKit`
- **공식 지원 컨트롤러**: Sony PlayStation DualSense Wireless Controller

상세 슬로건·외부 소개는 [README.md](README.md) 참조.

## 출시 상태

| 구분 | 버전 | 내용 |
|---|---|---|
| App Store 라이브 | **1.1.0 (20)** — 2026-10-05 심사 통과, 태그 `1.1.0` | SwiftUI, 컨트롤러 테스터, 충전 알림 기준값, Live Activity, StoreKit 2 구독 확인, iOS 15+ |
| 이전 버전 | 1.0.13 (2024-05-21), 태그 `1.0.13` | UIKit 앱, iOS 14+ |

## 빌드 / 실행 / 테스트

Tuist 미사용. `Controllers.xcodeproj`를 Xcode에서 직접 열어 작업합니다. 패키지는 Xcode SPM 통합으로 관리됩니다.

```bash
open Controllers/Controllers.xcodeproj

# CLI 빌드 (CI와 동일)
xcodebuild build -project Controllers/Controllers.xcodeproj -scheme Controllers \
  -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

### Scheme 목록 (shared)

| Scheme | 용도 |
|---|---|
| `Controllers` | 메인 iOS 앱 |
| `ControllersWidgetExtension` | 홈 화면 위젯 + Live Activity |
| `Controllers-macOS` | macOS 앱 (템플릿 상태) |

- `ControllersTests` 타깃은 있지만 `Controllers` scheme의 TestAction에 등록되어 있지 않아 `xcodebuild test`가 실패합니다.
- 백그라운드 알림 테스트 (LLDB, 앱 일시정지 상태에서):
  `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.controller.battery"]`
- 스크린샷·화면 확인용 DEBUG 실행 인자 ([ScreenshotFixture.swift](Controllers/Controllers/Sources/Debug/ScreenshotFixture.swift)): `-ACScreenshot YES`(시작 팝업·광고 생략, 실제 컨트롤러 이벤트 무시) + `-ACMockBattery 0.42`(`-1`이면 배터리 정보 없는 컨트롤러) `-ACMockCharging YES` `-ACMockVendor "<이름>"` `-ACTab controller|tester|setting` `-ACPaywall YES`. 시뮬레이터에는 컨트롤러를 연결할 수 없어 연결 상태는 이것으로 만듭니다. iOS 27 시뮬레이터는 배터리 정보 없는 가상 "Gamepad"를 연결된 것으로 넘겨줍니다

### CI

[.github/workflows/ios.yml](.github/workflows/ios.yml) — `main`/`develop` push·PR 시 `macos-15`(Xcode 16 이상 — Google Mobile Ads 13 요구)에서 `Controllers` scheme **빌드만** 수행. test 단계는 위 TestAction 문제로 비활성화.

### 주요 식별자

| 항목 | 값 |
|---|---|
| 메인 앱 번들 ID | `com.arex.achaCharge` |
| 위젯 번들 ID | `com.arex.achaCharge.widget` |
| macOS 번들 ID | `com.arex.Controllers-macOS` |
| App Group ID | `group.arex.achaCharge` |
| IAP 상품 ID | `weekly`, `monthly.10percent`, `yearly.25percent` |
| BG Task ID | `com.controller.battery` |

상품 ID는 [ProductIDs.plist](Controllers/Controllers/Supporting%20Files/ProductIDs.plist)에 정의되어 있습니다.

## 디렉토리 구조

```
.
├── .github/workflows/ios.yml               # CI (빌드 전용)
├── Controllers/                            # Xcode 프로젝트 루트
│   ├── Controllers.xcodeproj
│   ├── ControllerKit/                      # 로컬 SPM 패키지 (패키지 최소 iOS 14 / macOS 14.1)
│   │   └── Sources/Controller/             # GameControllerManager, ControllerInput
│   ├── Controllers/                        # 메인 앱 타깃
│   │   ├── Applications/                   # AppDelegate (BGTask 등록·IAP 트랜잭션), SceneDelegate (루트 뷰·BGTask 스케줄)
│   │   ├── Sources/
│   │   │   ├── MainTabView.swift           # 루트 TabView (Controller / Tester / Setting)
│   │   │   ├── Controller/                 # ControllerView, ControllerModel, ProgressBarView
│   │   │   ├── Tester/                     # TesterView, TesterModel, SubViews/ (DPad, Thumbstick, Trigger 등)
│   │   │   ├── Setting/                    # SettingViewController (UIKit), IAPOnboardingViewController (UIKit), InfoView
│   │   │   ├── Models/                     # StoreKitManager, FetchGameControllerOperation, LiveActivityManager, ControllerActivityAttributes
│   │   │   ├── Component/                  # ImageButton
│   │   │   └── Extensions/                 # StringKey+, UserDefaults+, String+(localized), UIColor+ 등
│   │   └── Supporting Files/               # Info.plist, ProductIDs.plist, Assets/ColorAsset.xcassets, ko/en/ja.lproj
│   ├── ControllersWidget/                  # 위젯 타깃 (SwiftUI) — 홈 위젯 + ControllerLiveActivity
│   ├── Controllers-macOS/                  # macOS 타깃 (AppKit 템플릿)
│   └── ControllersTests/                   # IAP 관련 단위 테스트
├── CLAUDE.md                               # 본 문서
├── ARCHITECTURE.md                         # 아키텍처 의사결정 기록
├── DESIGN.md                               # 디자인 토큰 현황·로드맵
├── docs/index.md                           # 문서 인덱스
└── README.md
```

## 코드베이스 컨벤션

### UI 프레임워크
- **메인 앱은 SwiftUI 기반** (PR #9에서 전환). `SceneDelegate`가 `UIHostingController(rootView: MainTabView())`를 루트로 설정
- 아직 UIKit으로 남은 화면: `SettingViewController`(`SettingViewRepresentable`로 감쌈), `IAPOnboardingViewController`. UIKit 화면은 SnapKit 없이 `NSLayoutConstraint`로 작성됨
- **신규 화면은 SwiftUI로 작성**. 최소 iOS 15이므로 iOS 16+/17+ API(`NavigationStack`, `@Observable` 등)는 `#available` 가드 필요

### 상태 관리
- 화면별 `ObservableObject` + `@Published` 모델 (`ControllerModel`, `TesterModel`)
- 컨트롤러 이벤트는 `GameControllerManager`가 모델에 전달. 연결/해제는 `addDelegate(_:)`로 등록(여러 구독자 가능), 입력은 `inputDelegate`(단일)
- `@Observable`(iOS 17+)은 최소 OS 때문에 사용 불가. MVVM 계층·Combine 파이프라인은 따로 두지 않음

### 의존성 주입
- DI 컨테이너 없음. 전역 객체는 싱글톤
  - `GameControllerManager.shared` (ControllerKit) — 연결 감지·배터리 조회·입력 매핑
  - `StoreKitManager.shared` — 구독 여부, 상품 ID 로드
  - `LiveActivityManager.shared` — Live Activity 시작/갱신/종료
  - `RewardedPassManager.shared` — 보상형 광고(로드·표시)와 광고 이용권
  - `AdConsentManager.shared` — 광고 요청 전 UMP 동의·ATT·SDK 시작
  - `AppOpenAdManager.shared` — 포어그라운드 복귀 시 앱 오프닝 광고
  - `ProPromotionManager.shared` — 컨트롤러 연결 시 Pro 소개 팝업
- 새 Manager 추가 시 같은 패턴 유지

### ControllerKit (로컬 패키지)
- 앱·위젯이 공유하는 GameController 래퍼. 위젯도 `import ControllerKit` 후 `GameControllerManager.shared`를 직접 호출
- 접근 제어: 외부에 노출할 API는 `public`으로 선언

### 영속화
- **`UserDefaults.shared`** (App Group `group.arex.achaCharge`) — 컨트롤러 연결 여부, 배터리, 알림 기준값 등 위젯과 공유하는 값
- **`UserDefaults.standard`** — 구독 여부(`StringKey.IS_SUBSCRIBED`), 광고 이용권 만료 시각(`StringKey.PRO_PASS_EXPIRATION`), 마지막 앱 오프닝 광고 시각(`StringKey.LAST_APP_OPEN_AD_DATE`). 위젯에서 읽을 수 없음
- 헬퍼: [UserDefaults+.swift](Controllers/Controllers/Sources/Extensions/UserDefaults+.swift) (`batteryNotificationThreshold` 등 계산 프로퍼티)
- 키는 `StringKey` 네임스페이스에 상수로 정의 — 새 키 추가 시 동일 패턴
- CoreData/Realm/Keychain 미사용. 도입 시 ARCHITECTURE.md에 의사결정 기록 필요
- **개인정보 매니페스트**: `UserDefaults`는 Apple의 required reason API라 `PrivacyInfo.xcprivacy`에 사유를 신고함 (앱 `Supporting Files/`: `CA92.1` + `1C8F.1`, 위젯: `1C8F.1`). 다른 required reason API(파일 타임스탬프, 부팅 시간, 디스크 용량 등)를 쓰면 두 파일을 함께 갱신하지 않으면 업로드가 거부될 수 있음

### 위젯 ↔ 앱 데이터 공유
- App Group `UserDefaults`를 단방향(앱 → 위젯)으로 사용
- 쓰기는 [WidgetSharedState](Controllers/Controllers/Sources/Models/WidgetSharedState.swift)`.save(...)` 한곳에서 합니다. 연결 여부·잔량·`BATTERY_STATE`·`VENDOR_NAME`·`LAST_UPDATED`를 쓰고, 상태가 바뀔 때만 타임라인을 다시 읽게 합니다
- 위젯은 `batteryState`가 unknown(-1)이면 "배터리 정보 없음"으로, 미연결이면 마지막 값과 함께 "Not connected"로 표시합니다
- 시뮬레이터에서 App Group을 공유하려면 로컬 서명으로 빌드해야 합니다(`CODE_SIGN_IDENTITY=- CODE_SIGNING_ALLOWED=YES`). `CODE_SIGNING_ALLOWED=NO` 빌드는 위젯이 앱 값을 못 읽습니다
- 위젯에서 Push를 보내던 코드는 제거됨 (커밋 `ba362d5`). 위젯 → 앱 통신을 다시 넣지 마세요

### 백그라운드 알림 (구독자·광고 이용권 사용자 전용)
- `AppDelegate`가 BGTask를 등록 → `SceneDelegate.sceneDidEnterBackground`에서 `PremiumAccess.isActive`일 때만 `scheduleAppRefresh()`
- 작업 실행 시 [FetchGameControllerOperation](Controllers/Controllers/Sources/Models/FetchGameControllerOperation.swift)이 배터리를 읽어 **기준값(기본 20%) 이하일 때만** 로컬 알림 발송

### Live Activity (iOS 16.1+, 구독자·광고 이용권 사용자 전용)
- `ControllerActivityAttributes`는 **앱 + 위젯 양쪽 타깃 멤버십** 필요
- ActivityKit 코드는 전부 `@available(iOS 16.1, *)` + 런타임 `if #available` 가드. 앱 배포 타깃(15.0)은 올리지 않음
- 갱신은 로컬(ActivityKit)만 사용, Push 기반 갱신 없음

### IAP
- **구매는 StoreKit 1(SwiftyStoreKit)**, **구독 상태·복원·가격 표시는 StoreKit 2**로 처리 ([StoreKitManager.swift](Controllers/Controllers/Sources/Models/StoreKitManager.swift))
  - 구매: `SwiftyStoreKit.purchaseProduct` (`IAPOnboardingViewController`), 트랜잭션 finish는 SwiftyStoreKit 담당
  - 구독 여부: `refreshSubscriptionStatus()`가 `Transaction.currentEntitlements`로 판단해 `StoreKitManager.shared.isSubscribed`에 저장. 앱 활성화 시와 `Transaction.updates` 수신 시 호출
  - 복원: `restoreSubscription()` (`AppStore.sync()` 후 재계산)
  - 구독 화면 가격: `displayPrices()` (`Product.displayPrice`, 현지 통화). 가격을 코드에 쓰지 마세요
- 서버 검증은 쓰지 않습니다. 유료 기능이 기기 안에서만 동작해서, 서버 검증이 보안상 추가로 막는 게 없습니다
- `hotfix/1.0.12-iapverify`는 develop에 머지됐지만 그 검증 코드는 남아 있지 않습니다. 위 StoreKit 2 판정이 그 역할을 대신합니다
- 상품 ID는 절대 코드에 하드코딩 금지 — `ProductIDs.plist`에서 로드
- 유료 기능 여부는 `StoreKitManager.shared.isSubscribed`가 아니라 **`PremiumAccess.isActive`**(구독 ‖ 광고 이용권)로 판단

### 광고 (AdMob)
유료 기능을 쓰지 않는 사용자(`!PremiumAccess.isActive`)에게만 광고가 나갑니다. 구독자와 광고 이용권 사용자는 광고를 보지 않습니다.

- **앱 시작 흐름** (`SceneDelegate.runLaunchFlow`, 실행당 1회): 알림 권한 답 기다림(최대 10초) → 구독자가 아니면 [AdConsentManager](Controllers/Controllers/Sources/Models/AdConsentManager.swift)가 UMP 동의 → ATT → SDK 시작 → 앱 오프닝 광고 미리 로드 → Pro 팝업 허용. 시스템 팝업이 겹치지 않게 이 순서를 지키세요
- **보상형 → 광고 이용권** ([RewardedPassManager.swift](Controllers/Controllers/Sources/Models/RewardedPassManager.swift)): 구매 화면 버튼·Pro 팝업에서 시청. 끝까지 보면 `passDuration` 동안 이용권
- **앱 오프닝 광고** ([AppOpenAdManager.swift](Controllers/Controllers/Sources/Models/AppOpenAdManager.swift)): 백그라운드에서 돌아올 때만(콜드 스타트·제어 센터 제외), 마지막 노출 후 `minimumInterval`(15분)이 지나야 표시. AdMob 정책상 앱을 열거나 돌아오는 시점에는 전면(interstitial) 광고를 쓰면 안 됩니다
- **Pro 팝업** ([ProPromotionManager.swift](Controllers/Controllers/Sources/Models/ProPromotionManager.swift)): 앱 실행 후 첫 컨트롤러 연결 때 1회. 광고 이용권 받기 / 구매 화면 / 나중에
- 앱이 사용자를 밖으로 보내는 코드(`UIApplication.shared.open` 등)를 추가하면 그 직전에 `AppOpenAdManager.shared.skipNextAd()`를 부르세요. 안 그러면 돌아오자마자 광고가 뜹니다
- **평가 요청** ([ControllerModel.swift](Controllers/Controllers/Sources/Controller/ControllerModel.swift) `isReviewRequestDue`): 누적 연결 3회째부터 앱 버전당 한 번. 차례인 실행에서는 Pro 팝업을 건너뛰고 평가를 먼저 띄우며, 시작 흐름·광고·모달이 끝나기를 최대 30초 기다립니다
- DEBUG 빌드는 Google 테스트 광고 단위를 씀. 실제 광고 단위로 개발 중 광고를 누르지 마세요(AdMob 무효 트래픽)
- AdMob 앱 ID `ca-app-pub-7469152743628808~7969925639`(Info.plist `GADApplicationIdentifier`), 보상형 `pro_pass_rewarded` `.../7469653173`, 앱 오프닝 `app_open_foreground` `.../3611967519`
- 광고 SDK가 데이터를 수집하므로 App Store 개인정보 라벨(추적 포함)과 dy-solution.kr 개인정보처리방침을 같이 관리. 근거는 ARCHITECTURE.md 결정 #12, #13

### 로컬라이제이션
- ko / en / ja / es / pt-BR / ru / tr / fr / de `Localizable.strings` + `InfoPlist.strings` (앱), 위젯은 `ControllersWidget/*.lproj/Localizable.strings`를 따로 가짐
- 접근: `"key".localized`, `"key %@".localized(with: [arg])` ([String+.swift](Controllers/Controllers/Sources/Extensions/String+.swift)). 위젯은 `Text("key")`/`NSLocalizedString`
- 신규 문구는 9개 언어 모두 추가하고 키 집합을 ko와 맞추세요. 사용자에게 보이는 문구를 하드코딩하지 마세요

### 컬러
- 컬러셋은 `ColorAsset.xcassets`에 정의하고 UIKit에서는 `UIColor.color(name:)` ([UIColor+.swift](Controllers/Controllers/Sources/Extensions/UIColor+.swift))로 접근. 현재 탭바 컬러 2개뿐
- **다크모드 필수**: 신규 컬러는 Any/Dark Appearance 모두 정의

### 명명
- 파일/타입: PascalCase (`MainTabView`, `GameControllerManager`)
- enum case: lowerCamelCase
- 알려진 오타 (별도 작업으로 분리, 임의 수정 금지): `MainTabView.TabType.controlelr`, `GameControllerManager.getControlelrInfo()`

## 브랜치 / 진행 중인 변경 사항

- **`develop`이 통합 브랜치**이자 GitHub 기본 브랜치입니다. 브랜치 흐름:
  1. `Feature/*`, `fix/*`, `docs/*` → `develop` (PR, merge commit)
  2. 출시 준비가 되면 `develop` → `release` fast-forward push → **Xcode Cloud `pre-release` 워크플로가 아카이브·App Store Connect 업로드** (빌드 번호 자동)
  3. App Store 심사 통과 후 `release` → `main` (PR, merge commit) + 빌드된 커밋에 버전 태그(annotated, 예: `1.1.0`)
  4. 머지된 브랜치는 로컬·원격에서 삭제
- 브랜치 prefix 대소문자를 섞지 마세요 (`Feature/` vs `feature/`). macOS 파일시스템은 대소문자를 구분하지 않아, `git pack-refs` 이후 HEAD가 존재하지 않는 ref를 가리키게 됩니다. 기존 브랜치가 `Feature/`이므로 새 브랜치도 `Feature/`를 사용하세요.

| 브랜치 | 작업 내용 | 머지 전 주의점 |
|---|---|---|
| `Feature/macOSTarget` | macOS App Open 로직, ControllerView 지원 | develop 미머지 (develop보다 오래된 base) |
| `Feature/AccesorySetupKit` | AccessorySetupKit 도입 검토 (로컬 전용) | 현재 페어링은 GameController 프레임워크가 자동 처리 |

## 상세 문서

- [ARCHITECTURE.md](ARCHITECTURE.md) — 각 아키텍처 결정의 근거·트레이드오프·대안
- [DESIGN.md](DESIGN.md) — 디자인 토큰 As-Is 인벤토리와 토큰화 로드맵
- [docs/index.md](docs/index.md) — 전체 문서 카탈로그 및 작성 컨벤션
- [README.md](README.md) — 외부용 앱 소개

---

*기준: `Feature/develop-dev` (UI/UX 개편) · 최종 갱신: 2026-10-27*
