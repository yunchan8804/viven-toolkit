---RPC 기반 멀티플레이어 시스템 템플릿

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

---@type GameObject
---@details RPC를 사용할 대상 오브젝트 (VivenCustomSyncView 컴포넌트 필요)
TargetSyncObject = checkInject(TargetSyncObject)
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

local isInitialized = false
--endregion

--region Unity Lifecycle
function awake()
    local syncView = TargetSyncObject:GetComponent("VivenCustomSyncView")
    rpc = rpclib.CreateRPC(self, syncView, Player.Mine.UserID, true)
end

function start()
    isInitialized = true
end

function onDisable()
    if rpc then
        rpc:Cleanup()
    end
end
--endregion

--region RPC 전송 함수
--- 모든 플레이어에게 브로드캐스트 (신뢰성 있음)
---@param functionName string
---@param ... any
function BroadcastReliable(functionName, ...)
    if not isInitialized then return end
    rpc:SendReliable(functionName, RPCSendOption.All, nil, { ... })
end

--- 모든 플레이어에게 브로드캐스트 (신뢰성 없음, 빠름)
---@param functionName string
---@param ... any
function BroadcastUnreliable(functionName, ...)
    if not isInitialized then return end
    rpc:SendUnreliable(functionName, RPCSendOption.All, nil, { ... })
end

--- 특정 플레이어에게 전송
---@param functionName string
---@param targetId string
---@param ... any
function SendToPlayer(functionName, targetId, ...)
    if not isInitialized then return end
    rpc:SendReliable(functionName, RPCSendOption.Target, { targetId }, { ... })
end

--- 콜백과 함께 전송
---@param functionName string
---@param params table
---@param callback function
function SendWithCallback(functionName, params, callback)
    if not isInitialized then return end
    rpc:SendReliable(functionName, RPCSendOption.All, nil, params, callback, 10)
end
--endregion

--region RPC 수신 핸들러 (예시)
--- RPC로 호출될 함수들을 여기에 정의
function OnPlayerAction(actionType, data)
    Debug.Log("플레이어 액션 수신: " .. actionType)
    -- 액션 처리 로직
end

function OnGameStateUpdate(newState)
    Debug.Log("게임 상태 업데이트: " .. newState)
    -- 상태 업데이트 처리
end

function OnChatMessage(senderId, message)
    Debug.Log("[" .. senderId .. "]: " .. message)
    -- 채팅 메시지 처리
end
--endregion

--region Public Functions
--- RPC 시스템이 준비되었는지 확인
function IsRPCReady()
    return isInitialized and rpc ~= nil
end

--- 대기 중인 메시지 수 확인
function GetPendingMessageCount()
    if rpc then
        return rpc:GetPendingMessageCount()
    end
    return 0
end

--- 모든 대기 중인 메시지 취소
function CancelAllPendingMessages()
    if rpc then
        rpc:CancelAllPendingMessages()
    end
end

--- 디버그 정보 출력
function PrintDebugInfo()
    if rpc then
        rpc:PrintDebugInfo()
    end
end
--endregion
