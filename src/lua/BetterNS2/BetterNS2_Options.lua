Script.Load("lua/menu2/widgets/GUIMenuDropdownWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuCheckboxWidgetLabeled.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuColorPickerWidget.lua")

BNS2_Checkbox = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Tooltip"})
BNS2_ColorPicker = GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip"})
BNS2_Dropdown = GetMultiWrappedClass(GUIMenuDropdownWidget, {"Option", "Tooltip"})
BNS2_Slider = GetMultiWrappedClass(GUIMenuSliderEntryWidget, {"Option", "Tooltip"})

function PrepareCheckbox(option)
    print("enter prep checkbox")
    local preppedOption = {
        name = option.name,
        class = BNS2_Checkbox,
        params = {
            optionType = "bool",
            default = option.defaultValue,

            tooltip = option.tooltip,
            tooltip = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        }
    }
    print("length of preppedcheckbox - %s", tostring(table.getn(preppedOption)))
    return preppedOption
end

function PrepareDropdown(option)

end

function PrepareColorPicker(option)

end

function PrepareSlider(option)

end

local factories = {
    checkbox = PrepareCheckbox,
    dropdown = PrepareDropdown,
    colorPicker = PrepareColorPicker,
    slider = PrepareSlider,
}

local function CreateBetterNS2MenuHeaders(displayHeaders)
    local menu = {}

    for _, header in ipairs(displayHeaders) do
        table.insert(menu, {[header] = {}})
    end

    return menu
end

local function BetterNS2OptionGenerator(option)
    print("enter option generator")
    local optionType = option.type
    print(option.type)
    local factory = factories[optionType]

    if not factory then
        Print("BetterNS2 option entry %s (%s) is not yet supported!", option.name, optionType)
        return
    end

    local preppedOption = factory(option)

    return preppedOption
end

function CreateBetterNS2Menu()
    local displayHeaders = BetterNS2OptionsCategories
    local options = BetterNS2Options

    local menu = CreateBetterNS2MenuHeaders(displayHeaders)

    for _, option in ipairs(options) do
        local createdOption = BetterNS2OptionGenerator(option)
        print("length of createdOption - %s", tostring(table.getn(createdOption)))
        print(option.category)
        print("option.category - %s", string.format(option.category))
        print("length of menu[option.category] -- %s", tostring(table.getn(menu[option.category])))
        if assert(createdOption, string.format("createdOption is null")) then
            table.insert(menu[option.category], createdOption)
        end
    end

    return menu
end

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

-- Register options categories here
BetterNS2OptionsCategories = {
    "alienvision",
}

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
BetterNS2Options = {
    {
        name = "BETTERNS2_AVGorgeUnique",
        label = "Colour Gorges Seperately",
        tooltip = "Allows you to seperately colour Gorges.\n Applies to babblers too.",
        type = "checkbox",
        values  = { "Off", "On" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        hideValues = { 0 },
        children = { "av_colorgorge", "av_gorgeintensity" },
        applyFunction = function() updateAlienVision() end,
        sort = "C14",
        parent = "av",
    },
}
