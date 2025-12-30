# Lua 코딩 스타일 가이드

VIVEN SDK Lua 스크립트 작성 시 따라야 할 규칙.

## 필수 패턴

### 의존성 주입 (Injection)
모든 외부 오브젝트는 반드시 검증 후 사용.

```lua
--region Injection list
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

---@type GameObject
local TargetObject = checkInject(TargetObject)
_ORDER = 0
--endregion
```

**규칙:**
- 필수 의존성: `checkInject()` 사용
- 선택 의존성: `NullableInject()` 사용
- 주입 후 `_ORDER = 0` 리셋

### 타입 어노테이션
모든 주입 변수와 주요 함수에 타입 명시.

```lua
---@type GameObject
local target = checkInject(Target)

---@param amount number
---@return boolean
function AddScore(amount)
    -- ...
end
```

### 리전 구조화
코드를 논리적 블록으로 구분.

```lua
--region Injection list
--endregion

--region State
local score = 0
local isActive = false
--endregion

--region Lifecycle
function awake() end
function start() end
--endregion

--region Public API
--endregion

--region Event Handlers
--endregion
```

## 생명주기 규칙

| 함수 | 용도 | 하지 말 것 |
|------|------|-----------|
| `awake()` | GetComponent, 캐싱 | 다른 오브젝트 참조 |
| `start()` | 초기화, 이벤트 등록 | 무거운 로직 |
| `onEnable()` | 이벤트 리스너 등록 | |
| `onDisable()` | 이벤트 리스너 해제 | |
| `onDestroy()` | 정리, EventBus 해제 | |
| `update()` | 프레임 로직 | 할당, 문자열 생성 |

## 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 지역 변수 | camelCase | `local playerScore` |
| 함수 (Public) | PascalCase | `function GetScore()` |
| 함수 (Unity 콜백) | camelCase | `function awake()` |
| 상수 | UPPER_SNAKE | `local MAX_HEALTH = 100` |
| 주입 변수 | PascalCase + Object | `TargetObject` |

## 금지 사항

### update()에서 하지 말 것
```lua
-- ❌ 나쁜 예
function update()
    local msg = "Score: " .. score  -- 매 프레임 문자열 생성
    local players = {}              -- 매 프레임 테이블 생성
end

-- ✅ 좋은 예
local cachedMsg = ""
local players = {}

function update()
    -- 캐시된 변수 사용
end
```

### Rigidbody 직접 접근 금지
```lua
-- ❌ 금지
local rb = self:GetComponent("Rigidbody")
rb.velocity = Vector3(0, 10, 0)

-- ✅ 올바른 방법
local rbModule = self:GetComponent("VivenRigidbodyControlModule")
rbModule:SetVelocity(Vector3(0, 10, 0))
```

## 이벤트 처리

### EventBus 패턴
```lua
function start()
    Util.EventBus:registerEvent("onGameStart", OnGameStart)
end

function onDestroy()
    -- 반드시 해제!
    Util.EventBus:unregisterEvent("onGameStart", OnGameStart)
end

function OnGameStart()
    -- 핸들러
end
```

### Unity 이벤트 리스너
```lua
function onEnable()
    button.onClick:AddListener(OnButtonClick)
end

function onDisable()
    button.onClick:RemoveListener(OnButtonClick)
end
```

## 참조

- 기본 스크립트 구조: `snippets/lua/basic-script.lua`
- 이벤트 콜백: `snippets/lua/event-callbacks.lua`
