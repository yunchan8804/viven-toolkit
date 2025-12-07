---Room Property 인코딩/디코딩 유틸리티 모듈

---@class RoomPropEncoder
local RoomPropEncoder = {}

--region 기본 타입 인코딩/디코딩

---@param value boolean
---@return string
function RoomPropEncoder.EncodeBoolean(value)
    return tostring(value)
end

---@param encodedValue string
---@return boolean
function RoomPropEncoder.DecodeBoolean(encodedValue)
    return encodedValue == "true"
end

---@param value int
---@return string
function RoomPropEncoder.EncodeInteger(value)
    return tostring(value)
end

---@param encodedValue string
---@return int
function RoomPropEncoder.DecodeInteger(encodedValue)
    return tonumber(encodedValue) --[[@as int]]
end

---@param value number
---@return string
function RoomPropEncoder.EncodeFloat(value)
    return string.format("%.6f", value)
end

---@param encodedValue string
---@return number
function RoomPropEncoder.DecodeFloat(encodedValue)
    return tonumber(encodedValue)
end

--endregion

--region 배열 인코딩/디코딩

---@param stringList string[]
---@return string
function RoomPropEncoder.EncodeStringList(stringList)
    if stringList == nil or #stringList == 0 then
        return ""
    end
    return table.concat(stringList, ",")
end

---@param encodedStringList string
---@return string[]
function RoomPropEncoder.DecodeStringList(encodedStringList)
    if encodedStringList == nil or encodedStringList == "" then
        return {}
    end
    return RoomPropEncoder.Split(encodedStringList, ",")
end

---@param value boolean[]
---@return string
function RoomPropEncoder.EncodeBooleanList(value)
    if value == nil or #value == 0 then
        return ""
    end

    local encodedList = {}
    for i = 1, #value do
        table.insert(encodedList, tostring(value[i]))
    end
    return table.concat(encodedList, ",")
end

---@param encodedValue string
---@return boolean[]
function RoomPropEncoder.DecodeBooleanList(encodedValue)
    if encodedValue == nil or encodedValue == "" then
        return {}
    end
    local parsed = RoomPropEncoder.Split(encodedValue, ",")
    local decodedList = {}
    for i = 1, #parsed do
        decodedList[i] = RoomPropEncoder.DecodeBoolean(parsed[i])
    end
    return decodedList
end

---@param value int[]
---@return string
function RoomPropEncoder.EncodeIntegerList(value)
    if value == nil or #value == 0 then
        return ""
    end

    local encodedList = {}
    for i = 1, #value do
        table.insert(encodedList, tostring(value[i]))
    end
    return table.concat(encodedList, ",")
end

---@param encodedValue string
---@return int[]
function RoomPropEncoder.DecodeIntegerList(encodedValue)
    if encodedValue == nil or encodedValue == "" then
        return {}
    end
    local parsed = RoomPropEncoder.Split(encodedValue, ",")
    local decodedList = {}
    for i = 1, #parsed do
        decodedList[i] = tonumber(parsed[i]) --[[@as int]]
    end
    return decodedList
end

--endregion

--region 복합 구조 인코딩/디코딩 (예시)

--- Vector3 인코딩
---@param vec {x: number, y: number, z: number}
---@return string
function RoomPropEncoder.EncodeVector3(vec)
    if vec == nil then return "" end
    return string.format("%.4f,%.4f,%.4f", vec.x, vec.y, vec.z)
end

--- Vector3 디코딩
---@param encodedVec string
---@return {x: number, y: number, z: number}|nil
function RoomPropEncoder.DecodeVector3(encodedVec)
    if encodedVec == nil or encodedVec == "" then return nil end
    local parsed = RoomPropEncoder.Split(encodedVec, ",")
    if #parsed ~= 3 then return nil end
    return {
        x = tonumber(parsed[1]),
        y = tonumber(parsed[2]),
        z = tonumber(parsed[3])
    }
end

--- 플레이어 상태 인코딩
---@param playerState {id: string, score: int, isReady: boolean}
---@return string
function RoomPropEncoder.EncodePlayerState(playerState)
    if playerState == nil then return "" end
    return playerState.id .. "," .. tostring(playerState.score) .. "," .. tostring(playerState.isReady)
end

--- 플레이어 상태 디코딩
---@param encodedState string
---@return {id: string, score: int, isReady: boolean}|nil
function RoomPropEncoder.DecodePlayerState(encodedState)
    if encodedState == nil or encodedState == "" then return nil end
    local parsed = RoomPropEncoder.Split(encodedState, ",")
    if #parsed ~= 3 then return nil end
    return {
        id = parsed[1],
        score = tonumber(parsed[2]) --[[@as int]],
        isReady = RoomPropEncoder.DecodeBoolean(parsed[3])
    }
end

--endregion

--region 유틸리티 함수

--- 문자열 분리
---@param inputstr string
---@param sep string
---@return string[]
function RoomPropEncoder.Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- Room Property ID 파싱
---@param propId string
---@return {category: string, propType: string, propName: string}|nil
function RoomPropEncoder.ParseRoomPropKey(propId)
    local parsed = RoomPropEncoder.Split(propId, "_")

    if #parsed < 2 then
        return nil
    end

    return {
        category = parsed[1],
        propType = parsed[2],
        propName = #parsed >= 3 and parsed[3] or nil
    }
end

--endregion

return RoomPropEncoder
