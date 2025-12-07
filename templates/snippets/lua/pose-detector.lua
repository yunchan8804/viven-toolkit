---손 포즈/제스처 감지 핸들러 템플릿

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

---@type GameObject
---@details 포즈 감지기 오브젝트
poseDetectorObject = checkInject(poseDetectorObject)

---@type GameObject
---@details 방향 감지기 오브젝트 (선택)
directionDetectorObject = checkInject(directionDetectorObject)

---@type string
---@details 게임 매니저 스크립트 이름
gameManagerName = checkInject(gameManagerName)
--endregion

--region Variables
XRHandAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.XRHandAPI
InteractionAPI = CS.TwentyOz.VivenSDK.ExperimentExtension.Scripts.API.Experiment.InteractionAPI

---@type GameManager
local gameManager = nil

---@type VivenPoseOrGestureInteraction
local poseDetector = nil

---@type VivenPoseOrGestureInteraction
local directionDetector = nil

---@type VivenGrabbableModule
local grabbableModule = nil

---@type boolean
local isPoseDetected = false

---@type boolean
local isDirectionDetected = false

---@type boolean
local isValidGrab = false
--endregion

--region Unity Lifecycle
function awake()
    gameManager = self:GetLuaComponentInParent(gameManagerName)
    poseDetector = poseDetectorObject:GetComponent("VivenPoseOrGestureInteraction")
    directionDetector = directionDetectorObject:GetComponent("VivenPoseOrGestureInteraction")
    grabbableModule = self:GetComponent("VivenGrabbableModule")
end

function onEnable()
    -- 포즈 감지 이벤트 등록
    poseDetector.onPoseOrGesturePerformed:AddListener(onPoseDetected)
    poseDetector.onPoseOrGestureEnded:AddListener(onPoseEnded)

    -- 방향 감지 이벤트 등록
    directionDetector.onPoseOrGesturePerformed:AddListener(onDirectionDetected)
    directionDetector.onPoseOrGestureEnded:AddListener(onDirectionEnded)
end

function onDisable()
    -- 포즈 감지 이벤트 해제
    poseDetector.onPoseOrGesturePerformed:RemoveListener(onPoseDetected)
    poseDetector.onPoseOrGestureEnded:RemoveListener(onPoseEnded)

    -- 방향 감지 이벤트 해제
    directionDetector.onPoseOrGesturePerformed:RemoveListener(onDirectionDetected)
    directionDetector.onPoseOrGestureEnded:RemoveListener(onDirectionEnded)
end
--endregion

--region Pose Events
function onPoseDetected()
    isPoseDetected = true
    Debug.Log("포즈 감지됨")

    checkValidGrab()
end

function onPoseEnded()
    isPoseDetected = false
    isValidGrab = false
    Debug.Log("포즈 종료됨")
end

function onDirectionDetected()
    isDirectionDetected = true
    Debug.Log("방향 감지됨")

    checkValidGrab()
end

function onDirectionEnded()
    isDirectionDetected = false
    isValidGrab = false
    Debug.Log("방향 종료됨")
end
--endregion

--region Validation
function checkValidGrab()
    -- 포즈와 방향이 모두 올바른 경우
    if isPoseDetected and isDirectionDetected then
        isValidGrab = true
        Debug.Log("올바른 잡기 자세")

        -- Interactor와 접촉 중이면 강제 잡기 시도
        if InteractionAPI.GetVerifiedColsCount(grabbableModule) > 0 then
            XRHandAPI.ForceGrabHandTracking(grabbableModule, false) -- 오른손
        end
    end
end
--endregion

--region Interaction Events
function onGrab()
    -- Hand Tracking 모드에서 올바른 포즈가 아니면 경고
    if XRHandAPI.GetHandTrackingMode() ~= "None" and not isValidGrab then
        Debug.Log("올바르지 않은 잡기 자세")
        -- 경고 UI 표시 등
        return
    end

    -- 정상 잡기 처리
    if gameManager ~= nil then
        gameManager.OnGrabObject()
    end
end

function onRelease()
    isValidGrab = false

    if gameManager ~= nil then
        gameManager.OnReleaseObject()
    end
end
--endregion

--region Public Functions
function GetIsPoseDetected()
    return isPoseDetected
end

function GetIsDirectionDetected()
    return isDirectionDetected
end

function GetIsValidGrab()
    return isValidGrab
end
--endregion
