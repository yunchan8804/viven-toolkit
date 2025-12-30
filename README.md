# VIVEN SDK Claude Toolkit

VIVEN SDK로 Lua 콘텐츠를 개발할 때 AI 코딩 어시스턴트(Claude Code, Cursor)가 더 똑똑하게 도와줄 수 있도록 만든 toolkit입니다.

## 이게 뭔가요?

AI가 VIVEN SDK를 이해하고, 올바른 패턴으로 코드를 생성할 수 있게 해주는 **컨텍스트 파일 모음**입니다.

**Without Toolkit:**
```
사용자: "멀티플레이어 점수 시스템 만들어줘"
Claude: (일반적인 Unity 코드 생성, VIVEN SDK 패턴 모름)
```

**With Toolkit:**
```
사용자: "멀티플레이어 점수 시스템 만들어줘"
Claude: (Host/Client 분리, RPC 패턴, checkInject 등 VIVEN SDK 규칙 준수)
```

## Quick Start

### 1. Claude Code에서 사용

```bash
# toolkit 폴더에서 Claude Code 실행
cd viven-sdk-claude-toolkit
claude
```

또는 기존 프로젝트에서:
```
> @path/to/viven-sdk-claude-toolkit/CLAUDE.md 참고해서 작업해줘
```

### 2. 코드 생성 요청

```
> 멀티플레이어 점수 시스템 만들어줘
> /viven:multiplayer 템플릿으로 시작해줘
```

→ 상세 사용법: [USAGE.md](./USAGE.md)

## 파일 구조

```
viven-sdk-claude-toolkit/
│
├── CLAUDE.md              # Claude가 읽는 핵심 가이드 (핵심!)
├── README.md              # 이 파일
├── USAGE.md               # 상세 사용 가이드
│
├── rules/                 # 코딩 규칙 문서
│   ├── lua-style.md       # Lua 코딩 스타일
│   ├── network-patterns.md # Host/Client, RPC, Sync
│   └── common-errors.md   # 자주 하는 실수 & 해결책
│
├── snippets/lua/          # 코드 스니펫 & 템플릿
│   ├── multiplayer-template.lua   # Host/Client RPC
│   ├── ui-panel-template.lua      # UI 패널
│   ├── sync-data-template.lua     # 동기화 테이블
│   ├── player-control.lua
│   ├── room-control.lua
│   ├── xr-control.lua
│   └── ...
│
├── generated/             # 자동 생성된 API 참조
└── scripts/               # 유틸리티 스크립트
```

## 주요 기능

### 📋 코딩 규칙
| 문서 | 내용 |
|------|------|
| `rules/lua-style.md` | checkInject, 네이밍, 생명주기 |
| `rules/network-patterns.md` | Host/Client, RPC, 동기화 |
| `rules/common-errors.md` | 자주 하는 실수 & 해결책 |

### 📝 코드 템플릿
| 템플릿 | 용도 |
|--------|------|
| `multiplayer-template.lua` | Host/Client RPC 구조 |
| `ui-panel-template.lua` | Show/Hide/Refresh 패턴 |
| `sync-data-template.lua` | isDirty/캐시 동기화 |

### 🔧 슬래시 커맨드

**템플릿 생성:**
- `/viven:multiplayer` - Host/Client 구조
- `/viven:ui-panel` - UI 패널
- `/viven:sync-data` - 동기화 테이블

**가이드:**
- `/viven:docs [topic]` - 온라인 문서 조회
- `/viven:troubleshoot` - 문제 해결
- `/viven:xr` - XR/VR 가이드
- `/viven:rpc` - RPC 시스템
- `/viven:room` - Room 속성

**초기화:**
- `/viven:init` - 새 VObject
- `/viven:lua-script` - Lua 스크립트
- `/viven:grabbable` - Grabbable 설정

## 핵심 패턴 미리보기

### Host/Client 분리
```
Client (입력) → RPC → Host (판정) → RPC → All Clients (시각화)
```

### 의존성 주입
```lua
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

local Target = checkInject(TargetObject)
```

### 이벤트 해제 필수
```lua
function start()
    Util.EventBus:registerEvent("onScore", OnScore)
end

function onDestroy()
    Util.EventBus:unregisterEvent("onScore", OnScore)  -- 필수!
end
```

## 관련 문서

- [VIVEN Developer Wiki](https://wiki.viven.app/developer)
- [VIVEN SDK API Reference](https://sdkdoc.viven.app/api/SDK/TwentyOz.VivenSDK)

## 요구사항

- Unity 6000.0+
- VIVEN SDK
- Claude Code 또는 Cursor

## 라이선스

TwentyOz 내부 사용
