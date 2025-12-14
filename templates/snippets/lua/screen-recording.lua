--[[
    screen-recording.lua
    화면 녹화 제어 패턴

    PC 모드 전용 화면 녹화 기능
    내부적으로 AVPro Movie Capture + ffmpeg 사용

    주의사항:
    - PC 모드에서만 작동 (XR/Mobile 불가)
    - FMOD 오디오 녹음을 위해 Loopback 장치 필요
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

local isRecording = false
local isPaused = false

-- 기본 설정
local DEFAULT_FRAME_RATE = 30
local DEFAULT_OUTPUT_PATH = nil  -- nil이면 파일 브라우저 표시
local DEFAULT_OUTPUT_FILENAME = nil
--endregion

--region Lifecycle
function awake()
    Debug.Log("[ScreenRecording] Awake")
end

function start()
    Debug.Log("[ScreenRecording] Start")

    -- PC 모드 확인
    if not IsPCMode() then
        Debug.LogWarning("[ScreenRecording] 화면 녹화는 PC 모드에서만 사용 가능합니다.")
    end
end
--endregion

--region Platform Check

--- PC 모드 여부 확인
---@return boolean
function IsPCMode()
    return Player.Mine.PlayMode == "PC"
end

--- 녹화 가능 상태 확인
---@return boolean
function CanRecord()
    if not IsPCMode() then
        UI.ToastWarningMessage("PC 모드에서만 녹화할 수 있습니다.")
        return false
    end
    return true
end
--endregion

--region Recording Control

--- 녹화 시작
---@param frameRate? number 프레임 레이트 (기본값: 30)
---@param outputPath? string 저장 경로 (nil이면 파일 브라우저 표시)
---@param fileName? string 파일명 (확장자 제외)
---@return boolean 성공 여부
function StartRecording(frameRate, outputPath, fileName)
    if not CanRecord() then
        return false
    end

    if isRecording then
        Debug.LogWarning("[ScreenRecording] 이미 녹화 중입니다.")
        return false
    end

    -- 프레임 레이트 설정
    local fps = frameRate or DEFAULT_FRAME_RATE
    ScreenRecording.SetFrameRate(fps)

    -- 저장 경로 설정 (지정하면 파일 브라우저 스킵)
    if outputPath then
        ScreenRecording.SetOutputPath(outputPath)
    end

    if fileName then
        ScreenRecording.SetOutputFileName(fileName)
    end

    -- 녹화 시작
    ScreenRecording.StartRecording()
    isRecording = true
    isPaused = false

    Debug.Log("[ScreenRecording] 녹화 시작 - " .. fps .. "fps")
    UI.ToastMessage("녹화가 시작되었습니다.")

    return true
end

--- 녹화 중단
---@return boolean 성공 여부
function StopRecording()
    if not isRecording then
        Debug.LogWarning("[ScreenRecording] 녹화 중이 아닙니다.")
        return false
    end

    ScreenRecording.StopRecording()
    isRecording = false
    isPaused = false

    Debug.Log("[ScreenRecording] 녹화 중단")
    UI.ToastMessage("녹화가 종료되었습니다.")

    return true
end

--- 녹화 일시정지
---@return boolean 성공 여부
function PauseRecording()
    if not isRecording then
        Debug.LogWarning("[ScreenRecording] 녹화 중이 아닙니다.")
        return false
    end

    if isPaused then
        Debug.LogWarning("[ScreenRecording] 이미 일시정지 상태입니다.")
        return false
    end

    ScreenRecording.PauseRecording()
    isPaused = true

    Debug.Log("[ScreenRecording] 녹화 일시정지")
    UI.ToastMessage("녹화가 일시정지되었습니다.")

    return true
end

--- 녹화 재개
---@return boolean 성공 여부
function ResumeRecording()
    if not isRecording then
        Debug.LogWarning("[ScreenRecording] 녹화 중이 아닙니다.")
        return false
    end

    if not isPaused then
        Debug.LogWarning("[ScreenRecording] 일시정지 상태가 아닙니다.")
        return false
    end

    ScreenRecording.ResumeRecording()
    isPaused = false

    Debug.Log("[ScreenRecording] 녹화 재개")
    UI.ToastMessage("녹화가 재개되었습니다.")

    return true
end

--- 녹화 토글 (시작/중단)
---@param frameRate? number 프레임 레이트 (기본값: 30)
---@return boolean 현재 녹화 상태
function ToggleRecording(frameRate)
    if isRecording then
        StopRecording()
    else
        StartRecording(frameRate)
    end
    return isRecording
end

--- 일시정지 토글
---@return boolean 현재 일시정지 상태
function TogglePause()
    if isPaused then
        ResumeRecording()
    else
        PauseRecording()
    end
    return isPaused
end
--endregion

--region Settings

--- 프레임 레이트 가져오기
---@return number
function GetFrameRate()
    return ScreenRecording.GetFrameRate()
end

--- 프레임 레이트 설정
---@param fps number 1~120 범위
function SetFrameRate(fps)
    if fps < 1 or fps > 120 then
        Debug.LogWarning("[ScreenRecording] 프레임 레이트는 1~120 범위여야 합니다.")
        return
    end
    ScreenRecording.SetFrameRate(fps)
    Debug.Log("[ScreenRecording] 프레임 레이트 설정: " .. fps .. "fps")
end

--- 저장 경로 설정
---@param path string 저장 폴더 경로
function SetOutputPath(path)
    ScreenRecording.SetOutputPath(path)
    Debug.Log("[ScreenRecording] 저장 경로 설정: " .. path)
end

--- 파일명 설정
---@param fileName string 파일명 (확장자 제외)
function SetOutputFileName(fileName)
    ScreenRecording.SetOutputFileName(fileName)
    Debug.Log("[ScreenRecording] 파일명 설정: " .. fileName)
end

--- 경로 설정 초기화
function ClearOutputPaths()
    ScreenRecording.ClearOutputPaths()
    Debug.Log("[ScreenRecording] 경로 설정 초기화")
end

--- 오디오 입력 장치 설정
---@param deviceName string 장치명 (Loopback 장치 권장)
function SetAudioInputDevice(deviceName)
    ScreenRecording.SetAudioInputDevice(deviceName)
    Debug.Log("[ScreenRecording] 오디오 장치 설정: " .. deviceName)
end

--- 현재 오디오 입력 장치 확인
---@return string
function GetCurrentAudioInputDevice()
    return ScreenRecording.GetCurrentAudioInputDevice()
end
--endregion

--region Status

--- 녹화 중 여부
---@return boolean
function IsRecording()
    return isRecording
end

--- 일시정지 상태 여부
---@return boolean
function IsPaused()
    return isPaused
end

--- 상태 정보 가져오기
---@return table {isRecording: boolean, isPaused: boolean, frameRate: number}
function GetStatus()
    return {
        isRecording = isRecording,
        isPaused = isPaused,
        frameRate = GetFrameRate()
    }
end
--endregion

--region Auto Save Recording (자동 저장 녹화)

--- 타임스탬프가 포함된 자동 저장 녹화 시작
---@param basePath string 저장 폴더 경로
---@param prefix? string 파일명 접두사 (기본값: "Recording")
---@param frameRate? number 프레임 레이트 (기본값: 30)
---@return boolean 성공 여부
function StartAutoSaveRecording(basePath, prefix, frameRate)
    if not CanRecord() then
        return false
    end

    local filePrefix = prefix or "Recording"
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local fileName = filePrefix .. "_" .. timestamp

    return StartRecording(frameRate, basePath, fileName)
end
--endregion
