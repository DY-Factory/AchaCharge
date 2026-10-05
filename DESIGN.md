# DESIGN.md

> AchaCharge의 디자인 토큰 현황(As-Is)과 토큰화 로드맵(To-Be)을 정리합니다. 현재 토큰화 수준은 **초기 단계**이며, 폰트·여백·배터리 색상 대부분이 각 View에 하드코딩되어 있습니다.

## 개요

의도된 디자인 시스템은 없고, "필요할 때 만든 값"이 SwiftUI View와 남은 UIKit 화면 곳곳에 흩어져 있습니다. 이 문서의 목표는:

1. 현재 어떤 토큰·하드코딩 값이 있는지 (**As-Is 인벤토리**)
2. 어떤 우선순위로 정리할지 (**To-Be 로드맵**)
3. 신규 작업 시 따를 명명·다크모드 정책

을 명문화하는 것입니다. UI 프레임워크 구성은 ARCHITECTURE.md 결정 #1 참고 (SwiftUI 메인 + UIKit 설정·결제 화면).

---

## As-Is: 컬러

### 컬러셋

| 이름 | Light | Dark | 위치 | 사용 여부 |
|---|---|---|---|---|
| `tabBarBackgroundColor` | `#F9F9F9` | `#111113` | `ColorAsset.xcassets` | ❌ 미사용 (SwiftUI `TabView` 전환 후) |
| `tabBarTintColor` | `#D8D8D8` | `#1F1F1F` | `ColorAsset.xcassets` | ❌ 미사용 |
| `Controller` | `#000000` | `#FFFFFF` | `Assets.xcassets` | — (`.primary`와 동일) |
| `AccentColor` | 미설정 | 미설정 | `Assets.xcassets` | 시스템 기본 파랑 |
| `AccentColor`, `WidgetBackground` | — | — | `ControllersWidget/Assets.xcassets` | 위젯 전용 |

**접근 헬퍼**: [UIColor+.swift](Controllers/Controllers/Sources/Extensions/UIColor+.swift)의 `UIColor.color(name:)` — 현재 호출하는 곳이 없음.

### 배터리 색상 (하드코딩, 규칙 불일치)

같은 배터리 잔량이 화면마다 다른 색으로 보입니다.

| 위치 | 규칙 |
|---|---|
| `ProgressBarView` (앱), `ProgressBar` (위젯) | 항상 `.green` (배경 링은 opacity 0.3) |
| `TesterView.batteryColor` | `≤ 0.2` red / `≤ 0.4` orange / 그 외 green |
| `LiveActivityFormat.batteryColor` | `< 0.2` red / `< 0.4` orange / 그 외 green |

### 그 밖의 하드코딩 색상

| 위치 | 값 | 문제 |
|---|---|---|
| `TesterView` 컨트롤러 카드 배경 | `Color.white.opacity(0.8)` | 다크모드에서 흰 카드로 남음 |
| `InfoView` 하단 아이콘 | `.foregroundColor(.black)` | 다크모드에서 안 보임 |
| Tester 버튼 눌림 상태 | `.blue` | |
| `IAPOnboardingViewController` 구매 버튼 | `.systemPink` | |
| Live Activity 배경 | `Color.black.opacity(0.6)` | |

나머지는 `.primary`, `.label`, `.systemBackground` 등 시스템 컬러를 사용합니다.

---

## As-Is: 폰트

> ❌ **폰트 토큰 미정의**. 커스텀 폰트 없음. 고정 크기와 Dynamic Type 텍스트 스타일이 섞여 있습니다.

| 사용처 | 값 |
|---|---|
| `ControllerView` 배터리 % / "Not connected.." | `.system(size: 25, weight: .bold)` |
| `ControllerView` 제조사 이름 | `.system(size: 16, weight: .bold)` |
| `ControllerView` Refresh 버튼 | `.system(size: 24, weight: .semibold)` |
| `InfoView` 앱 이름 / 버전 | `.system(size: 25, weight: .bold)` / `.system(size: 20, weight: .bold)` |
| `SettingItemCell` 제목 / 우측 버튼 | `preferredFont(.body)` / `systemFont(ofSize: 24, weight: .semibold)` |
| `IAPOnboardingViewController` | `systemFont(ofSize: 40)`, `26`, `25`, `boldSystemFont(ofSize: 20)` |
| `TesterView` 상태 바 | `.subheadline` |
| Live Activity | `.caption`, `.caption2`, `.subheadline`, `.headline`, `.title3` |

