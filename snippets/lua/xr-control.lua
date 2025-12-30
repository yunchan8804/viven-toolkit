--[[
    xr-control.lua
    XR/VR 제어 패턴

    VR 컨트롤러 진동, XR 관련 기능 제어
    PC VR 모드에서만 작동하는 기능들 포함
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

-- 진동 상태 관리
local isLeftVibrating = false
local isRightVibrating = false

-- 기본 설정
local DEFAULT_AMPLITUDE = 0.5
local DEFAULT_DURATION = 0.2
--endregion

--region Lifecycle
function awake()
    Debug.Log("[XRControl] Awake")
end

function start()
    Debug.Log("[XRControl] Start")

    -- XR 모드 확인
    if not IsXRMode() then
        Debug.LogWarning("[XRControl] XR 기능은 VR 모드에서만 사용 가능합니다.")
    end
end

function onDisable()
    -- 비활성화 시 진동 중지
    StopAllVibration()
end
--endregion

--region Platform Check

--- XR 모드 여부 확인
---@return boolean
function IsXRMode()
    return Player.Mine.PlayMode == "XR"
end

--- PC 모드 여부 확인
---@return boolean
function IsPCMode()
    return Player.Mine.PlayMode == "PC"
end

--- VR 기능 사용 가능 여부 확인
---@return boolean
function CanUseXR()
    if not IsXRMode() then
        Debug.LogWarning("[XRControl] XR 모드에서만 사용할 수 있습니다.")
        return false
    end
    return true
end
--endregion

--region Controller Vibration

--- 컨트롤러 진동 시작
---@param isLeft boolean 왼쪽 컨트롤러 여부 (false = 오른쪽)
---@param amplitude number 진동 세기 (0.0 ~ 1.0)
---@param duration number 진동 시간 (초)
---@return boolean 성공 여부
function StartControllerVibration(isLeft, amplitude, duration)
    if not CanUseXR() then
        return false
    end

    isLeft = isLeft or false
    amplitude = amplitude or DEFAULT_AMPLITUDE
    duration = duration or DEFAULT_DURATION

    -- 값 범위 제한
    amplitude = Mathf.Clamp(amplitude, 0, 1)
    duration = Mathf.Max(duration, 0)

    XR.StartControllerVibration(isLeft, amplitude, duration)

    if isLeft then
        isLeftVibrating = true
    else
        isRightVibrating = true
    end

    Debug.Log("[XRControl] 진동 시작 - " .. (isLeft and "왼쪽" or "오른쪽") ..
              " amplitude: " .. amplitude .. ", duration: " .. duration .. "s")

    return true
end

--- 컨트롤러 진동 중지
---@param isLeft boolean 왼쪽 컨트롤러 여부 (false = 오른쪽)
---@return boolean 성공 여부
function StopControllerVibration(isLeft)
    if not CanUseXR() then
        return false
    end

    isLeft = isLeft or false

    XR.StopControllerVibration(isLeft)

    if isLeft then
        isLeftVibrating = false
    else
        isRightVibrating = false
    end

    Debug.Log("[XRControl] 진동 중지 - " .. (isLeft and "왼쪽" or "오른쪽"))

    return true
end

--- 왼쪽 컨트롤러 진동 시작
---@param amplitude number 진동 세기 (0.0 ~ 1.0)
---@param duration number 진동 시간 (초)
function VibrateLeft(amplitude, duration)
    StartControllerVibration(true, amplitude, duration)
end

--- 오른쪽 컨트롤러 진동 시작
---@param amplitude number 진동 세기 (0.0 ~ 1.0)
---@param duration number 진동 시간 (초)
function VibrateRight(amplitude, duration)
    StartControllerVibration(false, amplitude, duration)
end

--- 양쪽 컨트롤러 진동 시작
---@param amplitude number 진동 세기 (0.0 ~ 1.0)
---@param duration number 진동 시간 (초)
function VibrateBoth(amplitude, duration)
    StartControllerVibration(true, amplitude, duration)
    StartControllerVibration(false, amplitude, duration)
end

--- 모든 진동 중지
function StopAllVibration()
    if isLeftVibrating then
        StopControllerVibration(true)
    end
    if isRightVibrating then
        StopControllerVibration(false)
    end
end
--endregion

--region Vibration Patterns

--- 짧은 피드백 진동 (클릭 느낌)
---@param isLeft boolean 왼쪽 컨트롤러 여부
function VibrateClick(isLeft)
    StartControllerVibration(isLeft, 0.3, 0.05)
end

--- 성공 피드백 진동
---@param isLeft boolean 왼쪽 컨트롤러 여부
function VibrateSuccess(isLeft)
    StartControllerVibration(isLeft, 0.5, 0.15)
end

--- 경고 피드백 진동
---@param isLeft boolean 왼쪽 컨트롤러 여부
function VibrateWarning(isLeft)
    StartControllerVibration(isLeft, 0.8, 0.3)
end

--- 강한 피드백 진동 (충돌 느낌)
---@param isLeft boolean 왼쪽 컨트롤러 여부
function VibrateImpact(isLeft)
    StartControllerVibration(isLeft, 1.0, 0.1)
end

--- 펄스 진동 패턴 (반복)
---@param isLeft boolean 왼쪽 컨트롤러 여부
---@param count number 반복 횟수
---@param amplitude number 진동 세기
---@param onDuration number 진동 시간
---@param offDuration number 정지 시간
function VibratePulse(isLeft, count, amplitude, onDuration, offDuration)
    count = count or 3
    amplitude = amplitude or 0.5
    onDuration = onDuration or 0.1
    offDuration = offDuration or 0.1

    self:StartCoroutine(util.cs_generator(function()
        for i = 1, count do
            StartControllerVibration(isLeft, amplitude, onDuration)
            coroutine.yield(WaitForSeconds(onDuration + offDuration))
        end
    end))
end
--endregion

--region Status

--- 왼쪽 컨트롤러 진동 중 여부
---@return boolean
function IsLeftVibrating()
    return isLeftVibrating
end

--- 오른쪽 컨트롤러 진동 중 여부
---@return boolean
function IsRightVibrating()
    return isRightVibrating
end

--- 현재 상태 정보
---@return table
function GetStatus()
    return {
        isXRMode = IsXRMode(),
        isLeftVibrating = isLeftVibrating,
        isRightVibrating = isRightVibrating
    }
end
--endregion
