# VIVEN SDK Toolkit 사용 가이드

Claude Code, Cursor 등 AI 코딩 어시스턴트에서 이 toolkit을 활용하는 방법.

---

## Claude Code에서 사용하기

### 방법 1: 작업 디렉토리로 열기 (권장)

```bash
# toolkit 폴더에서 Claude Code 실행
cd path/to/viven-sdk-claude-toolkit
claude
```

Claude가 자동으로 `CLAUDE.md`를 읽고 VIVEN SDK 전문가가 됩니다.

### 방법 2: 기존 프로젝트에서 컨텍스트 추가

```bash
# 내 Unity 프로젝트에서
cd my-viven-project
claude

# Claude Code 내에서
> @path/to/viven-sdk-claude-toolkit/CLAUDE.md 이 가이드 참고해서 작업해줘
```

### 방법 3: 파일 직접 참조

특정 파일만 필요할 때:
```
> @viven-sdk-claude-toolkit/rules/network-patterns.md 이 패턴대로 RPC 구현해줘
> @viven-sdk-claude-toolkit/snippets/lua/multiplayer-template.lua 이거 기반으로 만들어줘
```

---

## Cursor에서 사용하기

### 방법 1: .cursorrules에 추가

프로젝트 루트에 `.cursorrules` 생성:
```
# VIVEN SDK 개발 규칙
@import path/to/viven-sdk-claude-toolkit/CLAUDE.md
```

### 방법 2: 프로젝트에 복사

```bash
# toolkit을 프로젝트에 복사
cp -r viven-sdk-claude-toolkit/.  my-project/.viven-toolkit/
```

---

## 슬래시 커맨드 사용법

### 템플릿 생성

**멀티플레이어 시스템:**
```
> /viven:multiplayer 점수 관리 시스템 만들어줘
```
→ Host/Client 분리된 RPC 구조 생성

**UI 패널:**
```
> /viven:ui-panel 상점 UI 만들어줘
```
→ Show/Hide/Refresh 패턴의 UI 패널 생성

**동기화 데이터:**
```
> /viven:sync-data 플레이어 상태 동기화 만들어줘
```
→ isDirty/캐시 패턴의 동기화 테이블 생성

### 가이드 조회

**문제 해결:**
```
> /viven:troubleshoot "nth object is missing" 에러 해결해줘
```

**특정 주제:**
```
> /viven:docs grabbable
> /viven:xr 컨트롤러 진동 어떻게 해?
> /viven:room 속성 설정하는 법
```

---

## 실제 사용 시나리오

### 시나리오 1: 새 멀티플레이어 게임 시작

```
사용자: 2인용 퀴즈 게임 만들고 싶어.
       Host가 문제 출제하고, 정답 맞추면 점수 올라가는 구조로.

Claude: (toolkit 참조하여)
       1. multiplayer-template.lua 기반 구조 생성
       2. Host/Client 분리 적용
       3. Room 속성으로 게임 상태 관리
       4. RPC로 정답 체크 및 점수 동기화
```

### 시나리오 2: 기존 코드 디버깅

```
사용자: 이 에러 왜 나는지 모르겠어
       "attempt to index nil value (local 'button')"

Claude: (rules/common-errors.md 참조하여)
       원인: GetComponent가 nil 반환
       해결:
       1. 컴포넌트 이름 확인 ("button" → "Button")
       2. awake()에서 캐싱하고 있는지 확인
       3. 오브젝트에 Button 컴포넌트 있는지 확인
```

### 시나리오 3: 패턴 적용

```
사용자: 이 코드 VIVEN SDK 패턴에 맞게 리팩토링해줘
       [기존 코드 붙여넣기]

Claude: (rules/lua-style.md 참조하여)
       1. checkInject 패턴 적용
       2. 리전 구조화
       3. 타입 어노테이션 추가
       4. 이벤트 해제 누락 수정
```

---

## 팁 & 트릭

### 1. 구체적으로 요청하기

```
# ❌ 너무 추상적
> 게임 만들어줘

# ✅ 구체적
> Host가 라운드 시작하면 모든 클라이언트에 타이머 표시되고,
> 시간 끝나면 점수 집계해서 결과 UI 보여주는 구조로 만들어줘
```

### 2. 템플릿 먼저 요청

```
> /viven:multiplayer 기본 구조 먼저 만들어줘
> (생성된 코드 확인 후)
> 여기에 아이템 시스템 추가해줘
```

### 3. 에러 전체 복사

```
# ❌ 일부만
> nil 에러 나

# ✅ 전체 에러 메시지
> 이 에러 해결해줘:
> LuaException: [string "MyScript"]:45: attempt to index nil value (local 'syncView')
```

### 4. 파일 참조 활용

```
> @rules/network-patterns.md 이 패턴 중에서
> 내 상황(실시간 위치 동기화)에 맞는 거 추천해줘
```

---

## 자주 묻는 질문

### Q: CLAUDE.md를 직접 수정해도 되나요?

네. 프로젝트에 맞게 커스터마이징하세요. 단, 원본은 백업해두세요.

### Q: 새 스니펫 추가하고 싶어요

`snippets/lua/`에 `.lua` 파일 추가하고, `CLAUDE.md`의 템플릿 목록에 추가하세요.

### Q: Cursor랑 Claude Code 중 뭐가 좋아요?

둘 다 잘 동작합니다. 이미 쓰고 있는 걸 사용하세요.

### Q: 오프라인에서도 동작하나요?

toolkit 자체는 로컬 파일이라 오프라인 OK. 단, Claude/Cursor는 인터넷 필요.

---

## 문제 해결

### Claude가 CLAUDE.md를 안 읽는 것 같아요

1. 작업 디렉토리 확인: toolkit 폴더에서 실행했는지
2. 명시적 참조: `@CLAUDE.md 이거 읽고 작업해줘`
3. 컨텍스트 리셋: `/clear` 후 다시 시작

### 슬래시 커맨드가 안 돼요

슬래시 커맨드는 Claude에게 "이런 식으로 해줘"라는 **힌트**입니다.
실제로 실행되는 게 아니라, Claude가 해석해서 처리합니다.

```
# 이렇게 요청하세요
> /viven:multiplayer 패턴으로 채팅 시스템 만들어줘
```

### 생성된 코드가 이상해요

1. 구체적인 요구사항 추가
2. `@rules/lua-style.md` 명시적 참조
3. 생성된 코드 + 문제점 설명하고 수정 요청
