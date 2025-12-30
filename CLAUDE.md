# VIVEN SDK 개발 가이드

TwentyOz의 VIVEN SDK 기반 Unity VR 메타버스 콘텐츠 개발을 위한 Claude Code 툴킷.

## 온라인 문서

- **Wiki**: https://wiki.viven.app/developer
- **API Reference**: https://sdkdoc.viven.app/api/SDK/TwentyOz.VivenSDK
- **VObject 가이드**: https://wiki.viven.app/developer/contents/vobject
- **Scripting 가이드**: https://wiki.viven.app/developer/dev-guide/viven-script

---

## Quick Start

### 기본 스크립트 구조
→ 참조: `snippets/lua/basic-script.lua`

```lua
--region Injection list
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

---@type GameObject
local Target = checkInject(TargetObject)
_ORDER = 0
--endregion

function awake()
    -- GetComponent 캐싱
end

function start()
    -- 초기화, 이벤트 등록
end

function onDestroy()
    -- 이벤트 해제
end
```

### 핵심 규칙 (3가지)
1. **모든 외부 오브젝트는 `checkInject()`로 검증**
2. **이벤트는 등록하면 반드시 해제** (`onDestroy`)
3. **Host만 데이터 변경, Client는 시각화만**

→ 상세 규칙: `rules/lua-style.md`

---

## 가이드 문서

| 문서 | 설명 |
|------|------|
| `rules/lua-style.md` | Lua 코딩 스타일, 네이밍, 생명주기 |
| `rules/network-patterns.md` | Host/Client, RPC, 동기화 테이블 |
| `rules/common-errors.md` | 자주 발생하는 오류와 해결책 |

---

## 핵심 아키텍처

### 컴포넌트 계층
```
VObject (네트워크 동기화 기반)
    ↓
VivenGrabbableModule (잡기 가능)
    + VivenRigidbodyControlModule
    + VivenGrabbableRigidView
    ↓
VivenLuaBehaviour (Lua 스크립트)
```

### 필수 컴포넌트 조합

| 기능 | 필수 컴포넌트 |
|------|--------------|
| 네트워크 동기화 | VObject + VivenTransformView |
| 잡기 가능 | VObject + VivenGrabbableModule + VivenRigidbodyControlModule |
| 앉기 가능 | VObject + VivenSittable + Collider |

### Host/Client 분리
```
Client (입력) → RPC → Host (판정) → RPC → All Clients (시각화)
```
→ 상세: `rules/network-patterns.md`
→ 템플릿: `snippets/lua/multiplayer-template.lua`

---

## 전역 API 요약

### 플레이어
```lua
Player.Mine.UserID              -- 내 유저 ID
Player.Mine.Nickname            -- 닉네임
Player.Mine.PlayMode            -- "PC" | "XR" | "Mobile"
Player.Mine.TeleportPlayer(pos, rot)
Player.Mine.CharacterMoveLock = true/false
```
→ 상세: `snippets/lua/player-control.lua`

### 룸
```lua
Room.SetRoomProp("key", "value")  -- 값은 반드시 string!
Room.GetRoomProp("key")
Room.LeaveRoom()
Room.CurrentRoomPlayers
```
→ 상세: `snippets/lua/room-control.lua`

### UI
```lua
UI.ToastMessage("메시지")
UI.ToastWarningMessage("경고")
UI.FadeIn(duration, callback)
UI.FadeOut(duration, callback)
UI.OpenDock() / UI.CloseDock()
```
→ 상세: `snippets/lua/ui-control.lua`

### XR
```lua
XR.IsXRMode()
XR.StartControllerVibration(isLeft, amplitude, duration)
XR.StopControllerVibration(isLeft)
```
→ 상세: `snippets/lua/xr-control.lua`

### EventBus
```lua
Util.EventBus:registerEvent("eventName", handler)
Util.EventBus:invokeEvent("eventName", data)
Util.EventBus:unregisterEvent("eventName", handler)  -- 필수!
```

