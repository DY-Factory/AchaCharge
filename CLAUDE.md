# CLAUDE.md

> Claude Code가 본 저장소에서 작업할 때 자동으로 로드하는 컨텍스트 문서. 빌드/실행 명령, 코드베이스 컨벤션, 자주 쓰는 패턴을 기록합니다.

## 프로젝트 개요

**AchaCharge** ("아차! 충전 까먹었다")는 Game Controller의 배터리 충전 시기를 알려주는 iOS 앱입니다. 내부 Xcode 프로젝트명은 `Controllers`이며, 한국어 표시 이름은 `아차 충전 !`, 영어 표시 이름은 `Ah Charge!` 입니다.

- **핵심 기능**: Game Controller 배터리 모니터링 + 홈 화면 위젯 + 컨트롤러 테스터(버튼·D-pad·스틱·트리거) + 구독(IAP)
- **유료 기능**: 백그라운드 배터리 확인 + 로컬 알림 (구독자만 `BGAppRefreshTask` 예약)
- **지원 OS**: iOS 15.0 이상 (1.1.0부터. Xcode 27이 지원하는 최소값), 위젯 동봉. macOS 타깃 `Controllers-macOS`는 `Feature/macOSTarget` 브랜치에서 작업 중
- **외부 의존성 최소화**: SPM 원격 패키지는 SwiftyStoreKit(StoreKit 1 래퍼) 하나. 컨트롤러 로직은 로컬 패키지 `ControllerKit`으로 분리
- **공식 지원 컨트롤러**: Sony PlayStation DualSense Wireless Controller

상세 슬로건·외부 소개는 [README.md](README.md) 참조.

## 출시 상태

