--[[
    rpc-system.lua
    RPC 기반 멀티플레이어 시스템 템플릿

    VivenCustomSyncView 기반의 네트워크 동기화와 RPC 통신
]]

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

local function NullableInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    if OBJECT == nil then
        Debug.Log(_INJECTED_ORDER .. "th object is missing")
    end
    return OBJECT
end

---@type GameObject
---@details RPC를 사용할 대상 오브젝트 (VivenCustomSyncView 컴포넌트 필요)
TargetSyncObject = checkInject(TargetSyncObject)
--endregion

--region Variables
local util = require 'xlua.util'
local rpclib = ImportLuaScript(RpcLibrary)

---@type RPC
local rpc = nil

---@type VivenCustomSyncView
local syncView = nil

local RPCSendOption = {
    All = 0,
    Others = 1,
    Target = 2,
}

local isInitialized = false
local isOwner = false
local ownerId = nil

-- 동기화 데이터 (소유자가 업데이트)
local syncData = {}
local fixedSyncData = {}
--endregion

--region Unity Lifecycle
function awake()
    syncView = TargetSyncObject:GetComponent("VivenCustomSyncView")
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

--region SyncView Callbacks (VivenLuaBehaviour에서 자동 호출)

--- SyncView 초기화 완료 시 호출
---@param syncTable table Update 동기화 테이블
---@param fixedSyncTable table FixedUpdate 동기화 테이블
function onSyncViewInitialized(syncTable, fixedSyncTable)
    Debug.Log("[RPC] SyncView 초기화 완료")
    isOwner = SyncView.IsMine
    ownerId = SyncView.ControlUserId
end

--- 소유권 변경 시 호출
---@param isMine boolean 내가 소유자인지 여부
function onOwnershipChanged(isMine)
    isOwner = isMine
    if isMine then
        ownerId = Player.Mine.UserID
        Debug.Log("[RPC] 소유권 획득")
    else
        ownerId = SyncView.ControlUserId
        Debug.Log("[RPC] 소유권 상실, 새 소유자: " .. tostring(ownerId))
    end
end

--- Update에서 동기화 데이터 전송 (소유자만 호출됨)
---@return table 동기화할 데이터
function sendSyncUpdate()
    return { syncData.value1, syncData.value2, syncData.value3 }
end

--- Update에서 동기화 데이터 수신 (비소유자가 호출됨)
---@param data table 수신된 데이터 배열
function receiveSyncUpdate(data)
    if data and #data >= 3 then
        syncData.value1 = data[1]
        syncData.value2 = data[2]
        syncData.value3 = data[3]
    end
end

--- FixedUpdate에서 동기화 데이터 전송 (물리 데이터용, 소유자만)
---@return table 동기화할 물리 데이터
function sendSyncFixedUpdate()
    return { fixedSyncData.posX, fixedSyncData.posY, fixedSyncData.posZ }
end

--- FixedUpdate에서 동기화 데이터 수신 (비소유자)
---@param data table 수신된 물리 데이터
function receiveSyncFixedUpdate(data)
    if data and #data >= 3 then
        fixedSyncData.posX = data[1]
        fixedSyncData.posY = data[2]
        fixedSyncData.posZ = data[3]
    end
end
--endregion

--region Ownership Management

--- 소유권 요청
function RequestOwnership()
    if syncView then
        syncView:RequestOwnership()
        Debug.Log("[RPC] 소유권 요청")
    end
end

--- 현재 소유자인지 확인
---@return boolean
function IsOwner()
    return isOwner
end

--- 현재 소유자 ID 가져오기
---@return string|nil
function GetOwnerId()
    return ownerId
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

--- 소유자에게만 RPC 전송
---@param functionName string
---@param params table
function SendToOwner(functionName, params)
    if not isInitialized or not ownerId then return end
    rpc:SendReliable(functionName, RPCSendOption.Target, { ownerId }, params)
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

--- 동기화 데이터 설정 (소유자 전용)
---@param key string
---@param value any
function SetSyncData(key, value)
    if isOwner then
        syncData[key] = value
    end
end

--- 동기화 데이터 가져오기
---@param key string
---@return any
function GetSyncData(key)
    return syncData[key]
end
--endregion
