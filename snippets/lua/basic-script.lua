---[스크립트 설명을 여기에 작성]

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

--[[
    ---@type TYPE_OF_VARIABLE
    ---@details : 설명
    OBJECT = checkInject(OBJECT) -- {displayName}
]]

---@type GameObject
---@details 설명
TargetObject = checkInject(TargetObject)

---@type string
---@details 게임 매니저 스크립트 이름
gameManagerName = checkInject(gameManagerName)
--endregion

--region Variables
---@type GameManager
local gameManager = nil
--endregion

--region Unity Lifecycle
function awake()
    gameManager = self:GetLuaComponentInParent(gameManagerName)
end

function start()
end

function onEnable()
end

function onDisable()
end

function update()
end

function fixedUpdate()
end
--endregion

--region Event Handlers
--endregion

--region Public Functions
--endregion
