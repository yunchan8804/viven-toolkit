---네트워크 이벤트와 통합된 콜백 시스템 템플릿

--[[
    Lua 내부 이벤트 시스템과 네트워크 RPC를 통합하여
    로컬 이벤트와 네트워크 이벤트를 일관된 방식으로 처리합니다.
]]

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

---@type GameObject
---@details VivenCustomSyncView를 가진 오브젝트
SyncViewObject = checkInject(SyncViewObject)
--endregion

--region 이벤트 콜백 시스템

---@class NetworkEventCallback
---@field _events table<string, fun(...: any)[]>
local EventCallback = {}
EventCallback._events = {}

--- 이벤트 핸들러 등록
---@param eventName string
---@param handler fun(...: any)
function EventCallback.registerEvent(eventName, handler)
    if EventCallback._events[eventName] == nil then
        EventCallback._events[eventName] = { handler }
    else
        table.insert(EventCallback._events[eventName], handler)
    end
end

--- 이벤트 발생 (로컬)
---@param eventName string
---@param ... any
function EventCallback.invoke(eventName, ...)
    if EventCallback._events[eventName] then
        for _, handler in ipairs(EventCallback._events[eventName]) do
            local success, result = pcall(handler, ...)
            if not success then
                Debug.Log("ERROR: " .. tostring(eventName) .. " 이벤트 핸들러 오류 - " .. tostring(result))
            end
        end
    end
end

--- 이벤트 핸들러 해제
---@param eventName string
---@param handler fun(...: any)
function EventCallback.unregisterEvent(eventName, handler)
    if EventCallback._events[eventName] then
        for i, registeredHandler in ipairs(EventCallback._events[eventName]) do
            if registeredHandler == handler then
                table.remove(EventCallback._events[eventName], i)
                break
            end
        end
    end
end

--- 모든 이벤트 초기화
function EventCallback.clearAllEvents()
    EventCallback._events = {}
end

--- 특정 이벤트 초기화
---@param eventName string
function EventCallback.clearEvent(eventName)
    EventCallback._events[eventName] = nil
end

--endregion

--region Variables
local rpclib = ImportLuaScript(RpcLibrary)

---@type RPC
local rpc = nil

local RPCSendOption = {
    All = 0,
    Others = 1,
    Target = 2,
}

local isHost = false
--endregion

--region Unity Lifecycle
function awake()
    local syncView = SyncViewObject:GetComponent("VivenCustomSyncView")
    rpc = rpclib.CreateRPC(self, syncView, Player.Mine.UserID, false)

    -- 기본 이벤트 핸들러 등록
    RegisterDefaultEventHandlers()
end

function start()
    isHost = (SyncView.MotherObject.ControlUserId == Player.Mine.UserID)
end

function onDisable()
    EventCallback.clearAllEvents()
    if rpc then
        rpc:Cleanup()
    end
end
--endregion

--region 네트워크 이벤트 전송
--- 모든 플레이어에게 이벤트 전송 (로컬 포함)
---@param eventName string
---@param ... any
function BroadcastEvent(eventName, ...)
    -- 네트워크로 전송
    rpc:SendReliable("OnNetworkEvent", RPCSendOption.All, nil, { eventName, ... })
end

--- 다른 플레이어에게만 이벤트 전송 (로컬 제외)
---@param eventName string
---@param ... any
function BroadcastToOthers(eventName, ...)
    -- 로컬에서 먼저 실행
    EventCallback.invoke(eventName, ...)
    -- 네트워크로 전송
    rpc:SendReliable("OnNetworkEvent", RPCSendOption.Others, nil, { eventName, ... })
end

--- 특정 플레이어에게 이벤트 전송
---@param targetId string
---@param eventName string
---@param ... any
function SendEventToPlayer(targetId, eventName, ...)
    rpc:SendReliable("OnNetworkEvent", RPCSendOption.Target, { targetId }, { eventName, ... })
end

--- 로컬 이벤트만 발생
---@param eventName string
---@param ... any
function LocalEvent(eventName, ...)
    EventCallback.invoke(eventName, ...)
end
--endregion

--region 네트워크 이벤트 수신
--- RPC로 호출되는 네트워크 이벤트 핸들러
---@param eventName string
---@param ... any
function OnNetworkEvent(eventName, ...)
    Debug.Log("네트워크 이벤트 수신: " .. eventName)
    EventCallback.invoke(eventName, ...)
end
--endregion

--region 기본 이벤트 핸들러 등록
function RegisterDefaultEventHandlers()
    -- 게임 시작 이벤트
    EventCallback.registerEvent("onGameStart", function()
        Debug.Log("게임 시작!")
        -- 게임 시작 처리
    end)

    -- 게임 종료 이벤트
    EventCallback.registerEvent("onGameEnd", function()
        Debug.Log("게임 종료!")
        -- 게임 종료 처리
    end)

    -- 점수 업데이트 이벤트
    EventCallback.registerEvent("onScoreUpdate", function(playerId, newScore)
        Debug.Log("점수 업데이트: " .. playerId .. " = " .. tostring(newScore))
        -- UI 업데이트 등
    end)

    -- 플레이어 액션 이벤트
    EventCallback.registerEvent("onPlayerAction", function(playerId, actionType, data)
        Debug.Log("플레이어 액션: " .. playerId .. " - " .. actionType)
        -- 액션 처리
    end)
end
--endregion

--region Public Functions
--- 이벤트 핸들러 등록 (외부용)
---@param eventName string
---@param handler fun(...: any)
function RegisterEventHandler(eventName, handler)
    EventCallback.registerEvent(eventName, handler)
end

--- 이벤트 핸들러 해제 (외부용)
---@param eventName string
---@param handler fun(...: any)
function UnregisterEventHandler(eventName, handler)
    EventCallback.unregisterEvent(eventName, handler)
end

--- 현재 플레이어가 호스트인지 확인
function IsHost()
    return isHost
end
--endregion

--region 사용 예시
--[[
    -- 외부 스크립트에서 사용

    local eventManager = targetObject:GetLuaComponent("NetworkEventCallback")

    -- 이벤트 핸들러 등록
    eventManager.RegisterEventHandler("onCustomEvent", function(data)
        Debug.Log("커스텀 이벤트 수신: " .. tostring(data))
    end)

    -- 모든 플레이어에게 이벤트 브로드캐스트
    eventManager.BroadcastEvent("onCustomEvent", { score = 100, name = "test" })

    -- 특정 플레이어에게 이벤트 전송
    eventManager.SendEventToPlayer("playerId", "onPrivateEvent", "비밀 메시지")

    -- 로컬 이벤트만 발생
    eventManager.LocalEvent("onLocalEvent", "로컬 데이터")
]]
--endregion