---

## As-Is: Spacing / Layout

> ❌ **Spacing 토큰 미정의**. 4/8/16/24 같은 기준 스케일 없음.

| 위치 | 항목 | 값 |
|---|---|---|
| `ControllerView` | 로딩 영역 높이 | 120 |
| | 게임패드 아이콘 | 180 × 130 |
| | 원형 게이지 | 400 × 400 (작은 기기에서 화면을 넘을 수 있음) |
| | 배터리 텍스트 / 제조사 / 버튼 top padding | 36 / 57 / 20 |
| | Refresh 버튼 padding / corner | 10 / 10 |
| `ProgressBarView` / `ProgressBar` | 선 두께 | 11 |
| `InfoView` | 상단 여백 / 로고 / 하단 아이콘 / 하단 여백 | 100 / 150 / 50 / 80 |
| `TesterView` | stack spacing | 20, 40, 50, 100, 400 |
| | 카드 corner / shadow | 16 / 5 |
| Tester SubViews | 스틱 70·60, D-Pad 140, 트리거 폭 80 | |
| 위젯 | 게이지 padding | 40 |
| UIKit (`ImageButton`, 결제 버튼) | corner | 10 |

---

## As-Is: 이미지 / 아이콘

- 커스텀 이미지: `AppIcon.appiconset`, `AppLogo.imageset`
- **나머지는 SF Symbols** — `gamecontroller(.fill)`, `formfitting.gamecontroller(.fill)`, `gearshape(.fill)`, `arrow.clockwise`, `crown.fill`, `bell.badge`, `info.circle.fill`, `battery.0`~`battery.100`, `battery.100.bolt`
- 설정 행 아이콘은 `SettingItems.json`의 `typeImageName`으로 지정

---

## As-Is: Localization

✅ **구현됨** — ko / en / ja `Localizable.strings` + `InfoPlist.strings`. 접근은 `"key".localized`, `"key %@".localized(with:)` ([String+.swift](Controllers/Controllers/Sources/Extensions/String+.swift)).

**누락 / 하드코딩**:
- en·ja에 결제 안내 화면 키 8개가 없음: `Month Plan`, `Week Plan`, `Year Plan`, `Start Premium`, `Already Subscribing !`, `privacy Policy`, `termOfUse`, 구독 설명 문구 → 키 문자열이 그대로 노출됨
- `Current Battery is %@`는 ko에만 있고, 알림 문구가 `Battery is low %@`로 바뀐 뒤 사용처 없음
- 한국어 하드코딩: `TesterView` ("… 연결됨", "컨트롤러 연결 안됨"), 위젯 `configurationDisplayName` / `description`

---

## As-Is: 공통 컴포넌트 인벤토리

`DesignSystem` 폴더는 없고 컴포넌트가 기능 폴더에 흩어져 있습니다.

| 컴포넌트 | 위치 | 프레임워크 | 용도 |
|---|---|---|---|
| `ProgressBarView` | `Sources/Controller/ProgressBarView.swift` | SwiftUI | 메인 화면 원형 배터리 게이지 |
| `ProgressBar` | `ControllersWidget/ProgressBar.swift` | SwiftUI | 위젯 원형 게이지 — **`ProgressBarView`와 이름만 다른 동일 코드** |
| `LiveActivityFormat` | `ControllersWidget/ControllerLiveActivity.swift` | SwiftUI | 배터리 % 문자열·아이콘·색상 헬퍼 |
| `ControllerButton`, `DPadView`, `ThumbstickView`, `TriggerButtonView` | `Sources/Tester/SubViews/` | SwiftUI | Tester 탭 입력 시각화 |
| `SettingItemCell` | `Sources/Setting/` | UIKit | 설정 행 (아이콘 + 제목 + 우측 버튼 + NEW 배지) |
| `ImageButton` | `Sources/Component/` | UIKit | 결제 안내 화면 버튼 |

---

