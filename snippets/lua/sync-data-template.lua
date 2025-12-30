--[[
    Sync Data Template - 동기화 테이블 패턴

    핵심 원칙:
    - nil strip 방지를 위해 배열 테이블 사용
    - 큰 데이터는 JSON 문자열로 한 칸에 담음
    - isDirty/캐시로 불필요한 전송 최소화
    - Host는 자신에게도 receiveSyncUpdate 호출
]]

--#region Injection list
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

---@type SyncView
local SyncView = checkInject(SyncView)
_ORDER = 0
--#endregion

--#region Data Model
---@class GameData
---@field score number
---@field playerName string
---@field items table
local GameData = {
    score = 0,
    playerName = "",
    items = {}
}

--- 데이터를 JSON 변환 가능한 테이블로 변환
---@return table
function GameData:ToJSONConvertible()
    return {
        score = self.score,
        playerName = self.playerName,
        items = self.items
    }
end

--- JSON 테이블에서 데이터 복원
---@param json table
---@return GameData
function GameData.FromJSONConvertible(json)
    local data = {
        score = json.score or 0,
        playerName = json.playerName or "",
        items = json.items or {}
    }
    setmetatable(data, { __index = GameData })
    return data
end
--#endregion

--#region Sync State
local isDirty = true
local cachedSyncTable = nil
local currentData = GameData.FromJSONConvertible({})
--#endregion

--#region Sync API (필수 구현)
--- 동기화 데이터 전송 (Host가 호출)
--- @return table 동기화 테이블 (배열 형태)
function sendSyncUpdate()
    -- 변경 없으면 캐시 반환
    if not isDirty then
        return cachedSyncTable or {}
    end

    -- 새 동기화 테이블 생성 (배열 형태로!)
    cachedSyncTable = {}

    -- JSON 문자열로 직렬화하여 한 칸에 담음
    local jsonString = Util.JSON:encode(currentData:ToJSONConvertible())
    table.insert(cachedSyncTable, jsonString)

    -- 더티 플래그 리셋
    isDirty = false

    -- Host 자신에게도 적용 (중요!)
    receiveSyncUpdate(cachedSyncTable)

    return cachedSyncTable
end

--- 동기화 데이터 수신 (모든 클라이언트가 호출됨)
---@param syncTable table 동기화 테이블
function receiveSyncUpdate(syncTable)
    -- 빈 테이블이면 무시
    if #syncTable == 0 then
        return
    end

    -- JSON 역직렬화
    local jsonData = Util.JSON:decode(syncTable[1])
    if not jsonData then
        return
    end

    -- 데이터 복원
    local newData = GameData.FromJSONConvertible(jsonData)

    -- 변경 감지 및 시각화 업데이트
    local oldScore = currentData.score
    currentData = newData

    -- UI/시각화 업데이트
    UpdateVisuals(oldScore, newData.score)
end
--#endregion

--#region Data Modification (Host Only)
--- 점수 설정 (Host만 호출)
---@param newScore number
function SetScore(newScore)
    if not SyncView.IsMine then
        Debug.LogWarning("SetScore can only be called by Host")
        return
    end

    currentData.score = newScore
    MarkDirty()
end

--- 점수 추가 (Host만 호출)
---@param amount number
function AddScore(amount)
    if not SyncView.IsMine then
        return
    end

    currentData.score = currentData.score + amount
    MarkDirty()
end

--- 플레이어 이름 설정 (Host만 호출)
---@param name string
function SetPlayerName(name)
    if not SyncView.IsMine then
        return
    end

    currentData.playerName = name
    MarkDirty()
end

--- 아이템 추가 (Host만 호출)
---@param item table
function AddItem(item)
    if not SyncView.IsMine then
        return
    end

    table.insert(currentData.items, item)
    MarkDirty()
end
--#endregion

--#region Internal
--- 더티 플래그 설정
local function MarkDirty()
    isDirty = true
end

--- 시각화 업데이트 (모든 클라이언트)
---@param oldScore number
---@param newScore number
function UpdateVisuals(oldScore, newScore)
    -- 점수 변경 시 이펙트
    if newScore > oldScore then
        -- 점수 증가 이펙트
        Util.EventBus:invokeEvent("onScoreIncreased", {
            old = oldScore,
            new = newScore,
            diff = newScore - oldScore
        })
    end

    -- UI 갱신
    Util.EventBus:invokeEvent("onDataSynced", currentData)
end
--#endregion

--#region Getters (읽기 전용)
---@return number
function GetScore()
    return currentData.score
end

---@return string
function GetPlayerName()
    return currentData.playerName
end

---@return table
function GetItems()
    return currentData.items
end

---@return GameData
function GetData()
    return currentData
end
--#endregion
