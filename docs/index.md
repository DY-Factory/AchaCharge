# docs/

> AchaCharge 프로젝트의 문서 카탈로그. 루트의 핵심 문서(`CLAUDE.md`, `ARCHITECTURE.md`, `DESIGN.md`)와 본 디렉토리에 누적되는 보조 문서들의 인덱스 역할을 합니다.

## 어디에 무엇이 있나

### 루트 문서 (핵심)

| 파일 | 역할 | 주 독자 |
|---|---|---|
| [../CLAUDE.md](../CLAUDE.md) | 빌드/실행 명령, 코드 컨벤션, 자주 쓰는 패턴 | Claude Code · 개발자 |
| [../ARCHITECTURE.md](../ARCHITECTURE.md) | 아키텍처 결정 기록(ADR-lite), 트레이드오프 | 개발자 · 리뷰어 |
| [../DESIGN.md](../DESIGN.md) | 디자인 토큰 As-Is 인벤토리 + 토큰화 로드맵 | 개발자 · 디자이너 |
| [../README.md](../README.md) | 외부용 앱 소개, 지원 기기 | 외부 방문자 |

### `docs/` 디렉토리 (보조)

현재 본 인덱스 외에 다른 문서는 없습니다. 향후 다음과 같은 주제별 상세 문서가 추가될 수 있습니다:

- `docs/iap-receipt-validation.md` — StoreKit 1 영수증 검증 흐름 상세 (`hotfix/1.0.12-iapverify` 머지 후)
- `docs/widget-data-flow.md` — App ↔ Widget 데이터 동기화 시퀀스
- `docs/macos-target.md` — macOS 타깃 분기 전략 (`Feature/macOSTarget` 머지 후)
- `docs/swiftui-migration.md` — UIKit → SwiftUI 전환 가이드 (`refactor/#8-uikit--swiftui` 머지 후)

신규 문서를 추가할 때는 위 표에 한 줄 등록하고 파일을 본 디렉토리에 작성하세요.

---

## 문서 작성 컨벤션

### 어디에 무엇을 적나

| 변경 종류 | 갱신 대상 |
|---|---|
| 새 아키텍처 결정 (UI 프레임워크, DI, 영속화, IAP 등) | `ARCHITECTURE.md`에 "결정 #N" 형식으로 추가 |
| 새 디자인 토큰 / 컴포넌트 도입 | `DESIGN.md`의 As-Is 인벤토리 + 명명 규칙 갱신 |
| 새 빌드 명령 / scheme / 환경 변수 | `CLAUDE.md`의 "빌드 / 실행 / 테스트" 섹션 |
| 특정 주제의 상세 가이드 (시퀀스, FAQ, 트러블슈팅 등) | `docs/{주제}.md` 신규 작성 + 본 인덱스에 등록 |
| 외부 사용자 안내 (앱 다운로드, 지원 기기 등) | `README.md` |

### 언어
- **본문은 한국어**로 작성합니다 (커밋 메시지·기존 README 일관성).
- 코드 식별자, API 이름, 기술 용어는 **영어 그대로** (예: `SKPaymentQueue`, `App Group`).

### 마크다운 스타일
- 제목은 `#` ~ `###` 3단계까지만. 더 깊은 계층은 글머리표·테이블로 표현.
- 파일 경로는 항상 백틱 코드 형식 또는 마크다운 링크 형식 `[표시명](경로)` 사용.
- 결정·상태 표는 GitHub Flavored Markdown 테이블 사용.

### 메타 정보
각 문서의 맨 아래에 다음 한 줄을 둡니다:

```
*기준 브랜치: <브랜치명> · 최종 갱신: YYYY-MM-DD*
```

큰 변경이 있을 때만 갱신. 매 커밋마다 손댈 필요 없음.

### 변경 이력
별도 `CHANGELOG.md`는 두지 않습니다. **Git log를 정본**으로 사용하세요.

---

## 진행 중인 브랜치와 문서 영향

문서가 영향받는 활성 브랜치 목록입니다. 머지될 때 어떤 문서를 갱신해야 하는지 미리 식별해 두었습니다.

| 브랜치 | 영향받는 문서 |
|---|---|
| `refactor/#8-uikit--swiftui` | `CLAUDE.md` (UI 컨벤션), `ARCHITECTURE.md` (결정 #1, #2, #3 재작성) |
| `Feature/macOSTarget` | `ARCHITECTURE.md` (결정 #5 갱신), `docs/macos-target.md` 신규 |
| `Feature/AccesorySetupKit` | `ARCHITECTURE.md` (결정 #9 갱신) |
| `hotfix/1.0.12-iapverify` | `ARCHITECTURE.md` (결정 #7 갱신), `docs/iap-receipt-validation.md` 신규 |

---

*기준 브랜치: `claude/happy-chaum-c8de73` · 최종 갱신: 2026-05-20*
