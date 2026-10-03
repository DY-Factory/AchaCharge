# PLAN — 충전 알림 임계값 커스터마이즈 & Live Activity

> 작업 브랜치: `feature/charge-alert-enhancements` (`develop` 기반)
> 대상: [`forward_feature.md`](./forward_feature.md)의 ② / ③ 기능
> **완료 기준: 아래 모든 검증 조건 체크박스가 충족되면 작업 완료.**

## Context

`AchaCharge`는 게임 컨트롤러(DualSense) 배터리 충전 시기를 알려주는 iOS 앱이다.
현재 충전 알림은 임계값 개념 없이 백그라운드 태스크마다 무조건 발송되며,
배터리 상태는 홈 화면 위젯에서만 확인할 수 있다.
이 두 가지를 개선해 (1) 사용자가 알림 기준을 직접 정하고,
(2) 잠금화면·Dynamic Island에서 배터리를 상시 확인할 수 있게 한다.

### 확정된 결정 사항
- 브랜치: `develop` 기반 단일 브랜치 `feature/charge-alert-enhancements`
- 배포 타깃: 앱 최소 버전 **iOS 14.0 유지** + Live Activity 코드는 `@available(iOS 16.1, *)` 가드
- Live Activity 갱신: **로컬 업데이트** (ActivityKit, 별도 서버 없음)
- 게이팅: 두 기능 모두 **프리미엄(구독) 전용 유지** — 기존 알림 흐름과 일관

---

## 기능 2 — 충전 알림 임계값 커스터마이즈

### 현재 상태
- `FetchGameControllerOperation.swift`가 백그라운드 태스크에서 현재 배터리 레벨을
  무조건 알림으로 발송 — 임계값 비교 로직 없음 (`main()`, line 19-37)
- 알림 발송은 이미 구독자 전용 (`SceneDelegate` line 39 / `AppDelegate` line 84)
- 설정 화면은 UIKit `UITableView`, `SettingItems.json` 기반 데이터 구동
- 설정 저장은 App Group 공유 `UserDefaults`(`group.arex.achaCharge`), 키는 `StringKey+.swift`

### 구현 요구사항
1. `StringKey+.swift`에 `BATTERY_NOTIFICATION_THRESHOLD` 키 추가 (Int %, 기본값 20)
2. 설정 행 추가 — `SettingItems.json`에 "충전 알림 기준" 행 추가.
   기존 `SettingItemCell`(아이콘 + 라벨 + `buttonTitle`)을 재사용:
   - `buttonTitle`에 현재값("20%") 표시
   - `didSelectRowAt`에서 `UIAlertController(.actionSheet)`로 10/20/30/50% 선택지 제시
   - 새 셀 타입 불필요
3. 선택값을 `UserDefaults.shared`에 저장 → 앱 재실행 후에도 유지
4. `FetchGameControllerOperation.main()`에서 임계값을 읽어 `level <= threshold`일 때만
   `center.add(request)` 호출, 초과 시 알림 스킵
5. 알림 본문을 저전력 경고 문구로 변경("배터리가 %@ 입니다. 충전이 필요해요!")
   + `Localizable.strings`(ko/en) 항목 추가
6. 임계값 설정 행은 프리미엄 섹션에 배치 — 알림 흐름 자체가 이미 구독 전용이므로 일관 유지

### 검증 조건
- [ ] 설정 화면에 "충전 알림 기준" 행이 보이고 현재값이 표시된다
- [ ] 행 탭 시 10/20/30/50% 액션시트가 뜨고, 선택값이 앱 재실행 후에도 유지된다
- [ ] 임계값 30% 설정 후 백그라운드 태스크 시뮬레이션 시 배터리 ≤ 30%면 알림 발송,
      > 30%면 알림 미발송
      (LLDB: `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.controller.battery"]`)
- [ ] 알림 본문이 로컬라이즈된 저전력 경고 문구로 표시된다
- [x] `Controllers` 스킴 빌드 성공

### 수정 대상 파일
- `Controllers/Controllers/Sources/Extensions/StringKey+.swift`
- `Controllers/Controllers/Sources/Models/FetchGameControllerOperation.swift`
- `Controllers/Controllers/Sources/Setting/SettingViewController.swift`
- `Controllers/Controllers/Supporting Files/Assets.xcassets/SettingItems/SettingItems.dataset/SettingItems.json`
- `Localizable.strings` (ko/en)

---

## 기능 3 — Live Activity / Dynamic Island

