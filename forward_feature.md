# AchaCharge — 기능 제안 백로그 (forward_feature)

게임 컨트롤러(DualSense) 충전 시기 알림 앱 `AchaCharge`의 향후 기능 후보 목록.
현재 코드 구조 위에 자연스럽게 얹을 수 있는 기능들을 우선순위 감각으로 정리했다.

> ②번(충전 알림 임계값 커스터마이즈), ③번(Live Activity / Dynamic Island)은
> `feature/charge-alert-enhancements` 브랜치에서 작업 진행 중 — 상세 계획은 [`PLAN.md`](./PLAN.md) 참고.

---

## 1. 핵심 기능 강화 (앱 정체성)

| # | 기능 | 설명 | 추정 진입점 |
|---|---|---|---|
| ① | 배터리 히스토리 그래프 | 시간대별 잔량 변화를 차트로 시각화(Swift Charts). 충전 패턴을 눈으로 보여 "충전 시기 알림" 앱의 설득력 확보 | `ControllerView.swift`, 신규 `BatteryHistoryStore` |
| ② | 충전 알림 임계값 커스터마이즈 | 고정된 알림 기준을 사용자가 10/20/30/50% 등으로 직접 설정 | `FetchGameControllerOperation.swift`, `SettingViewController.swift` |
| ③ | Live Activity / Dynamic Island | 잠금화면·Dynamic Island에 컨트롤러 배터리 표시. 이 앱의 가장 자연스러운 노출 포인트 | `ControllersWidget/`, 신규 `LiveActivityManager` |
| ④ | 사용 패턴 학습 기반 추천 | "보통 화요일 저녁 게임 → 월요일 밤 충전 권장" 같은 인사이트 제공 | 신규 분석 모듈, `BatteryHistoryStore` |

## 2. TesterView 확장 (방금 만든 기능 위에)

| # | 기능 | 설명 | 추정 진입점 |
|---|---|---|---|
| ⑤ | 진동 / 햅틱 테스트 | `GCController.haptics`, DualSense 어댑티브 트리거 테스트 | `TesterView.swift`, `ControllerKit` |
| ⑥ | LED 색상 변경 | DualSense 라이트바 색상 조정 (`GCDualSenseAdaptiveTrigger` 등) | `ControllerKit/GameControllerManager.swift` |
| ⑦ | 입력 지연(latency) 측정 | 버튼 누름 → 화면 반영까지 ms 측정. 컨트롤러/블루투스 품질 진단 | `TesterModel.swift` |
| ⑧ | 버튼 매핑 시각화 모드 | 입력 로그를 시간축에 펼쳐 표시 (커맨드 연습용 응용 가능) | `TesterView.swift`, `ControllerInput.swift` |

## 3. 확장성

| # | 기능 | 설명 | 추정 진입점 |
|---|---|---|---|
| ⑨ | Xbox / Switch Pro 컨트롤러 지원 | 현재 DualSense만 지원. `GCExtendedGamepad`로 추상화 | `ControllerKit/GameControllerManager.swift` |
| ⑩ | 다중 컨트롤러 동시 추적 | 컨트롤러 여러 개를 동시에 모니터링 | `GameControllerManager.swift`, `ControllerModel.swift` |
| ⑪ | Apple Watch 컴플리케이션 | 손목에서 컨트롤러 배터리 즉시 확인 | 신규 watchOS 타깃 |

---

## 우선순위 메모

- **임팩트 최대 묶음**: ② + ③ (알림 임계값 + Live Activity) — 앱 정체성을 직접 강화
- **현재 브랜치 자연 확장**: ⑤, ⑦ — TesterView 위에 바로 붙음
- **차별화 포인트**: ④ (사용 패턴 학습 기반 추천)

## 진행 현황

- [x] ② 충전 알림 임계값 커스터마이즈 — 1.1.0 출시 (#16)
- [x] ③ Live Activity / Dynamic Island — 1.1.0 출시 (#16, #17)
- 그 외 항목: 미착수 (백로그)
