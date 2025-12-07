---Host-Client 아키텍처 게임 매니저 템플릿

local util = require 'xlua.util'

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

--region Variables
local encoder = ImportLuaScript(RoomPropEncoder)
local rpclib = ImportLuaScript(RpcLibrary)

---@type RPC
local rpc = nil

---@type string
local hostId = nil

---@type boolean
local isHost = false

---@alias GameState "Lobby" | "Playing" | "Paused" | "Finished"

---@type GameState
local state = "Lobby"

---@type string[]
local playerIdList = {}

local SyncView = nil

local RPCSendOption = {
    All = 0,
    Others = 1,
    Target = 2,
}
--endregion

--region Unity Lifecycle
function awake()
    SyncView = SyncViewObject:GetComponent("VivenCustomSyncView")
end

function start()
    rpc = rpclib.CreateRPC(self, SyncView, Player.Mine.UserID, false)
end

--- SyncView 초기화 완료 시 호출
function onSyncViewInitialized()
    FindHost()

    if IsHost() then
        Debug.Log("호스트로 초기화됨")
        InitializeAsHost()
    else
        Debug.Log("클라이언트로 초기화됨")
        InitializeAsClient()
    end
end
--endregion

--region Host 관리
function FindHost()
    hostId = SyncView.MotherObject.ControlUserId
    isHost = (hostId == Player.Mine.UserID)

    if isHost then
        Room.SetRoomProp("Lobby_HostId", hostId)
        Debug.Log("방장 ID 설정: " .. hostId)
    end
end

function IsHost()
    return isHost
end

function GetHostId()
    return hostId
end

--- 호스트로 초기화
function InitializeAsHost()
    -- 로비 시작
    SetState("Lobby")

    -- 플레이어 목록 초기화
    playerIdList = {}
    for playerId, userInfo in pairs(Room.CurrentRoomPlayers) do
        local userData = userInfo --[[@as UserData]]
        table.insert(playerIdList, userData.userId)
    end

    -- Room 속성 초기화
    Room.SetRoomProp("Host_PlayerList", encoder.EncodeStringList(playerIdList))
end

--- 클라이언트로 초기화
function InitializeAsClient()
    -- Room 속성에서 상태 복구
    local hostState = Room.GetRoomProp("Host_State")
    if hostState then
        state = hostState
    end

    playerIdList = encoder.DecodeStringList(Room.GetRoomProp("Host_PlayerList") or "")
end
--endregion

--region 상태 관리
function SetState(newState)
    state = newState
    if IsHost() then
        Room.SetRoomProp("Host_State", newState)
        -- 모든 클라이언트에게 상태 변경 알림
        SendToAll("OnStateChanged", newState)
    end
    Debug.Log("상태 변경: " .. newState)
end

function GetState()
    return state
end

--- 클라이언트에서 상태 변경 수신
function OnStateChanged(newState)
    state = newState
    Debug.Log("상태 동기화: " .. newState)
end
--endregion

--region Room 이벤트 핸들러
---@param userData UserData
function onRoomUserJoined(userData)
    if not IsHost() then return end

    local playerId = userData.userId
    table.insert(playerIdList, playerId)
    Room.SetRoomProp("Host_PlayerList", encoder.EncodeStringList(playerIdList))

    Debug.Log("플레이어 입장: " .. playerId)

    -- 새 플레이어에게 현재 상태 전송
    SendToPlayer("OnSyncCurrentState", playerId, state)
end

---@param userData UserData
function onUserLeaveRoom(userData)
    local playerId = userData.userId

    -- 방장이 나간 경우
    if playerId == hostId then
        OnHostLeft()
        return
    end

    -- 일반 플레이어가 나간 경우
    if IsHost() then
        -- 플레이어 목록에서 제거
        for i, id in ipairs(playerIdList) do
            if id == playerId then
                table.remove(playerIdList, i)
                break
            end
        end
        Room.SetRoomProp("Host_PlayerList", encoder.EncodeStringList(playerIdList))
    end

    Debug.Log("플레이어 퇴장: " .. playerId)
end

function OnHostLeft()
    Debug.Log("방장 퇴장 - 새로운 방장 선출")
    FindHost()

    if IsHost() then
        UI.ToastMessage("새로운 방장이 되었습니다.")
        -- 호스트 역할 인수인계
        RecoverAsNewHost()
    end
end

function RecoverAsNewHost()
    -- Room 속성에서 데이터 복구
    playerIdList = encoder.DecodeStringList(Room.GetRoomProp("Host_PlayerList") or "")
    state = Room.GetRoomProp("Host_State") or "Lobby"

    Debug.Log("새 호스트로 데이터 복구 완료")
end
--endregion

--region RPC 전송 헬퍼
--- 모든 플레이어에게 전송
function SendToAll(functionName, ...)
    rpc:SendReliable(functionName, RPCSendOption.All, nil, { ... })
end

--- 특정 플레이어에게 전송
function SendToPlayer(functionName, targetId, ...)
    rpc:SendReliable(functionName, RPCSendOption.Target, { targetId }, { ... })
end

--- 호스트에게 요청 전송 (클라이언트용)
function RequestToHost(functionName, ...)
    if IsHost() then
        -- 호스트면 바로 실행
        self[functionName](...)
    else
        rpc:SendReliable(functionName, RPCSendOption.Target, { hostId }, { ... })
    end
end
--endregion

--region 게임 플로우 (예시)
--- 호스트: 게임 시작
function StartGame()
    if not IsHost() then return end

    SetState("Playing")
    self:StartCoroutine(util.cs_generator(GameLoop))
end

--- 게임 루프 (호스트에서만 실행)
function GameLoop()
    while state ~= "Finished" do
        if state == "Playing" then
            -- 게임 로직 처리
        elseif state == "Paused" then
            -- 일시정지 처리
        end
        coroutine.yield(WaitForEndOfFrame())
    end

    OnGameFinished()
end

function OnGameFinished()
    SendToAll("OnGameEnd")
    Debug.Log("게임 종료")
end

--- 클라이언트: 게임 종료 수신
function OnGameEnd()
    state = "Finished"
    Debug.Log("게임 종료 알림 수신")
end
--endregion

--region Room 속성 헬퍼
--- Host 전용 Room 속성 설정
function SetHostRoomProp(propName, value)
    if not IsHost() then return end
    Room.SetRoomProp("Host_" .. propName, value)
end

--- Room 속성 읽기
function GetHostRoomProp(propName)
    return Room.GetRoomProp("Host_" .. propName)
end
--endregion
