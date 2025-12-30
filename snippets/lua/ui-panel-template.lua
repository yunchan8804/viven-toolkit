--[[
    UI Panel Template - 표준 UI 패널 구조

    핵심 원칙:
    - Show/Hide/Refresh 최소 API 제공
    - 이벤트 기반 갱신 (update에서 매 프레임 갱신 금지)
    - "상태 → 뷰" 단방향 데이터 흐름
    - onDestroy에서 이벤트 해제 필수
]]

--#region Injection list
local _ORDER = 0
local function checkInject(o)
    _ORDER = _ORDER + 1
    assert(o, _ORDER .. "th object is missing")
    return o
end

---@type GameObject
local PanelRoot = checkInject(PanelRoot)
---@type GameObject
local ActionButtonObject = checkInject(ActionButtonObject)
---@type GameObject
local TitleTextObject = checkInject(TitleTextObject)
_ORDER = 0
--#endregion

--#region Components (awake에서 캐싱)
local button      -- Button 컴포넌트
local titleText   -- TMP_Text 컴포넌트
--#endregion

--#region State
local currentData = nil
local isVisible = false
--#endregion

--#region Lifecycle
function awake()
    -- 컴포넌트 캐싱 (자주 쓰는 것들)
    button = ActionButtonObject:GetComponent("Button")
    titleText = TitleTextObject:GetComponent("TMP_Text")

    -- 버튼 이벤트 바인딩
    if button then
        button.onClick:AddListener(OnActionButtonClicked)
    end
end

function start()
    -- 이벤트 등록
    Util.EventBus:registerEvent("onDataUpdated", OnDataUpdated)
    Util.EventBus:registerEvent("onPlayerStateChanged", OnPlayerStateChanged)

    -- 초기 상태 동기화
    Hide()
end

function onDestroy()
    -- 이벤트 해제 (메모리 누수 방지)
    Util.EventBus:unregisterEvent("onDataUpdated", OnDataUpdated)
    Util.EventBus:unregisterEvent("onPlayerStateChanged", OnPlayerStateChanged)

    -- 버튼 리스너 해제
    if button then
        button.onClick:RemoveListener(OnActionButtonClicked)
    end
end
--#endregion

--#region Public API
--- 패널 표시
---@param data table|nil 초기 데이터 (선택)
function Show(data)
    if data then
        currentData = data
    end

    isVisible = true
    PanelRoot:SetActive(true)
    Refresh()
end

--- 패널 숨김
function Hide()
    isVisible = false
    PanelRoot:SetActive(false)
end

--- 패널 토글
function Toggle()
    if isVisible then
        Hide()
    else
        Show()
    end
end

--- UI 갱신 (데이터 기반)
---@param data table|nil 새 데이터 (선택)
function Refresh(data)
    if data then
        currentData = data
    end

    -- 데이터 없으면 기본값 표시
    if not currentData then
        if titleText then
            titleText.text = "No Data"
        end
        return
    end

    -- 데이터 기반 UI 업데이트
    if titleText and currentData.title then
        titleText.text = currentData.title
    end

    -- 추가 UI 요소 업데이트...
end
--#endregion

--#region Event Handlers
--- 데이터 업데이트 이벤트 핸들러
---@param payload table
function OnDataUpdated(payload)
    if isVisible then
        Refresh(payload)
    else
        -- 숨겨진 상태에서는 데이터만 저장
        currentData = payload
    end
end

--- 플레이어 상태 변경 핸들러
---@param oldState number
---@param newState number
function OnPlayerStateChanged(oldState, newState)
    -- 상태에 따른 패널 표시/숨김
    -- 예: 특정 상태에서만 패널 표시
    if newState == PLAYER_STATE.READY then
        Show()
    elseif newState == PLAYER_STATE.PLAYING then
        Hide()
    end
end

--- 액션 버튼 클릭 핸들러
function OnActionButtonClicked()
    -- 버튼 클릭 시 이벤트 발행 (상위 시스템으로 전달)
    Util.EventBus:invokeEvent("onPanelActionClicked", {
        panelName = "MyPanel",
        data = currentData
    })
end
--#endregion

--#region Utility
--- 애니메이션과 함께 표시 (선택적 확장)
---@param duration number 애니메이션 시간
function ShowAnimated(duration)
    PanelRoot:SetActive(true)
    isVisible = true
    -- DOTween 등 애니메이션 라이브러리 사용
    -- CanvasGroup.alpha 0→1 등
    Refresh()
end

--- 애니메이션과 함께 숨김
---@param duration number 애니메이션 시간
function HideAnimated(duration)
    isVisible = false
    -- 애니메이션 완료 후 SetActive(false)
end
--#endregion
