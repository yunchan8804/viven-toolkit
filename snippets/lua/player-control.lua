--[[
    player-control.lua
    플레이어 제어 패턴

    플레이어 이동, 상호작용, 텔레포트 등 제어 기능
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

---@type GameObject
---@details 텔레포트 목적지 오브젝트
TeleportTarget = NullableInject(TeleportTarget)

---@type GameObject
---@details 잡을 수 있는 오브젝트
GrabbableTarget = NullableInject(GrabbableTarget)

---@type GameObject
---@details 앉을 수 있는 오브젝트
SittableTarget = NullableInject(SittableTarget)
--endregion

--region Local Variables
local util = require 'xlua.util'

local isMoveLocked = false
local originalSpeed = 1.0
local speedMultiplier = 1.0
--endregion

--region Lifecycle
function awake()
    Debug.Log("[PlayerControl] Awake")
end

function start()
    Debug.Log("[PlayerControl] Start")
    PrintPlayerInfo()
end

function onEnable()
    Debug.Log("[PlayerControl] OnEnable")
end

function onDisable()
    Debug.Log("[PlayerControl] OnDisable")
    -- 이동 제한 해제
    UnlockMovement()
    ResetSpeed()
end
--endregion

--region Player Info

--- 플레이어 정보 출력
function PrintPlayerInfo()
    local userId = Player.Mine.UserID
    local nickname = Player.Mine.Nickname
    local playMode = Player.Mine.PlayMode

    Debug.Log("[PlayerControl] UserID: " .. userId)
    Debug.Log("[PlayerControl] Nickname: " .. nickname)
    Debug.Log("[PlayerControl] PlayMode: " .. playMode)
end

--- 플레이어 데이터 테이블 가져오기
---@return table 플레이어 데이터
function GetPlayerData()
    local data = Player.Mine.GetPlayerData()
    return {
        nickname = data.nickname,
        userId = data.userId,
        userTag = data.userTag
    }
end

--- 프로필 이미지 가져오기 (비동기)
---@param callback function 콜백 함수(isSuccess, texture)
function GetProfileImage(callback)
    Player.Mine.GetPlayerProfileImage(function(isSuccess, texture)
        if isSuccess then
            Debug.Log("[PlayerControl] 프로필 이미지 로드 성공")
        else
            Debug.Log("[PlayerControl] 프로필 이미지 로드 실패")
        end

        if callback then
            callback(isSuccess, texture)
        end
    end)
end
--endregion

--region Movement Control

--- 이동 잠금
function LockMovement()
    Player.Mine.CharacterMoveLock = true
    isMoveLocked = true
    Debug.Log("[PlayerControl] 이동 잠금")
end

--- 이동 잠금 해제
function UnlockMovement()
    Player.Mine.CharacterMoveLock = false
    isMoveLocked = false
    Debug.Log("[PlayerControl] 이동 잠금 해제")
end

--- 이동 잠금 토글
function ToggleMovementLock()
    if isMoveLocked then
        UnlockMovement()
    else
        LockMovement()
    end
end

--- 속도 배율 설정
---@param multiplier number 속도 배율 (0.01 ~ 5)
function SetSpeedMultiplier(multiplier)
    multiplier = Mathf.Clamp(multiplier, 0.01, 5)
    speedMultiplier = multiplier
    Player.Mine.MultiplyPlayerSpeed(multiplier)
    Debug.Log("[PlayerControl] 속도 배율: " .. multiplier)
end

--- 속도 초기화
function ResetSpeed()
    Player.Mine.ResetPlayerSpeed()
    speedMultiplier = 1.0
    Debug.Log("[PlayerControl] 속도 초기화")
end

--- 카메라 잠금
---@param lockMode string|boolean "None" | "Lock" | "HardLocked" 또는 boolean (호환성)
--- VivenCameraLockMode: None (해제), Lock (잠금), HardLocked (강제 잠금)
function SetCameraLock(lockMode)
    if type(lockMode) == "boolean" then
        -- 호환성: boolean 지원
        if lockMode then
            Player.Mine.SetCameraLock(VivenCameraLockMode.Lock)
        else
            Player.Mine.SetCameraLock(VivenCameraLockMode.None)
        end
    elseif lockMode == "HardLocked" then
        Player.Mine.SetCameraLock(VivenCameraLockMode.HardLocked)
    elseif lockMode == "Lock" then
        Player.Mine.SetCameraLock(VivenCameraLockMode.Lock)
    else
        Player.Mine.SetCameraLock(VivenCameraLockMode.None)
    end
end
--endregion

--region Teleport

--- 좌표로 텔레포트
---@param x number X 좌표
---@param y number Y 좌표
---@param z number Z 좌표
---@param rotationY number Y 회전 (옵션)
function TeleportTo(x, y, z, rotationY)
    local pos = Vector3(x, y, z)
    local rot = Quaternion.Euler(0, rotationY or 0, 0)

    Player.Mine.TeleportPlayer(pos, rot)
    Debug.Log("[PlayerControl] 텔레포트: " .. tostring(pos))
end

--- 오브젝트 위치로 텔레포트
---@param targetObject GameObject 목적지 오브젝트
function TeleportToObject(targetObject)
    if targetObject == nil then
        Debug.Log("[PlayerControl] 텔레포트 대상이 없습니다")
        return
    end

    local pos = targetObject.transform.position
    local rot = targetObject.transform.rotation

    Player.Mine.TeleportPlayer(pos, rot)
    Debug.Log("[PlayerControl] 텔레포트 (오브젝트): " .. targetObject.name)
end

--- 주입된 텔레포트 타겟으로 텔레포트
function TeleportToTarget()
    TeleportToObject(TeleportTarget)
end

--- 페이드와 함께 텔레포트
---@param targetObject GameObject 목적지 오브젝트
---@param fadeDuration number 페이드 시간
function TeleportWithFade(targetObject, fadeDuration)
    fadeDuration = fadeDuration or 0.5

    UI.FadeOut(fadeDuration, function()
        TeleportToObject(targetObject)

        UI.FadeIn(fadeDuration, function()
            Debug.Log("[PlayerControl] 텔레포트 완료")
        end)
    end)
end
--endregion

--region Interaction

--- 오브젝트 잡기 시도 (비동기 - Task<bool> 반환)
---@param grabbable VivenGrabbableModule 잡을 모듈
---@param isLeft boolean 왼손 사용 여부 (기본값: false = 오른손)
---@param isForce boolean 기존에 잡고있는 모듈을 놓게 할지 여부 (기본값: false)
---@return boolean 잡기 성공 여부 (xLua가 Task를 자동 처리)
function TryGrab(grabbable, isLeft, isForce)
    if grabbable == nil then
        Debug.Log("[PlayerControl] 잡을 대상이 없습니다")
        return false
    end

    isLeft = isLeft or false
    isForce = isForce or false

    local success = Player.Mine.TryGrab(grabbable, isLeft, isForce, GrabInterpolation.All)

    if success then
        Debug.Log("[PlayerControl] 잡기 성공")
    else
        Debug.Log("[PlayerControl] 잡기 실패")
    end

    return success
end

--- 주입된 오브젝트 잡기 시도
---@param isLeft boolean 왼손 사용 여부
function TryGrabTarget(isLeft)
    if GrabbableTarget == nil then
        Debug.Log("[PlayerControl] GrabbableTarget이 없습니다")
        return
    end

    local grabbable = GrabbableTarget:GetComponent("VivenGrabbableModule")
    TryGrab(grabbable, isLeft, false)
end

--- 앉기 시도
---@param sittable VivenSittable 앉을 대상
function TrySit(sittable)
    if sittable == nil then
        Debug.Log("[PlayerControl] 앉을 대상이 없습니다")
        return
    end

    Player.Mine.Sit(sittable)
    Debug.Log("[PlayerControl] 앉기 시도")
end

--- 주입된 오브젝트에 앉기 시도
function TrySitTarget()
    if SittableTarget == nil then
        Debug.Log("[PlayerControl] SittableTarget이 없습니다")
        return
    end

    local sittable = SittableTarget:GetComponent("VivenSittable")
    TrySit(sittable)
end

--- 모든 상호작용 종료
function EndAllInteractions()
    Player.Mine.EndAllInteractions()
    Debug.Log("[PlayerControl] 모든 상호작용 종료")
end
--endregion

--region Character Access

--- 캐릭터 머리 Transform 가져오기
---@return Transform 머리 Transform
function GetHeadTransform()
    return Player.Mine.CharacterHead
end

--- 캐릭터 오른손 Transform 가져오기
---@return Transform 오른손 Transform
function GetRightHandTransform()
    return Player.Mine.CharacterRightHand
end

--- 캐릭터 왼손 Transform 가져오기
---@return Transform 왼손 Transform
function GetLeftHandTransform()
    return Player.Mine.CharacterLeftHand
end

--- 캐릭터 Animator 가져오기
---@return Animator Animator
function GetAnimator()
    return Player.Mine.CharacterAnimator
end
--endregion

--region Avatar

--- 아바타 변경 (프롬프트 표시)
---@param avatarId string 아바타 UUID
function ChangeAvatar(avatarId)
    if avatarId == nil or avatarId == "" then
        Debug.Log("[PlayerControl] 아바타 ID가 없습니다")
        return
    end

    Player.Mine.ChangeAvatar(avatarId)
    Debug.Log("[PlayerControl] 아바타 변경 요청: " .. avatarId)
end
--endregion
