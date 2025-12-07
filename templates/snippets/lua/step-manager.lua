---IStep 기반 게임 플로우 매니저 템플릿

IStep = ImportLuaScript(IStep)
GameCallback = ImportLuaScript(EventCallbacks)

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end

---@type Timeline
---@details 게임 타임라인
GameTimeline = checkInject(GameTimeline)

---@type GameObject
---@details 타임라인 매니저 오브젝트
TimelineManagerObject = checkInject(TimelineManagerObject)

-- 스텝별 오브젝트 주입
---@type GameObject
Step1ActiveObject = checkInject(Step1ActiveObject)

---@type GameObject
Step2ActiveObject = checkInject(Step2ActiveObject)
--endregion

--region Variables
---@type TimelineManager
local timelineManager = nil

---@type table
local steps = {}

---@type number
local currentStepIndex = 1

---@type boolean
local isGameStarted = false

---@type boolean
local isGamePaused = false
--endregion

--region Unity Lifecycle
function awake()
    timelineManager = TimelineManagerObject:GetLuaComponent("TimelineManager")
    initSteps()
end

function start()
end
--endregion

--region Step Initialization
function initSteps()
    -- 스텝 1
    steps[1] = IStep:new(
        { Step1ActiveObject },          -- 활성화할 오브젝트
        nil,                            -- 비활성화할 오브젝트
        0.0,                            -- 타임라인 시간
        1,                              -- 스텝 번호
        "step1Complete",                -- 클리어 조건
        { onStep1Start },               -- 시작 콜백
        { onStep1Reset },               -- 리셋 콜백
        nil                             -- 스킵 콜백
    )

    -- 스텝 2
    steps[2] = IStep:new(
        { Step2ActiveObject },
        { Step1ActiveObject },
        5.0,
        2,
        "step2Complete",
        { onStep2Start },
        { onStep2Reset },
        nil
    )

    -- 스텝 3 (매개변수 있는 콜백 예시)
    steps[3] = IStep:new(
        nil,
        { Step2ActiveObject },
        10.0,
        3,
        "gameComplete",
        { { onStepStartWithParam, "param1", "param2" } },
        nil,
        nil
    )
end
--endregion

--region Step Callbacks
function onStep1Start()
    Debug.Log("스텝 1 시작")
end

function onStep1Reset()
    Debug.Log("스텝 1 리셋")
end

function onStep2Start()
    Debug.Log("스텝 2 시작")
end

function onStep2Reset()
    Debug.Log("스텝 2 리셋")
end

function onStepStartWithParam(param1, param2)
    Debug.Log("스텝 시작 with params: " .. param1 .. ", " .. param2)
end
--endregion

--region Game Flow Control
function StartGame()
    if isGameStarted then return end

    isGameStarted = true
    isGamePaused = false
    currentStepIndex = 1

    -- 타임라인 시작
    timelineManager.StartTimeline(GameTimeline)

    -- 첫 번째 스텝 시작
    steps[currentStepIndex]:OnStepStart()
end

function PauseGame()
    if not isGameStarted or isGamePaused then return end

    isGamePaused = true
    timelineManager.PauseTimeline()
end

function ResumeGame()
    if not isGameStarted or not isGamePaused then return end

    isGamePaused = false
    timelineManager.ResumeTimeline()
end

function EndGame()
    if not isGameStarted then return end

    isGameStarted = false
    isGamePaused = false
    timelineManager.StopTimeline()

    -- 게임 종료 콜백 호출
    GameCallback.invoke("onGameEnd")
end

function ResetGame()
    EndGame()

    -- 모든 스텝 리셋
    for i = 1, #steps do
        steps[i]:OnStepReset()
    end

    currentStepIndex = 1
end
--endregion

--region Clear Condition
function CheckClearCondition(condition)
    if not isGameStarted or isGamePaused then return end

    local currentStep = steps[currentStepIndex]
    if currentStep == nil then return end

    if currentStep.clearCondition == condition then
        -- 현재 스텝 클리어
        currentStep:OnStepClear()

        -- 다음 스텝으로 이동
        currentStepIndex = currentStepIndex + 1

        if steps[currentStepIndex] ~= nil then
            -- 다음 스텝 시작
            steps[currentStepIndex]:OnStepStart()

            -- 타임라인 시간 이동
            timelineManager.SkipTimeline(steps[currentStepIndex].time)
        else
            -- 모든 스텝 완료
            onAllStepsCompleted()
        end
    end
end

function onAllStepsCompleted()
    Debug.Log("모든 스텝 완료!")
    GameCallback.invoke("onGameComplete")
end
--endregion

--region Getters
function GetCurrentStepIndex()
    return currentStepIndex
end

function GetIsGameStarted()
    return isGameStarted
end

function GetIsGamePaused()
    return isGamePaused
end

function GetPaused()
    return isGamePaused
end
--endregion
