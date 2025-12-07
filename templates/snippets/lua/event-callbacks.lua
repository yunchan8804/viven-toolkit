---이벤트 콜백 시스템 (EventCallbacks 모듈 사용 예시)

--[[
    EventCallbacks 모듈 사용법:

    1. 모듈 가져오기
       MyCallback = ImportLuaScript(EventCallbacks)

    2. 콜백 등록
       MyCallback.register("eventName", callbackFunction)

    3. 콜백 호출
       MyCallback.invoke("eventName")
       MyCallback.invoke("eventName", param1, param2)

    4. 콜백 해제
       MyCallback.unregister("eventName", callbackFunction)
]]

-- 사용 예시 스크립트

GameCallback = ImportLuaScript(EventCallbacks)

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

---@type string
---@details 리스너 스크립트 이름
listenerScriptName = checkInject(listenerScriptName)
--endregion

--region Variables
---@type ListenerScript
local listenerScript = nil
--endregion

--region Unity Lifecycle
function awake()
    listenerScript = self:GetLuaComponentInChildren(listenerScriptName)
end

function onEnable()
    -- 콜백 등록
    GameCallback.register("onGameStart", onGameStartCallback)
    GameCallback.register("onGameEnd", onGameEndCallback)
    GameCallback.register("onScoreUpdate", onScoreUpdateCallback)
end

function onDisable()
    -- 콜백 해제
    GameCallback.unregister("onGameStart", onGameStartCallback)
    GameCallback.unregister("onGameEnd", onGameEndCallback)
    GameCallback.unregister("onScoreUpdate", onScoreUpdateCallback)
end
--endregion

--region Callback Handlers
function onGameStartCallback()
    Debug.Log("게임 시작 콜백 수신")
    -- 게임 시작 처리
end

function onGameEndCallback()
    Debug.Log("게임 종료 콜백 수신")
    -- 게임 종료 처리
end

function onScoreUpdateCallback(score)
    Debug.Log("점수 업데이트: " .. tostring(score))
    -- 점수 업데이트 처리
end
--endregion

--region Event Invokers
function TriggerGameStart()
    GameCallback.invoke("onGameStart")
end

function TriggerGameEnd()
    GameCallback.invoke("onGameEnd")
end

function TriggerScoreUpdate(newScore)
    GameCallback.invoke("onScoreUpdate", newScore)
end
--endregion