---

## 템플릿 (복붙용)

| 파일 | 용도 |
|------|------|
| `snippets/lua/multiplayer-template.lua` | Host/Client RPC 전체 구조 |
| `snippets/lua/ui-panel-template.lua` | UI 패널 (Show/Hide/Refresh) |
| `snippets/lua/sync-data-template.lua` | 동기화 테이블 (isDirty/캐시) |
| `snippets/lua/basic-script.lua` | 기본 스크립트 구조 |

---

## 슬래시 커맨드

### 초기화/생성
- `/viven:init` - 새 VObject 초기화
- `/viven:lua-script` - Lua 스크립트 생성
- `/viven:grabbable` - Grabbable 오브젝트 설정
- `/viven:component` - 컴포넌트 추가 가이드

### 네트워크
- `/viven:network` - 네트워크 동기화 설정
- `/viven:rpc` - RPC 시스템 설정
- `/viven:room` - Room 속성/이벤트 가이드
- `/viven:host-client` - Host-Client 아키텍처

### 템플릿 생성
- `/viven:multiplayer` - Host/Client 템플릿
- `/viven:ui-panel` - UI 패널 템플릿
- `/viven:sync-data` - 동기화 테이블 템플릿

### 기타
- `/viven:xr` - XR/VR 컨트롤러 가이드
- `/viven:player-input` - 플레이어 입력 제어
- `/viven:recording` - 화면 녹화 시스템
- `/viven:step` - IStep 게임 플로우
- `/viven:docs [topic]` - 온라인 문서 조회
- `/viven:troubleshoot` - 문제 해결 가이드

---

## 자주 하는 실수

| 증상 | 원인 | 해결 |
|------|------|------|
| "nth object is missing" | Inspector 연결 누락 | 오브젝트 드래그 연결 |
| RPC 호출 안 됨 | 함수가 local | 전역 함수로 변경 |
| Room 속성 저장 안 됨 | string 아닌 값 | `tostring()` 사용 |
| 이벤트 중복 호출 | 해제 누락 | `onDestroy`에서 해제 |
| 동기화 데이터 nil | nil strip | 배열 또는 JSON 사용 |

→ 상세: `rules/common-errors.md`

---

## API 변경 이력

### Deprecated (사용 지양)
| API | 대체 방안 |
|-----|----------|
| `UI.SetUIMode(bool)` | 지원 중단 |
| `Player.Mine.PlayEmote()` | `SDKCustomAnimationModule` 사용 |

### 신규 API (2025-12)
| API | 설명 |
|-----|------|
| `Player.Mine.AddMoveInput(Vector2)` | 이동 입력 |
| `Player.Mine.AddViewInput(Vector2)` | 시선 입력 |
| `Room.LeaveRoom()` | 방 나가기 |
| `UI.OpenDock()` / `CloseDock()` | 독 제어 |
| `XR.StartControllerVibration()` | VR 진동 |

---

## 파일 구조

```
viven-sdk-claude-toolkit/
├── CLAUDE.md              ← 이 파일 (핵심 개요)
├── rules/
│   ├── lua-style.md       ← Lua 코딩 규칙
│   ├── network-patterns.md ← 네트워크 패턴
│   └── common-errors.md   ← 오류 해결
├── snippets/lua/          ← 코드 스니펫
│   ├── basic-script.lua
│   ├── multiplayer-template.lua
│   ├── ui-panel-template.lua
│   ├── sync-data-template.lua
│   ├── player-control.lua
│   ├── room-control.lua
│   ├── xr-control.lua
│   ├── ui-control.lua
│   └── ...
├── generated/             ← 자동 생성 (API 참조)
└── scripts/               ← 동기화 스크립트
```

---

## 필수 패키지

```
com.unity.xr.openxr: 1.14.0+
com.unity.xr.hands: 1.5.0+
com.unity.xr.interaction.toolkit: 3.0.7+
com.unity.inputsystem: 1.13.1+
```
