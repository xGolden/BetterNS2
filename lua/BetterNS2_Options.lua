local function BetterNS2RestartScripts(scripts)
    for _, currentScript in ipairs(scripts) do
        local script = ClientUI.GetScript(currentScript)
        if script then
            script:Uninitialize()
            script:Initialize()
        end
    end
end

local uiScaleTime = 0
local function BetterNS2ApplyNewUIScale()
    uiScaleTime = Shared.GetTime()
end

local function CheckUIScaleTime()
    if uiScaleTime ~= 0 and uiScaleTime + 1 < Shared.GetTime() then
        local xRes = Client.GetScreenWidth()
        local yRes = Client.GetScreenHeight()
        GetGUIManager():OnResolutionChanged(xRes, yRes, xRes, yRes)
        uiScaleTime = 0
    end
end

Event.Hook("UpdateRender", CheckUIScaleTime)

--[[ Register Options here
optionname = {
    name = "",
    label = "",
    tooltip = "",
    type = "",
    values = {},
    defaultValue = x,
    category = "",
    valueType = "",
    sort = "",

    -- optional parameters
    applyFunction = function()
        FunctionName()
    end,
    parent = ""
    minValue = x,
    maxValue = y,
    decimalPlaces = z,
    applyOnLoadComplete = bool,
    resetSettingInBuild = t
}
]]
BetterNS2Options = {}
