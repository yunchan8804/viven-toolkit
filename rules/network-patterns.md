# 네트워크 패턴 가이드

VIVEN SDK 멀티플레이어 개발을 위한 핵심 패턴.

## Host/Client 분리 원칙

```
┌─────────────────┐     RPC     ┌─────────────────┐
│     Client      │ ─────────→ │      Host       │
│   (입력/요청)   │             │ (판정/상태변경) │
└─────────────────┘             └─────────────────┘
         ↑                              │
         │          RPC (결과)          │
         └──────────────────────────────┘
                      ↓
              ┌─────────────────┐
              │  All Clients    │
              │ (시각화/이펙트) │
              └─────────────────┘
```

### 역할 분담

| 역할 | Host | Client |
|------|------|--------|
| 데이터 변경 | ✅ | ❌ |
| 게임 판정 | ✅ | ❌ |
| 상태 머신 틱 | ✅ | ❌ |
| 입력 수집 | - | ✅ |
| 시각화/이펙트 | ✅ | ✅ |
| UI 업데이트 | ✅ | ✅ |

### 함수 네이밍 규칙

```lua
-- 클라이언트 → Host 요청
function DoSomething()
    RPC_Server("DoSomething_Host", params)
end

-- Host에서 처리
function DoSomething_Host(params)
    -- 판정, 상태 변경
    RPC_Client("OnSomethingDone_Client", result)
end

-- 모든 클라이언트에서 시각화
function OnSomethingDone_Client(result)
    -- 이펙트, UI 업데이트
end
```

→ 템플릿: `snippets/lua/multiplayer-template.lua`

## RPC 유틸리티

### 기본 RPC 함수
```lua
-- Host에게 전송
function RPC_Server(functionName, ...)
    local params = { ... }
    SyncView:SendTargetRPC(functionName, { SyncView.ControlUserId }, params)
end

-- 모든 클라이언트에게 전송
function RPC_Client(functionName, ...)
    local params = { ... }
    SyncView:SendRPC(functionName, RPCSendOption.All, params)
end
```

### RPCSendOption
| 옵션 | 설명 |
|------|------|
| `RPCSendOption.All` | 모든 플레이어 (나 포함) |
| `RPCSendOption.Others` | 나를 제외한 모든 플레이어 |

→ 참조: `snippets/lua/rpc-system.lua`

## 동기화 테이블 패턴

### 핵심 원칙
1. **배열 테이블 사용** - nil strip 방지
2. **isDirty + 캐시** - 불필요한 전송 최소화
3. **Host 자체 적용** - receiveSyncUpdate 호출

### 구조
```lua
local isDirty = true
local cachedSyncTable = nil

-- Host가 호출 (데이터 전송)
function sendSyncUpdate()
    if not isDirty then
        return cachedSyncTable or {}
    end

    cachedSyncTable = {}
    -- JSON으로 직렬화하여 한 칸에
    table.insert(cachedSyncTable, Util.JSON:encode(data))

    isDirty = false
    receiveSyncUpdate(cachedSyncTable)  -- Host 자신에게도!
    return cachedSyncTable
end

-- 모든 클라이언트가 호출 (데이터 수신)
function receiveSyncUpdate(syncTable)
    if #syncTable == 0 then return end
    local data = Util.JSON:decode(syncTable[1])
    -- 시각화 업데이트
end
```

→ 템플릿: `snippets/lua/sync-data-template.lua`

## Room 속성

### 사용법
```lua
-- 설정 (값은 반드시 string!)
Room.SetRoomProp("Host_Score", tostring(score))

-- 읽기
local value = Room.GetRoomProp("Host_Score")
local score = tonumber(value) or 0
```

### 네이밍 컨벤션
| 패턴 | 용도 | 예시 |
|------|------|------|
| `Host_*` | Host 관리 데이터 | `Host_CurrentRound` |
| `{playerId}_*` | 플레이어별 데이터 | `abc123_Score` |
| `Lobby_*` | 로비 상태 | `Lobby_HostId` |

→ 참조: `snippets/lua/room-control.lua`

## Host 확인

```lua
-- SyncView 기반
local isHost = SyncView.IsMine

-- update에서 Host만 실행
function update()
    if not SyncView.IsMine then return end
    -- Host 로직
end
```

## 체크리스트

- [ ] 데이터 변경은 Host에서만
- [ ] Client는 RPC로 요청만
- [ ] 함수명에 `_Host`, `_Client` 접미사
- [ ] 동기화 테이블은 배열로
- [ ] Room 속성은 string으로
- [ ] Host는 자신에게도 receiveSyncUpdate 호출
