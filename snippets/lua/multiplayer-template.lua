--[[
    Multiplayer Template - Host/Client RPC 패턴

    핵심 원칙:
    - Host: 데이터 변경, 판정, 상태 관리
    - Client: 시각화, 이펙트, UI 업데이트
    - 클라이언트는 입력만 Host로 전달, 결과만 반영
]]

--#region Injection list
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

---@type GameObject
local RootObject = checkInject(RootObject)
---@type SyncView
local SyncView = checkInject(SyncView)
_ORDER = 0
--#endregion

--#region State
local isActive = false
local score = 0
--#endregion

--#region Lifecycle
function awake()
    -- 컴포넌트 캐싱
end

function start()
    -- 초기화, 이벤트 등록
    Util.EventBus:registerEvent("onGameStart", OnGameStart)
end

function update()
    -- Host만 상태 머신 틱 처리
    if not SyncView.IsMine then return end
    -- Host 로직...
end

function onDestroy()
    Util.EventBus:unregisterEvent("onGameStart", OnGameStart)
end
--#endregion

--#region RPC Utilities
---@param functionName string
---@param ... any
local function RPC_Server(functionName, ...)
    local params = { ... }
    SyncView:SendTargetRPC(functionName, { SyncView.ControlUserId }, params)
end

---@param functionName string
---@param ... any
local function RPC_Client(functionName, ...)
    local params = { ... }
    SyncView:SendRPC(functionName, RPCSendOption.All, params)
end
--#endregion

--#region Public API (Client → Host 요청)
--- 점수 추가 요청 (클라이언트가 호출)
---@param amount number
function AddScore(amount)
    RPC_Server("AddScore_Host", amount)
end

--- 활성화 요청
function Activate()
    RPC_Server("Activate_Host")
end

--- 비활성화 요청
function Deactivate()
    RPC_Server("Deactivate_Host")
end
--#endregion

--#region Host Handlers (서버에서 처리)
--- 점수 추가 처리 (Host만 실행)
---@param amount number
function AddScore_Host(amount)
    -- 유효성 검사
    if amount <= 0 then return end

    -- 상태 변경 (Host만)
    score = score + amount

    -- 모든 클라이언트에 결과 전파
    RPC_Client("OnScoreChanged_Client", score)
end

function Activate_Host()
    isActive = true
    RPC_Client("OnActivate_Client")
end

function Deactivate_Host()
    isActive = false
    RPC_Client("OnDeactivate_Client")
end
--#endregion

--#region Client Handlers (시각화/이펙트)
--- 점수 변경 시각화 (모든 클라이언트)
---@param newScore number
function OnScoreChanged_Client(newScore)
    score = newScore
    -- UI 업데이트
    -- 이펙트 재생
    -- 사운드 재생
end

function OnActivate_Client()
    RootObject:SetActive(true)
    -- 활성화 이펙트
end

function OnDeactivate_Client()
    RootObject:SetActive(false)
    -- 비활성화 이펙트
end
--#endregion

--#region Event Handlers
function OnGameStart()
    if SyncView.IsMine then
        -- Host 초기화
        score = 0
        RPC_Client("OnScoreChanged_Client", score)
    end
end
--#endregion