## To-Be: 정리 로드맵

우선순위 순. 각 항목은 별도 작업으로 분리 가능한 단위입니다.

### 🥇 1순위 — 배터리 색상 규칙 통일

Live Activity 추가로 같은 값이 세 군데서 다르게 계산됩니다. 규칙 하나로 모읍니다.

- 경계값 하나로 통일 (예: `< 0.2` red / `< 0.4` orange / 그 외 green)
- 앱·위젯 두 타깃이 쓰므로 `ControllerActivityAttributes`처럼 양쪽 멤버십 파일에 두거나 ControllerKit에 둠
- 원형 게이지(`ProgressBarView`)에도 같은 규칙 적용 여부 결정

### 🥈 2순위 — 다크모드 하드코딩 수정

- `TesterView` 카드 `Color.white.opacity(0.8)` → `Color(.secondarySystemBackground)` 등 시스템 컬러
- `InfoView` `.black` → `.primary`

### 🥉 3순위 — Localization 누락 채우기

- en·ja에 결제 안내 키 8개 추가
- `TesterView`, 위젯 문구를 로컬라이즈 키로 전환
- 미사용 키(`Current Battery is %@`) 제거
- `.xcstrings`(String Catalog)는 빌드 시 `.strings`로 변환되어 iOS 15 타깃에서도 사용 가능 — 키 누락을 Xcode가 표시해 주므로 전환 검토

### 4순위 — 중복 컴포넌트 / 미사용 자산 정리

- `ProgressBarView`와 `ProgressBar`를 파일 하나로 합치고 앱·위젯 두 타깃에 포함
- 미사용 `tabBarBackgroundColor`, `tabBarTintColor`, `UIColor.color(name:)` 제거 (또는 `TabView`에 실제 적용)

### 5순위 — 폰트 토큰

SwiftUI는 고정 크기보다 **텍스트 스타일(Dynamic Type)** 우선. 고정 크기가 꼭 필요한 곳만 토큰으로 둡니다.

```swift
// 제안: Sources/DesignSystem/Font+Token.swift
extension Font {
    enum Token {
        static let batteryValue = Font.system(size: 25, weight: .bold)   // ControllerView, InfoView
        static let button       = Font.system(size: 24, weight: .semibold)
    }
}
```

UIKit 화면(설정, 결제 안내)은 SwiftUI 전환 시 함께 정리하고, 그 전까지는 `preferredFont(forTextStyle:)` 사용.

### 6순위 — Spacing 토큰

8pt 그리드 기준.

```swift
// 제안: Sources/DesignSystem/Spacing.swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
```

**주의**: 120 / 180 / 400 같은 값은 여백이 아니라 컴포넌트 크기입니다. `ControllerView` 게이지 400×400은 고정값 대신 화면 폭 기준(`GeometryReader` 또는 `aspectRatio`)으로 바꾸는 것을 권장합니다.

---

## 명명 규칙

### 컬러
- 컴포넌트 종속: `{component}{Variant}Color` — 예: `tabBarBackgroundColor`
- 시맨틱: `{semantic}` — 예: `batteryLow`, `batteryMedium`, `batteryHigh`

### 폰트 토큰
- 역할 기반: `batteryValue`, `button`, `title` (크기 직접 표기 지양)

### Spacing
- 크기 스케일: `xs`, `sm`, `md`, `lg`, `xl`

### 이미지
- SF Symbols 우선
- 커스텀 이미지셋이 필요하면 `{domain}_{role}` 패턴 (예: `controller_dualsense`)

---

## 다크모드 정책

- **모든 신규 컬러는 Any Appearance + Dark Appearance 둘 다 정의 필수**
- 시스템 컬러(`.primary`, `.label`, `.systemBackground` 등)는 자동 대응되므로 우선 사용
- `.white`, `.black`, 하드코딩 RGB 사용 금지 — 필요하면 컬러셋으로 등록
- Live Activity 잠금화면 뷰는 배경이 고정(`black.opacity(0.6)`)이라 흰 글씨를 쓰는 예외 허용

---

*기준: `develop` + PR #15 + `Feature/charge-alert-enhancements` 작업 트리 · 최종 갱신: 2026-10-04*