| 구분 | 버전 | 내용 |
|---|---|---|
| App Store 라이브 | 1.0.13 (2024-05-21) | UIKit 앱, iOS 14+, 테스터 없음 |
| `develop` | 1.1.0 준비 중 | SwiftUI 전환(#9) + 컨트롤러 테스터(#10), iOS 15+ |

## 빌드 / 실행 / 테스트

Tuist는 사용하지 않습니다. `Controllers.xcodeproj`를 Xcode에서 직접 열어 작업하고, 의존성은 프로젝트에 연결된 SPM 패키지(SwiftyStoreKit, 로컬 `ControllerKit`)뿐입니다.

```bash
open Controllers/Controllers.xcodeproj

# CLI 빌드 확인 (서명 없이)
xcodebuild -project Controllers/Controllers.xcodeproj -scheme Controllers \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

### Scheme 목록

| Scheme | 용도 |
|---|---|
| `Controllers` | 메인 iOS 앱 |
| `ControllersWidgetExtension` | 홈 화면 위젯 |
| `Controllers-macOS` | macOS 앱 (제출 준비 중) |

`ControllersTests` 타깃은 있지만 `Controllers` scheme의 TestAction에 등록돼 있지 않아 CI 테스트 단계는 꺼져 있습니다 ([.github/workflows/ios.yml](.github/workflows/ios.yml)).

### 주요 식별자

| 항목 | 값 |
|---|---|
| 메인 앱 번들 ID | `com.arex.achaCharge` |
| 위젯 번들 ID | `com.arex.achaCharge.widget` |
| macOS 번들 ID | `com.arex.Controllers-macOS` |
| App Group ID | `group.arex.achaCharge` |
| IAP 상품 ID | `weekly`, `monthly.10percent`, `yearly.25percent` |
| BG Task ID | `com.controller.battery` |

상품 ID는 [Controllers/Controllers/Supporting Files/ProductIDs.plist](Controllers/Controllers/Supporting%20Files/ProductIDs.plist)에 정의되어 있습니다.

### 브랜치

- GitHub 기본 브랜치는 **`develop`** 입니다. PR은 `develop`으로 올립니다. `main`은 2023-08 이후 갱신되지 않았습니다.
- 브랜치 prefix의 대소문자를 섞지 마세요 (`Feature/` vs `feature/`). macOS 파일 시스템은 대소문자를 구분하지 않아서, `git pack-refs` 이후 HEAD가 존재하지 않는 ref를 가리키게 됩니다.

## 디렉토리 구조

```
.
├── Controllers/                            # Xcode 프로젝트 루트
│   ├── Controllers.xcodeproj
│   ├── ControllerKit/                      # 로컬 SPM 패키지: GameControllerManager, ControllerInput
│   ├── Controllers/                        # 메인 앱 타깃
│   │   ├── Applications/                   # AppDelegate (IAP 트랜잭션, BG Task), SceneDelegate (루트 뷰)
│   │   ├── Sources/
│   │   │   ├── MainTabView.swift           # 탭: 컨트롤러 / 테스터 / 설정
│   │   │   ├── Controller/                 # 배터리 화면 (SwiftUI) + ControllerModel
│   │   │   ├── Tester/                     # 컨트롤러 테스터 (SwiftUI) + TesterModel
│   │   │   ├── Setting/                    # 설정·구독 화면 (UIKit) + InfoView (SwiftUI)
│   │   │   ├── Models/                     # StoreKitManager, StoreObserver, FetchGameControllerOperation
│   │   │   ├── Component/
│   │   │   └── Extensions/                 # UIColor+, UserDefaults+, StringKey+, String+ (localized)
│   │   └── Supporting Files/               # Info.plist, ProductIDs.plist, xcassets, {en,ja,ko}.lproj
│   ├── ControllersWidget/                  # 위젯 타깃 (SwiftUI)
│   ├── Controllers-macOS/                  # macOS 타깃
│   └── ControllersTests/                   # 테스트 타깃
├── CLAUDE.md                               # 본 문서
├── ARCHITECTURE.md                         # 아키텍처 의사결정 기록
├── DESIGN.md                               # 디자인 토큰 현황·로드맵
├── docs/
│   └── index.md                            # 문서 인덱스
└── README.md
```

## 코드베이스 컨벤션

### UI 프레임워크
- **메인 앱은 SwiftUI**. [SceneDelegate.swift](Controllers/Controllers/Applications/SceneDelegate.swift)에서 `UIHostingController(rootView: MainTabView())`를 루트로 설정
- **설정 화면만 UIKit** (`SettingViewController`, `IAPOnboardingViewController`). `SettingViewRepresentable`로 감싸 탭에 넣음
- 새 화면은 **SwiftUI로 작성**하세요. 최소 iOS 15이므로 iOS 16+/17+ API는 `#available`로 감싸야 합니다

### 상태 관리
- 화면별 `ObservableObject` + `@Published` 모델 (`ControllerModel`, `TesterModel`)
- 컨트롤러 이벤트는 `GameControllerManager.shared`(ControllerKit) + `NotificationCenter`로 받음
- `@Observable`(iOS 17+)은 최소 OS 때문에 사용 불가

### 의존성 주입
- DI 컨테이너 없음. 모델은 각 뷰가 직접 생성
- 전역 객체는 싱글톤: `GameControllerManager.shared`, `StoreKitManager.shared`
- 새 Manager 추가 시 같은 패턴 유지

### 영속화
- **`UserDefaults.shared`만 사용** (App Group: `group.arex.achaCharge`)
- 헬퍼: [Extensions/UserDefaults+.swift](Controllers/Controllers/Sources/Extensions/UserDefaults+.swift)
- 키는 `StringKey` 네임스페이스에 상수로 정의 — 새 키 추가 시 동일 패턴
- CoreData/Realm/Keychain 미사용. 도입 시 ARCHITECTURE.md에 의사결정 기록 필요

### 위젯 ↔ 앱 데이터 공유
- App Group `UserDefaults`를 단방향(앱 → 위젯)으로 사용
- 위젯이 사용하는 키: `StringKey.BATTERY_LEVEL`, `StringKey.CONTROLLER_CONNECTED`
- 위젯에서 보내던 Push는 제거됨 (커밋 `ba362d5` 참조). 위젯 → 앱 통신과 원격 Push는 다시 도입하지 마세요
- 배터리 로컬 알림은 앱이 보냅니다 (`FetchGameControllerOperation`, 구독자 전용 BG Task)

### IAP
- **StoreKit 1** 기반. 구매·복원·트랜잭션 완료는 **SwiftyStoreKit**으로 처리
  - 앱 시작 시 `SwiftyStoreKit.completeTransactions` ([AppDelegate.swift](Controllers/Controllers/Applications/AppDelegate.swift))
  - 구매·복원: `SettingViewController`, `IAPOnboardingViewController`
  - 구독 여부: `StoreKitManager.shared.isSubscribed`
- 1.1.0부터 최소 iOS 15라 StoreKit 2를 쓸 수 있지만 아직 전환하지 않았습니다 (ARCHITECTURE.md 결정 #7)
- 영수증 검증은 별도 브랜치 (`hotfix/1.0.12-iapverify`)에서 작업 중. 본 브랜치에는 미반영
- 상품 ID는 절대 코드에 하드코딩 금지 — `ProductIDs.plist`에서 로드

### 컬러
- 컬러는 `ColorAsset.xcassets`의 컬러셋으로 정의하고 `UIColor.color(name:)` ([UIColor+.swift](Controllers/Controllers/Sources/Extensions/UIColor+.swift))로 접근
- **다크모드 필수**: 신규 컬러는 Any/Dark Appearance 모두 정의

### 문자열
- `Supporting Files/{en,ja,ko}.lproj/Localizable.strings` + `String.localized` ([String+.swift](Controllers/Controllers/Sources/Extensions/String+.swift))
- 새 문자열은 세 언어 파일에 모두 추가

### 명명
- 파일/타입: PascalCase (`MainTabView`, `GameControllerManager`)
- enum case: lowerCamelCase. 단, 기존 `TabType.controlelr` 오타는 미수정 상태(별도 작업으로 분리)

## 진행 중인 변경 사항

| 브랜치 | 작업 내용 | 머지 전 주의점 |
|---|---|---|
| `Feature/macOSTarget` | macOS 타깃 | App Open 로직, ControllerView SwiftUI 추가 |
| `Feature/AccesorySetupKit` | AccessorySetupKit 도입 검토 | 현재 페어링은 GameController 프레임워크가 자동 처리 |
| `hotfix/1.0.12-iapverify` | 영수증 검증 핫픽스 | StoreKit 1 영수증 검증 로직 |

## 상세 문서

- [ARCHITECTURE.md](ARCHITECTURE.md) — 각 아키텍처 결정의 근거·트레이드오프·대안 (일부 항목은 SwiftUI 전환 이전 기준)
- [DESIGN.md](DESIGN.md) — 디자인 토큰 As-Is 인벤토리와 토큰화 로드맵
- [docs/index.md](docs/index.md) — 전체 문서 카탈로그 및 작성 컨벤션
- [README.md](README.md) — 외부용 앱 소개

---

*기준 브랜치: `develop` · 최종 갱신: 2026-10-04*
