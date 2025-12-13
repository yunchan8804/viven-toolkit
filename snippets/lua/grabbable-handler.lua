--[[
    grabbable-handler.lua
    Grabbable 오브젝트 핸들러 템플릿

    잡기, 놓기, 햅틱 피드백 및 Player.Mine.TryGrab 패턴
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

---@type string
---@details 게임 매니저 스크립트 이름
gameManagerName = checkInject(gameManagerName)

---@type GameObject
---@details 자동 잡기 대상 오브젝트 (선택)
autoGrabTarget = NullableInject(autoGrabTarget)
--endregion

--region Variables
local util = require 'xlua.util'
XRHandAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.XRHandAPI
InteractionAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.InteractionAPI
Handedness = CS.TwentyOz.VivenSDK.Scripts.Core.Haptic.DataModels.SDKHandedness
FingerType = CS.TwentyOz.VivenSDK.Scripts.Core.Haptic.DataModels.SDKFingerType

---@type GameManager
local gameManager = nil

---@type VivenGrabbableModule
local grabbableModule = nil

---@type VivenRigidbodyControlModule
local rigidbodyModule = nil

---@type Transform
local handInteractorTransform = nil

---@type boolean
local isGrabbed = false

---@type boolean
local isLeftHand = false
--endregion

--region Unity Lifecycle
function awake()
    gameManager = self:GetLuaComponentInParent(gameManagerName)
    grabbableModule = self:GetComponent("VivenGrabbableModule")
    rigidbodyModule = self:GetComponent("VivenRigidbodyControlModule")
end

function start()
    local rigidBody = rigidbodyModule.Rigid
    rigidBody.collisionDetectionMode = CS.UnityEngine.CollisionDetectionMode.ContinuousDynamic
end

function onEnable()
    -- 추가 이벤트 리스너 등록이 필요하면 여기에
end

function onDisable()
    -- 추가 이벤트 리스너 해제가 필요하면 여기에
end

function update()
end

function fixedUpdate()
end
--endregion

--region Interaction Events
function onGrab()
    isGrabbed = true
    handInteractorTransform = grabbableModule.InteractingInteractor.InteractingTransform

    -- 어느 손인지 확인
    local interactorName = grabbableModule.InteractingInteractor.gameObject.name
    isLeftHand = string.find(interactorName, "Left") ~= nil

    -- 햅틱 피드백
    playHapticFeedback(0.3, 0.1, 0.05, 50)

    -- 게임 매니저에 알림
    if gameManager ~= nil then
        gameManager.OnGrabObject()
    end
end

function onRelease()
    isGrabbed = false
    handInteractorTransform = nil
    isLeftHand = false

    -- 게임 매니저에 알림
    if gameManager ~= nil then
        gameManager.OnReleaseObject()
    end
end

function onShortClick()
    -- 짧게 클릭 (잡은 상태에서)
end

function onLongClick()
    -- 길게 클릭 (holdTimeThreshold 이상)
end
--endregion

--region Trigger Events
function onTriggerEnter(other)
end

function onTriggerExit(other)
end
--endregion

--region Player TryGrab API

--- 플레이어가 이 오브젝트를 강제로 잡도록 시도 (비동기 - Task<bool>)
---@param useLeftHand boolean 왼손 사용 여부 (기본값: false = 오른손)
---@param forceGrab boolean 기존에 잡고있는 모듈을 놓게 할지 여부 (기본값: false)
---@return boolean 성공 여부 (xLua가 Task를 자동 처리)
function TryGrabByPlayer(useLeftHand, forceGrab)
    if grabbableModule == nil then
        Debug.Log("[Grabbable] grabbableModule이 없습니다")
        return false
    end

    useLeftHand = useLeftHand or false
    forceGrab = forceGrab or false

    local success = Player.Mine.TryGrab(grabbableModule, useLeftHand, forceGrab, GrabInterpolation.All)

    if success then
        Debug.Log("[Grabbable] TryGrab 성공")
    else
        Debug.Log("[Grabbable] TryGrab 실패")
    end

    return success
end

--- 대상 오브젝트를 잡도록 시도 (외부 오브젝트, 비동기 - Task<bool>)
---@param targetObject GameObject 대상 오브젝트
---@param useLeftHand boolean 왼손 사용 여부 (기본값: false = 오른손)
---@return boolean 성공 여부 (xLua가 Task를 자동 처리)
function TryGrabObject(targetObject, useLeftHand)
    if targetObject == nil then
        Debug.Log("[Grabbable] 대상 오브젝트가 없습니다")
        return false
    end

    local targetGrabbable = targetObject:GetComponent("VivenGrabbableModule")
    if targetGrabbable == nil then
        Debug.Log("[Grabbable] 대상에 VivenGrabbableModule이 없습니다")
        return false
    end

    return Player.Mine.TryGrab(targetGrabbable, useLeftHand or false, false, GrabInterpolation.All)
end

--- 주입된 autoGrabTarget 오브젝트를 잡도록 시도
---@param useLeftHand boolean 왼손 사용 여부
function TryGrabAutoTarget(useLeftHand)
    if autoGrabTarget then
        TryGrabObject(autoGrabTarget, useLeftHand)
    end
end

--- 모든 상호작용 종료
function EndAllInteractions()
    Player.Mine.EndAllInteractions()
    Debug.Log("[Grabbable] 모든 상호작용 종료")
end
--endregion

--region Haptic Functions
---@param controllerIntensity number 컨트롤러 진동 강도 (0.0 ~ 1.0)
---@param controllerDuration number 컨트롤러 진동 지속시간 (초)
---@param gloveIntensity number 장갑 진동 강도 (0.0 ~ 1.0)
---@param gloveDuration number 장갑 진동 지속시간 (밀리초)
function playHapticFeedback(controllerIntensity, controllerDuration, gloveIntensity, gloveDuration)
    if XRHandAPI.GetHandTrackingMode() == "None" then
        -- 컨트롤러 모드
        XR.StartControllerVibration(isLeftHand, controllerIntensity, controllerDuration)
    else
        -- 비햅틱스 장갑 모드
        local hand = isLeftHand and Handedness.Left or Handedness.Right
        HandTracking.CommandVibrationHaptic(gloveIntensity, gloveDuration, hand, FingerType.Index, false)
        HandTracking.CommandVibrationHaptic(gloveIntensity, gloveDuration, hand, FingerType.Thumb, false)
    end
end

--- 양손에 햅틱 피드백
---@param intensity number 진동 강도
---@param duration number 지속시간
function playBothHandsHaptic(intensity, duration)
    if XRHandAPI.GetHandTrackingMode() == "None" then
        XR.StartControllerVibration(false, intensity, duration)
        XR.StartControllerVibration(true, intensity, duration)
    else
        HandTracking.CommandVibrationHaptic(intensity * 0.1, duration * 500, Handedness.Right, FingerType.Index, false)
        HandTracking.CommandVibrationHaptic(intensity * 0.1, duration * 500, Handedness.Left, FingerType.Index, false)
    end
end
--endregion

--region Public Functions
function GetIsGrabbed()
    return isGrabbed
end

function GetIsLeftHand()
    return isLeftHand
end

function SetActive(isActive)
    grabbableModule:FlushInteractableCollider()
    self.gameObject:SetActive(isActive)
end

function ForceRelease()
    if grabbableModule ~= nil then
        grabbableModule:Release()
    end
end

--- Grabbable 활성화/비활성화
---@param enabled boolean
function SetGrabbableEnabled(enabled)
    if grabbableModule then
        grabbableModule.enabled = enabled
    end
end

--- 물리 제어 모드 설정
---@param isKinematic boolean
function SetKinematic(isKinematic)
    if rigidbodyModule and rigidbodyModule.Rigid then
        rigidbodyModule.Rigid.isKinematic = isKinematic
    end
end
--endregion