### 현재 상태
- App Group `group.arex.achaCharge`가 앱·위젯 양쪽 entitlements에 이미 설정됨
- 위젯 익스텐션 `ControllersWidgetExtension`(`com.arex.achaCharge.widget`) — 홈 화면 위젯만 존재
- ActivityKit 사용 흔적 전무 — 충돌 없이 신규 도입 가능
- 앱 배포 타깃 iOS 14.0 → ActivityKit(16.1+)는 `@available` 가드 필요
- 배터리 데이터: `GameControllerManager.getBatteryInfo()` → `ControllerModel` → 공유 `UserDefaults`

### 구현 요구사항
1. 메인 앱 `Info.plist`에 `NSSupportsLiveActivities = YES` 추가
2. `ControllerActivityAttributes.swift` 신규 — `ActivityAttributes` 채택,
   `ContentState`에 `batteryLevel: Float`, `batteryState: Int`, `vendorName: String`.
   **앱 타깃 + 위젯 익스텐션 타깃 양쪽 멤버십** 필요, `@available(iOS 16.1, *)` 가드
3. 위젯 익스텐션에 Live Activity 위젯 추가 — `ActivityConfiguration`로
   잠금화면 뷰 + Dynamic Island(compact / minimal / expanded) 영역 구현,
   `ControllersWidgetBundle`에 `@available(iOS 16.1, *)`로 등록
4. 앱 타깃에 `LiveActivityManager` 추가 — ActivityKit 래핑:
   - `start()` — 컨트롤러 연결 시 `Activity.request`
   - `update(level:state:)` — `activity.update`
   - `end()` — 연결 해제 시 `activity.end`
   - 전부 `@available(iOS 16.1, *)`
5. `ControllerModel`에 연동 — 연결 시 start, `updateControllerInfo()` 시 update,
   해제 시 end. `FetchGameControllerOperation`(백그라운드)에서도 update 호출해 잠금화면 최신화
6. 프리미엄 게이팅 — `StoreKitManager.shared.isSubscribed`일 때만 Live Activity 시작
7. 배포 타깃 14.0 유지 — 모든 ActivityKit 코드는 `@available` + 런타임
   `if #available(iOS 16.1, *)` 가드
8. `project.pbxproj` 타깃 멤버십 갱신 — Attributes 파일은 양 타깃,
   Live Activity 위젯 파일은 위젯 익스텐션에 추가

### 검증 조건
- [x] `Controllers` 스킴 빌드 성공 (1.1.0부터 최소 iOS 15.0, Debug/Release)
- [ ] iOS 16.1+ 시뮬레이터에서 컨트롤러 연결 시(구독자) 잠금화면에 Live Activity 표시
- [ ] iPhone 15 Pro 시뮬레이터에서 Dynamic Island compact / expanded 배터리 뷰 표시
- [ ] 배터리 값 변경 시 Live Activity에 반영
- [ ] 컨트롤러 연결 해제 시 Live Activity 종료
- [ ] iOS 14/15 환경에서 앱 정상 동작, Live Activity 미표시, 크래시 없음 (@available 가드 검증)
- [ ] 비구독 사용자에서는 Live Activity가 시작되지 않음

### 수정 / 신규 대상 파일
- 신규 `Controllers/.../ControllerActivityAttributes.swift` (앱 + 위젯 공유)
- 신규 Live Activity 위젯 파일 (`Controllers/ControllersWidget/` 하위)
- `Controllers/ControllersWidget/ControllersWidgetBundle.swift`
- `Controllers/Controllers/Supporting Files/Info.plist`
- `Controllers/Controllers/Sources/Controller/ControllerModel.swift`
- `Controllers/Controllers/Sources/Models/FetchGameControllerOperation.swift`
- 신규 `LiveActivityManager.swift` (앱 타깃)
- `Controllers/Controllers.xcodeproj/project.pbxproj`

### 구현 시 주의
- `.xcodeproj` 직접 사용(Tuist 아님) → 신규 파일의 타깃 멤버십은 Xcode GUI 또는
  pbxproj 정밀 편집 필요. `ControllerActivityAttributes` 파일이 두 타깃 모두에
  속해야 컴파일됨
- 컨트롤러 실물 없이 시뮬레이터에서 배터리 변화 테스트가 어려움 →
  공유 `UserDefaults`의 `BATTERY_LEVEL` 값을 수동 주입해 검증

---

## 완료 기준

기능 2·3의 **모든 검증 조건 체크박스가 충족되면 작업 완료**로 간주한다.
