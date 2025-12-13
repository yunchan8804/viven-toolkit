--[[
    network-sync.lua
    VivenCustomSyncView 기반 네트워크 동기화 패턴

    사용법:
    1. GameObject에 VivenLuaBehaviour 추가
    2. VivenCustomSyncView 컴포넌트 추가
    3. 이 스크립트를 VivenLuaBehaviour에 할당
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
local isInitialized = false

-- 동기화할 데이터
local syncData = {
    health = 100,
    score = 0,
    state = "idle"
}

-- 물리 동기화 데이터
local physicsSyncData = {
    posX = 0,
    posY = 0,
    posZ = 0,
    rotY = 0
}
--endregion

--region Lifecycle
function awake()
    -- SyncView는 자동으로 제공됨
    Debug.Log("[NetworkSync] Awake - SyncView: " .. tostring(SyncView ~= nil))
end

function start()
    Debug.Log("[NetworkSync] Start")
end

function onEnable()
    Debug.Log("[NetworkSync] OnEnable")
end

function onDisable()
    Debug.Log("[NetworkSync] OnDisable")
end

function update()
    if not isInitialized then return end

    -- 소유자만 데이터 업데이트
    if SyncView.IsMine then
        updateLocalData()
    end
end

function fixedUpdate()
    if not isInitialized then return end

    -- 소유자만 물리 데이터 업데이트
    if SyncView.IsMine then
        updatePhysicsData()
    end
end
--endregion

--region SyncView Callbacks

--- SyncView 초기화 완료 시 호출
---@param syncTable table Update 동기화 테이블
---@param fixedSyncTable table FixedUpdate 동기화 테이블
function onSyncViewInitialized(syncTable, fixedSyncTable)
    Debug.Log("[NetworkSync] SyncView Initialized")
    Debug.Log("[NetworkSync] IsMine: " .. tostring(SyncView.IsMine))
    Debug.Log("[NetworkSync] ControlUserId: " .. tostring(SyncView.ControlUserId))
    isInitialized = true
end

--- 소유권 변경 시 호출
---@param isMine boolean 현재 내 오브젝트인지
function onOwnershipChanged(isMine)
    Debug.Log("[NetworkSync] Ownership Changed: " .. tostring(isMine))

    if isMine then
        -- 소유권 획득 시 처리
        onOwnershipAcquired()
    else
        -- 소유권 상실 시 처리
        onOwnershipLost()
    end
end

--- Update 동기화 데이터 전송 (소유자만 호출됨)
---@return table 동기화할 데이터 배열
function sendSyncUpdate()
    return {
        syncData.health,
        syncData.score,
        syncData.state
    }
end

--- Update 동기화 데이터 수신 (비소유자가 호출됨)
---@param data table 수신된 데이터 배열
function receiveSyncUpdate(data)
    if data == nil or #data < 3 then return end

    syncData.health = data[1]
    syncData.score = data[2]
    syncData.state = data[3]

    -- 수신 데이터 처리
    onDataReceived()
end

--- FixedUpdate 동기화 데이터 전송 (소유자만 호출됨)
---@return table 물리 동기화 데이터 배열
function sendSyncFixedUpdate()
    local pos = self.transform.position
    local rot = self.transform.rotation.eulerAngles

    return {
        pos.x,
        pos.y,
        pos.z,
        rot.y
    }
end

--- FixedUpdate 동기화 데이터 수신 (비소유자가 호출됨)
---@param data table 수신된 물리 데이터 배열
function receiveSyncFixedUpdate(data)
    if data == nil or #data < 4 then return end

    physicsSyncData.posX = data[1]
    physicsSyncData.posY = data[2]
    physicsSyncData.posZ = data[3]
    physicsSyncData.rotY = data[4]

    -- 물리 데이터 적용
    applyPhysicsData()
end
--endregion

--region Local Functions

--- 소유자의 로컬 데이터 업데이트
local function updateLocalData()
    -- 여기에 로컬 데이터 업데이트 로직 작성
    -- 예: syncData.health = currentHealth
end

--- 소유자의 물리 데이터 업데이트
local function updatePhysicsData()
    -- 여기에 물리 데이터 업데이트 로직 작성
end

--- 수신된 데이터 처리
local function onDataReceived()
    -- 여기에 수신 데이터 처리 로직 작성
    -- 예: UI 업데이트, 상태 변경 등
end

--- 수신된 물리 데이터 적용
local function applyPhysicsData()
    local targetPos = Vector3(physicsSyncData.posX, physicsSyncData.posY, physicsSyncData.posZ)
    local targetRot = Quaternion.Euler(0, physicsSyncData.rotY, 0)

    -- 보간 적용
    self.transform.position = Vector3.Lerp(self.transform.position, targetPos, Time.deltaTime * 10)
    self.transform.rotation = Quaternion.Slerp(self.transform.rotation, targetRot, Time.deltaTime * 10)
end

--- 소유권 획득 시 처리
local function onOwnershipAcquired()
    Debug.Log("[NetworkSync] 소유권 획득")
    UI.ToastMessage("오브젝트 제어권 획득")
end

--- 소유권 상실 시 처리
local function onOwnershipLost()
    Debug.Log("[NetworkSync] 소유권 상실")
end
--endregion

--region Public API

--- 소유권 요청
function RequestOwnership()
    if SyncView then
        SyncView:RequestOwnership()
    end
end

--- 동기화 데이터 설정
---@param health number 체력
---@param score number 점수
---@param state string 상태
function SetSyncData(health, score, state)
    if not SyncView.IsMine then
        Debug.Log("[NetworkSync] 소유자만 데이터를 설정할 수 있습니다")
        return
    end

    syncData.health = health or syncData.health
    syncData.score = score or syncData.score
    syncData.state = state or syncData.state
end

--- 현재 동기화 데이터 가져오기
---@return table 동기화 데이터
function GetSyncData()
    return {
        health = syncData.health,
        score = syncData.score,
        state = syncData.state
    }
end
--endregion
