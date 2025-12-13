--[[
    ui-control.lua
    UI 제어 패턴

    윈도우, 독, 토스트, 페이드 등 UI 제어 기능
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

local isFading = false
local DEFAULT_TOAST_DURATION = 3.0
local DEFAULT_FADE_DURATION = 0.5
--endregion

--region Lifecycle
function awake()
    Debug.Log("[UIControl] Awake")
end

function start()
    Debug.Log("[UIControl] Start")
end
--endregion

--region Window Control

--- 홈 윈도우 열기
function OpenHome()
    UI.OpenHomeWindow()
    Debug.Log("[UIControl] 홈 윈도우 열기")
end

--- 방 윈도우 열기
function OpenRoom()
    UI.OpenRoomWindow()
    Debug.Log("[UIControl] 방 윈도우 열기")
end

--- 아바타 윈도우 열기
function OpenAvatar()
    UI.OpenAvatarWindow()
    Debug.Log("[UIControl] 아바타 윈도우 열기")
end

--- 오브젝트 윈도우 열기
function OpenObject()
    UI.OpenObjectWindow()
    Debug.Log("[UIControl] 오브젝트 윈도우 열기")
end

--- 친구 윈도우 열기
function OpenFriend()
    UI.OpenFriendWindow()
    Debug.Log("[UIControl] 친구 윈도우 열기")
end

--- 설정 윈도우 열기
function OpenSetting()
    UI.OpenSettingWindow()
    Debug.Log("[UIControl] 설정 윈도우 열기")
end

--- 모든 윈도우 닫기
function CloseAllWindows()
    UI.CloseAllWindow()
    Debug.Log("[UIControl] 모든 윈도우 닫기")
end
--endregion

--region Dock Control

--- 독 열기
function OpenDock()
    UI.OpenDock()
    Debug.Log("[UIControl] 독 열기")
end

--- 독 닫기
function CloseDock()
    UI.CloseDock()
    Debug.Log("[UIControl] 독 닫기")
end
--endregion

--region Toast Messages

--- 일반 토스트 메시지
---@param message string 메시지 내용
---@param duration number 표시 시간 (초)
function ShowToast(message, duration)
    duration = duration or DEFAULT_TOAST_DURATION
    UI.ToastMessage(message, duration)
end

--- 경고 토스트 메시지
---@param message string 메시지 내용
---@param duration number 표시 시간 (초)
function ShowWarning(message, duration)
    duration = duration or DEFAULT_TOAST_DURATION
    UI.ToastWarningMessage(message, duration)
end

--- 성공 메시지 (일반 토스트)
---@param message string 메시지 내용
function ShowSuccess(message)
    ShowToast("✓ " .. message)
end

--- 에러 메시지 (경고 토스트)
---@param message string 메시지 내용
function ShowError(message)
    ShowWarning("✗ " .. message)
end

--- 정보 메시지
---@param message string 메시지 내용
function ShowInfo(message)
    ShowToast("ℹ " .. message)
end
--endregion

--region Fade Effects

--- 페이드 인 (화면이 밝아짐)
---@param duration number 페이드 시간 (초)
---@param callback function 완료 콜백
function FadeIn(duration, callback)
    if isFading then
        Debug.Log("[UIControl] 페이드 진행 중")
        return
    end

    duration = duration or DEFAULT_FADE_DURATION
    isFading = true

    UI.FadeIn(duration, function()
        isFading = false
        Debug.Log("[UIControl] 페이드 인 완료")
        if callback then
            callback()
        end
    end)
end

--- 페이드 아웃 (화면이 어두워짐)
---@param duration number 페이드 시간 (초)
---@param callback function 완료 콜백
---@param showBackground boolean 배경 이미지 표시 여부
function FadeOut(duration, callback, showBackground)
    if isFading then
        Debug.Log("[UIControl] 페이드 진행 중")
        return
    end

    duration = duration or DEFAULT_FADE_DURATION
    showBackground = showBackground ~= false  -- 기본값 true
    isFading = true

    UI.FadeOut(duration, function()
        isFading = false
        Debug.Log("[UIControl] 페이드 아웃 완료")
        if callback then
            callback()
        end
    end, showBackground)
end

--- 페이드 효과와 함께 함수 실행
---@param action function 실행할 함수
---@param fadeDuration number 페이드 시간 (초)
function ExecuteWithFade(action, fadeDuration)
    fadeDuration = fadeDuration or DEFAULT_FADE_DURATION

    FadeOut(fadeDuration, function()
        if action then
            action()
        end

        FadeIn(fadeDuration, nil)
    end)
end

--- 씬 전환 스타일 페이드
---@param action function 전환 중 실행할 함수
---@param fadeOutDuration number 페이드 아웃 시간
---@param fadeInDuration number 페이드 인 시간
---@param holdDuration number 검은 화면 유지 시간
function SceneTransitionFade(action, fadeOutDuration, fadeInDuration, holdDuration)
    fadeOutDuration = fadeOutDuration or 0.5
    fadeInDuration = fadeInDuration or 0.5
    holdDuration = holdDuration or 0.5

    FadeOut(fadeOutDuration, function()
        if action then
            action()
        end

        -- 잠시 대기 후 페이드 인
        self:StartCoroutine(util.cs_generator(function()
            coroutine.yield(WaitForSeconds(holdDuration))
            FadeIn(fadeInDuration, nil)
        end))
    end)
end
--endregion

--region Utility Functions

--- 페이드 진행 중인지 확인
---@return boolean 페이드 진행 중 여부
function IsFading()
    return isFading
end

--- 확인 메시지 후 액션 실행
---@param message string 확인 메시지
---@param action function 실행할 액션
function ConfirmAction(message, action)
    -- VIVEN SDK에서는 프롬프트 API가 별도로 있을 수 있음
    -- 여기서는 토스트로 대체
    ShowToast(message)
    if action then
        action()
    end
end

--- 카운트다운 토스트
---@param seconds number 카운트다운 시간
---@param onComplete function 완료 콜백
function CountdownToast(seconds, onComplete)
    self:StartCoroutine(util.cs_generator(function()
        for i = seconds, 1, -1 do
            ShowToast(tostring(i), 0.9)
            coroutine.yield(WaitForSeconds(1))
        end

        ShowToast("시작!", 1)

        if onComplete then
            onComplete()
        end
    end))
end

--- 진행 상태 토스트
---@param current number 현재 값
---@param total number 전체 값
---@param prefix string 접두사
function ProgressToast(current, total, prefix)
    prefix = prefix or "진행"
    local percent = math.floor((current / total) * 100)
    ShowToast(prefix .. ": " .. current .. "/" .. total .. " (" .. percent .. "%)")
end
--endregion
