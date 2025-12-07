---Grabbable 오브젝트 핸들러 템플릿

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

--region Haptic Functions
---@param controllerIntensity number 컨트롤러 진동 강도 (0.0 ~ 1.0)
---@param controllerDuration number 컨트롤러 진동 지속시간 (초)
---@param gloveIntensity number 장갑 진동 강도 (0.0 ~ 1.0)
---@param gloveDuration number 장갑 진동 지속시간 (밀리초)
function playHapticFeedback(controllerIntensity, controllerDuration, gloveIntensity, gloveDuration)
    if XRHandAPI.GetHandTrackingMode() == "None" then
        -- 컨트롤러 모드
        XR.StartControllerVibration(false, controllerIntensity, controllerDuration)
    else
        -- 비햅틱스 장갑 모드
        HandTracking.CommandVibrationHaptic(gloveIntensity, gloveDuration, Handedness.Right, FingerType.Index, false)
        HandTracking.CommandVibrationHaptic(gloveIntensity, gloveDuration, Handedness.Right, FingerType.Thumb, false)
    end
end
--endregion

--region Public Functions
function GetIsGrabbed()
    return isGrabbed
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
--endregion
