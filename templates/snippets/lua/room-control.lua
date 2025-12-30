--[[
    room-control.lua
    Room 제어 패턴

    방 정보 조회, 플레이어 관리, 프로퍼티 제어, 음성 채팅 등
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
--endregion

--region Local Variables
local util = require 'xlua.util'

-- 프로퍼티 변경 콜백 저장
local propCallbacks = {}
--endregion

--region Lifecycle
function awake()
    Debug.Log("[RoomControl] Awake")
end

function start()
    Debug.Log("[RoomControl] Start")
    PrintRoomInfo()
end

function onDisable()
    -- 등록된 콜백 정리
    UnregisterAllPropCallbacks()
end
--endregion

--region Room Info

--- 방 정보 출력
function PrintRoomInfo()
    local creatorId = Room.GetCreatorUserID()
    local playerCount = GetPlayerCount()

    Debug.Log("[RoomControl] 방 생성자 ID: " .. (creatorId or "N/A"))
    Debug.Log("[RoomControl] 현재 플레이어 수: " .. playerCount)
end

--- 방 생성자 UserID 가져오기
---@return string 방 생성자의 UUID
function GetCreatorUserID()
    return Room.GetCreatorUserID()
end

--- 현재 플레이어가 방 생성자인지 확인
---@return boolean
function IsRoomCreator()
    local creatorId = Room.GetCreatorUserID()
    local myId = Player.Mine.UserID
    return creatorId == myId
end

--- 방 나가기 (마이룸으로 이동)
function LeaveRoom()
    Debug.Log("[RoomControl] 방 나가기")
    Room.LeaveRoom()
end

--- 확인 후 방 나가기
---@param message string 확인 메시지 (선택)
function LeaveRoomWithConfirm(message)
    message = message or "방을 나가시겠습니까?"
    UI.ToastMessage(message)
    -- 실제 확인 다이얼로그가 필요하면 별도 구현
    LeaveRoom()
end
--endregion

--region Players in Room

--- 현재 방의 플레이어 목록 가져오기
---@return table (PlayerId, UserData) 딕셔너리
function GetCurrentPlayers()
    return Room.CurrentRoomPlayers
end

--- 현재 방의 플레이어 수
---@return number
function GetPlayerCount()
    local players = Room.CurrentRoomPlayers
    local count = 0
    if players then
        for _ in pairs(players) do
            count = count + 1
        end
    end
    return count
end

--- 특정 플레이어가 방에 있는지 확인
---@param playerId string 플레이어 ID
---@return boolean
function IsPlayerInRoom(playerId)
    local players = Room.CurrentRoomPlayers
    if players then
        return players[playerId] ~= nil
    end
    return false
end

--- 플레이어 ID 목록 가져오기
---@return table 플레이어 ID 배열
function GetPlayerIds()
    local players = Room.CurrentRoomPlayers
    local ids = {}
    if players then
        for id, _ in pairs(players) do
            table.insert(ids, id)
        end
    end
    return ids
end

--- 플레이어 닉네임으로 검색
---@param nickname string 닉네임
---@return table|nil UserData 또는 nil
function FindPlayerByNickname(nickname)
    local players = Room.CurrentRoomPlayers
    if players then
        for id, userData in pairs(players) do
            if userData.nickname == nickname then
                return userData
            end
        end
    end
    return nil
end
--endregion

--region Room Properties

--- 방 프로퍼티 가져오기
---@param propId string 프로퍼티 ID
---@return string|nil 프로퍼티 값 또는 nil
function GetRoomProp(propId)
    return Room.GetRoomProp(propId)
end

--- 방 프로퍼티 설정
---@param propId string 프로퍼티 ID
---@param propVal string 프로퍼티 값
function SetRoomProp(propId, propVal)
    Room.SetRoomProp(propId, propVal)
    Debug.Log("[RoomControl] 프로퍼티 설정: " .. propId .. " = " .. propVal)
end

--- 방 프로퍼티 가져오기 (기본값 지원)
---@param propId string 프로퍼티 ID
---@param defaultValue string 기본값
---@return string 프로퍼티 값 또는 기본값
function GetRoomPropOrDefault(propId, defaultValue)
    local value = Room.GetRoomProp(propId)
    if value == nil then
        return defaultValue
    end
    return value
end

--- 방 프로퍼티 변경 콜백 등록
---@param propId string 프로퍼티 ID
---@param callback function 콜백 함수
function RegisterRoomPropChanged(propId, callback)
    Room.RegisterRoomPropChanged(propId, callback)

    -- 내부 관리용 저장
    if not propCallbacks[propId] then
        propCallbacks[propId] = {}
    end
    table.insert(propCallbacks[propId], callback)

    Debug.Log("[RoomControl] 프로퍼티 변경 콜백 등록: " .. propId)
end

--- 방 프로퍼티 변경 콜백 해제
---@param propId string 프로퍼티 ID
---@param callback function 콜백 함수
function UnregisterRoomPropChanged(propId, callback)
    Room.UnRegisterRoomPropChanged(propId, callback)

    -- 내부 관리용 제거
    if propCallbacks[propId] then
        for i, cb in ipairs(propCallbacks[propId]) do
            if cb == callback then
                table.remove(propCallbacks[propId], i)
                break
            end
        end
    end

    Debug.Log("[RoomControl] 프로퍼티 변경 콜백 해제: " .. propId)
end

--- 모든 프로퍼티 콜백 해제
function UnregisterAllPropCallbacks()
    for propId, callbacks in pairs(propCallbacks) do
        for _, callback in ipairs(callbacks) do
            Room.UnRegisterRoomPropChanged(propId, callback)
        end
    end
    propCallbacks = {}
    Debug.Log("[RoomControl] 모든 프로퍼티 콜백 해제")
end
--endregion

--region Room Property Utilities

--- JSON 형태로 프로퍼티 저장
---@param propId string 프로퍼티 ID
---@param data table Lua 테이블
function SetRoomPropAsJson(propId, data)
    local json = require 'xlua.util'.json_encode(data)
    SetRoomProp(propId, json)
end

--- JSON 프로퍼티를 테이블로 가져오기
---@param propId string 프로퍼티 ID
---@return table|nil 파싱된 테이블 또는 nil
function GetRoomPropAsJson(propId)
    local value = GetRoomProp(propId)
    if value then
        local success, result = pcall(function()
            return require 'xlua.util'.json_decode(value)
        end)
        if success then
            return result
        end
    end
    return nil
end

--- 숫자 프로퍼티 증가
---@param propId string 프로퍼티 ID
---@param amount number 증가량 (기본: 1)
---@return number 새로운 값
function IncrementRoomProp(propId, amount)
    amount = amount or 1
    local current = tonumber(GetRoomPropOrDefault(propId, "0")) or 0
    local newValue = current + amount
    SetRoomProp(propId, tostring(newValue))
    return newValue
end

--- 숫자 프로퍼티 감소
---@param propId string 프로퍼티 ID
---@param amount number 감소량 (기본: 1)
---@return number 새로운 값
function DecrementRoomProp(propId, amount)
    return IncrementRoomProp(propId, -(amount or 1))
end
--endregion

--region Voice Chat (Room.VoiceChat)

--- 음성 채팅 활성화
function EnableVoiceChat()
    if Room.VoiceChat then
        Room.VoiceChat.SetVoiceChatEnabled(true)
        Debug.Log("[RoomControl] 음성 채팅 활성화")
    end
end

--- 음성 채팅 비활성화
function DisableVoiceChat()
    if Room.VoiceChat then
        Room.VoiceChat.SetVoiceChatEnabled(false)
        Debug.Log("[RoomControl] 음성 채팅 비활성화")
    end
end

--- 음성 채팅 토글
function ToggleVoiceChat()
    if Room.VoiceChat then
        local current = Room.VoiceChat.IsVoiceChatEnabled()
        Room.VoiceChat.SetVoiceChatEnabled(not current)
        Debug.Log("[RoomControl] 음성 채팅 " .. (not current and "활성화" or "비활성화"))
    end
end
--endregion

--region Map Settings (Room.Map)

--- 맵 설정 접근 (Room.Map API 존재 시)
-- Room.Map 관련 API가 있다면 여기에 추가
--endregion
