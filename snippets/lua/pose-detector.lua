--[[
    pose-detector.lua
    Force/Fever Haptic Templates
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

poseDetectorObject = checkInject(poseDetectorObject)
directionDetectorObject = NullableInject(directionDetectorObject)
gameManagerName = checkInject(gameManagerName)
--endregion

--region Variables
local util = require "xlua.util"
XRHandAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.XRHandAPI
InteractionAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.InteractionAPI
Handedness = CS.TwentyOz.VivenSDK.Scripts.Core.Haptic.DataModels.SDKHandedness
FingerType = CS.TwentyOz.VivenSDK.Scripts.Core.Haptic.DataModels.SDKFingerType

local gameManager = nil
local poseDetector = nil
local directionDetector = nil
local grabbableModule = nil
local isPoseDetected = false
local isDirectionDetected = false
local isValidGrab = false
local isLeftHand = false
--endregion

function awake()
    gameManager = self:GetLuaComponentInParent(gameManagerName)
    poseDetector = poseDetectorObject:GetComponent("VivenPoseOrGestureInteraction")
    if directionDetectorObject then
        directionDetector = directionDetectorObject:GetComponent("VivenPoseOrGestureInteraction")
    end
    grabbableModule = self:GetComponent("VivenGrabbableModule")
end

function onEnable()
    poseDetector.onPoseOrGesturePerformed:AddListener(onPoseDetected)
    poseDetector.onPoseOrGestureEnded:AddListener(onPoseEnded)
    if directionDetector then
        directionDetector.onPoseOrGesturePerformed:AddListener(onDirectionDetected)
        directionDetector.onPoseOrGestureEnded:AddListener(onDirectionEnded)
    end
end

function onDisable()
    poseDetector.onPoseOrGesturePerformed:RemoveListener(onPoseDetected)
    poseDetector.onPoseOrGestureEnded:RemoveListener(onPoseEnded)
    if directionDetector then
        directionDetector.onPoseOrGesturePerformed:RemoveListener(onDirectionDetected)
        directionDetector.onPoseOrGestureEnded:RemoveListener(onDirectionEnded)
    end
    StopAllHaptics()
end

function onPoseDetected()
    isPoseDetected = true
    checkValidGrab()
end

function onPoseEnded()
    isPoseDetected = false
    isValidGrab = false
end

function onDirectionDetected()
    isDirectionDetected = true
    checkValidGrab()
end

function onDirectionEnded()
    isDirectionDetected = false
    isValidGrab = false
end

function checkValidGrab()
    local directionOk = (directionDetector == nil) or isDirectionDetected
    if isPoseDetected and directionOk then
        isValidGrab = true
        if InteractionAPI.GetVerifiedColsCount(grabbableModule) > 0 then
            -- ForceGrabHandTracking(grabbable, isLeft, isInteractable=true, isForce=false)
            XRHandAPI.ForceGrabHandTracking(grabbableModule, isLeftHand)
        end
    end
end

function onGrab()
    if XRHandAPI.GetHandTrackingMode() ~= "None" and not isValidGrab then
        PlayVibrationHaptic(0.2, 100, isLeftHand)
        return
    end
    PlayVibrationHaptic(0.5, 50, isLeftHand)
    if gameManager ~= nil then gameManager.OnGrabObject() end
end

function onRelease()
    isValidGrab = false
    if gameManager ~= nil then gameManager.OnReleaseObject() end
end

--region Haptic - Vibration
function PlayVibrationHaptic(intensity, duration, useLeftHand, fingerType)
    fingerType = fingerType or FingerType.Index
    local hand = useLeftHand and Handedness.Left or Handedness.Right
    if XRHandAPI.GetHandTrackingMode() == "None" then
        XR.StartControllerVibration(useLeftHand, intensity, duration / 1000)
    else
        HandTracking.CommandVibrationHaptic(intensity * 0.1, duration, hand, fingerType, false)
    end
end

function StopVibrationHaptic(useLeftHand)
    local hand = useLeftHand and Handedness.Left or Handedness.Right
    if XRHandAPI.GetHandTrackingMode() == "None" then
        XR.StopControllerVibration(useLeftHand)
    else
        HandTracking.StopVibrationHaptic(hand)
    end
end
--endregion

--region Haptic - Force
function PlayForceHaptic(intensity, bendValue, inward, useLeftHand, fingerType)
    if XRHandAPI.GetHandTrackingMode() == "None" then
        XR.StartControllerVibration(useLeftHand, intensity * 0.5, 0.1)
        return
    end
    local hand = useLeftHand and Handedness.Left or Handedness.Right
    fingerType = fingerType or FingerType.Index
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, fingerType)
end

function PlayForceHapticAllFingers(intensity, bendValue, inward, useLeftHand)
    local hand = useLeftHand and Handedness.Left or Handedness.Right
    if XRHandAPI.GetHandTrackingMode() == "None" then
        XR.StartControllerVibration(useLeftHand, intensity * 0.5, 0.2)
        return
    end
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, FingerType.Thumb)
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, FingerType.Index)
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, FingerType.Middle)
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, FingerType.Ring)
    HandTracking.CommandForceHaptic(intensity, bendValue, inward, hand, FingerType.Little)
end

function StopForceHaptic(useLeftHand)
    if XRHandAPI.GetHandTrackingMode() ~= "None" then
        local hand = useLeftHand and Handedness.Left or Handedness.Right
        HandTracking.StopForceHaptic(hand)
    end
end
--endregion

--region Haptic - Fever
function PlayFeverHaptic(temperature, duration, useLeftHand)
    if XRHandAPI.GetHandTrackingMode() == "None" then
        local intensity = math.abs(temperature - 36.5) / 10
        XR.StartControllerVibration(useLeftHand, math.min(intensity, 1.0), duration / 1000)
        return
    end
    local hand = useLeftHand and Handedness.Left or Handedness.Right
    HandTracking.CommandFeverHaptic(temperature, duration, hand)
end

function PlayColdHaptic(duration, useLeftHand)
    PlayFeverHaptic(20.0, duration, useLeftHand)
end

function PlayWarmHaptic(duration, useLeftHand)
    PlayFeverHaptic(40.0, duration, useLeftHand)
end

function PlayHotHaptic(duration, useLeftHand)
    PlayFeverHaptic(50.0, duration, useLeftHand)
end

function StopFeverHaptic(useLeftHand)
    if XRHandAPI.GetHandTrackingMode() ~= "None" then
        local hand = useLeftHand and Handedness.Left or Handedness.Right
        HandTracking.StopFeverHaptic(hand)
    end
end
--endregion

--region Haptic Utility
function StopAllHaptics()
    StopVibrationHaptic(false)
    StopVibrationHaptic(true)
    StopForceHaptic(false)
    StopForceHaptic(true)
    StopFeverHaptic(false)
    StopFeverHaptic(true)
end

function PlayGrabStartHaptic(useLeftHand)
    PlayVibrationHaptic(0.3, 50, useLeftHand)
    PlayForceHapticAllFingers(0.5, 0.6, true, useLeftHand)
end

function PlayGrabEndHaptic(useLeftHand)
    StopForceHaptic(useLeftHand)
    PlayVibrationHaptic(0.1, 30, useLeftHand)
end
--endregion

function GetIsPoseDetected() return isPoseDetected end
function GetIsDirectionDetected() return isDirectionDetected end
function GetIsValidGrab() return isValidGrab end
function SetHandedness(leftHand) isLeftHand = leftHand end
