# 자주 발생하는 오류와 해결책

VIVEN SDK Lua 개발 시 자주 만나는 오류 패턴.

## Injection 관련

### "nth object is missing"
```
Error: 1th object is missing
```

**원인:** Inspector에서 오브젝트가 연결되지 않음

**해결:**
1. Unity Inspector에서 해당 Lua 스크립트 컴포넌트 확인
2. 누락된 오브젝트 슬롯에 GameObject 드래그
3. 변수명과 Inspector 슬롯명 일치 확인

```lua
-- 코드에서 TargetObject라면
---@type GameObject
local target = checkInject(TargetObject)  -- Inspector에도 TargetObject 슬롯 필요
```

---

## nil 참조 관련

### "attempt to index nil value"
```
Error: attempt to index nil value (local 'component')
```

**원인:** GetComponent가 nil 반환

**해결:**
1. 컴포넌트 이름 정확히 확인
2. awake()에서 캐싱하고 있는지 확인
3. 오브젝트에 해당 컴포넌트가 있는지 확인

```lua
-- ❌ 잘못된 예
function start()
    local btn = self:GetComponent("button")  -- 소문자!
end

-- ✅ 올바른 예
function awake()
    button = self:GetComponent("Button")  -- 정확한 이름
    if button == nil then
        Debug.LogWarning("Button not found!")
    end
end
```

### "attempt to call nil value"
```
Error: attempt to call nil value (method 'SomeMethod')
```

**원인:** 메서드가 존재하지 않거나 오타

**해결:**
1. API 문서에서 정확한 메서드명 확인
2. 대소문자 확인
3. 해당 버전에서 지원하는지 확인

---

## 네트워크 관련

### RPC가 호출되지 않음

**원인 1:** 함수가 전역이 아님
```lua
-- ❌ local 함수는 RPC 불가
local function MyRPC_Host()
end

-- ✅ 전역 함수로 정의
function MyRPC_Host()
end
```

**원인 2:** SyncView 미초기화
```lua
-- onSyncViewInitialized 이후에 RPC 사용
function onSyncViewInitialized()
    -- 이제 RPC 사용 가능
end
```

### 동기화 데이터가 nil

**원인:** nil이 포함된 테이블 전송 (nil strip)

```lua
-- ❌ nil이 있으면 strip됨
return { score, nil, name }

-- ✅ 배열 형태로 전송
return { score, "", name }  -- 빈 문자열 사용

-- ✅ 또는 JSON 직렬화
return { Util.JSON:encode(data) }
```

### Room 속성이 저장 안 됨

**원인:** string이 아닌 값 전달

```lua
-- ❌ 숫자 직접 전달
Room.SetRoomProp("score", 100)

-- ✅ 문자열로 변환
Room.SetRoomProp("score", tostring(100))
```

---

## 이벤트 관련

### 이벤트가 중복 호출됨

**원인:** 이벤트 해제 누락

```lua
-- ❌ 해제 안 함
function start()
    Util.EventBus:registerEvent("onScore", OnScore)
end

-- ✅ onDestroy에서 해제
function onDestroy()
    Util.EventBus:unregisterEvent("onScore", OnScore)
end
```

### 이벤트 핸들러가 호출 안 됨

**원인 1:** 이벤트 이름 오타
```lua
-- 등록: "onGameStart"
-- 발행: "onGamestart"  ← 대소문자 다름!
```

**원인 2:** 핸들러가 지역 함수
```lua
-- ❌ 지역 함수
local function OnScore(data)
end

-- ✅ 전역 함수
function OnScore(data)
end
```

---

## UI 관련

### UI 요소가 업데이트 안 됨

**원인:** update()에서 매 프레임 갱신

```lua
-- ❌ 비효율적
function update()
    scoreText.text = tostring(score)  -- 매 프레임!
end

-- ✅ 이벤트 기반
function OnScoreChanged(newScore)
    scoreText.text = tostring(newScore)
end
```

### Button 클릭이 안 됨

**원인 1:** Raycast 막힘
- Canvas 앞에 다른 UI 요소 확인
- Image의 Raycast Target 확인

**원인 2:** 리스너 미등록
```lua
function awake()
    button = self:GetComponent("Button")
end

function onEnable()
    button.onClick:AddListener(OnClick)  -- 등록!
end
```

---

## 성능 관련

### 프레임 드랍

**원인:** update()에서 할당

```lua
-- ❌ 매 프레임 테이블 생성
function update()
    local data = { score = 1, name = "test" }
end

-- ✅ 캐싱
local cachedData = { score = 0, name = "" }
function update()
    cachedData.score = 1
end
```

### 메모리 누수

**원인:** 코루틴 미정리

```lua
local routine = nil

function startRoutine()
    routine = self:StartCoroutine(...)
end

-- ❌ 정리 안 함

-- ✅ onDisable에서 정리
function onDisable()
    if routine then
        self:StopCoroutine(routine)
        routine = nil
    end
end
```

---

## 디버깅 팁

### 로그 출력
```lua
Debug.Log("일반 로그")
Debug.LogWarning("경고")
Debug.LogError("에러")

-- 테이블 출력
Debug.Log(Util.JSON:encode(myTable))
```

### Host/Client 구분 로그
```lua
local prefix = SyncView.IsMine and "[HOST]" or "[CLIENT]"
Debug.Log(prefix .. " 메시지")
```

### nil 체크
```lua
if component == nil then
    Debug.LogError("Component is nil!")
    return
end
```
