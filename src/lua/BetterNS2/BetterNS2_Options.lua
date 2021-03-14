Script.Load('lua/BetterNS2/BetterNS2_FileManagement.lua')

BNS2_Checkbox = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Tooltip"})
BNS2_ColorPicker = GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip"})
BNS2_Dropdown = GetMultiWrappedClass(GUIMenuDropdownWidget, {"Option", "Tooltip"})
BNS2_Slider = GetMultiWrappedClass(GUIMenuSliderEntryWidget, {"Option", "Tooltip"})

BNS2_Expandable_Checkbox = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Tooltip", "Expandable"})
BNS2_Expandable_ColorPicker = GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip", "Expandable"})
BNS2_Expandable_Dropdown = GetMultiWrappedClass(GUIMenuDropdownWidget, {"Option", "Tooltip", "Expandable"})
BNS2_Expandable_Slider = GetMultiWrappedClass(GUIMenuSliderEntryWidget, {"Option", "Tooltip", "Expandable"})

BNS2_Expandable_Button = GetMultiWrappedClass(GUIMenuButton, {"Expandable"})

function BetterNS2GetOption(key)
    local value = GetOptionsMenu():GetOptionWidget(key):GetValue()
    if type(value) == "cdata" and value:isa("Color") then
        value = ColorToColorInt(value)
    elseif type(value) == "boolean" then
        value = value and 1 or 0
    end
    return value
end

function BetterNS2SetOption(key, value)
    GetOptionsMenu():GetOptionWidget(key):SetValue(value)
end

local function updateAlienVisionInGame()
    if kInGame then
        UpdateAlienVision()
    end
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

local function BetterNS2RestartInGameScripts(scripts)
    if kInGame then
        BetterNS2RestartScripts(scripts)
    end
end

local function SyncContentsSize(self, size)
    self:SetContentsSize(size)
end

local function SyncParentContentsSizeToLayout(self)
    local parent = self:GetParent():GetParent():GetParent()
    assert(parent)

    parent:HookEvent(self, "OnSizeChanged", SyncContentsSize)
end

local function CreateHeaderGroup(paramsTable)
    RequireType({"table", "nil"}, paramsTable.params, "paramsTable.params", 2)

    return {
        name = paramsTable.name,
        class = GUIMenuExpandableGroup,
        params = CombineParams(paramsTable.params or {}, { expansionMargin = 4 }),
        properties = {
            { "Label", paramsTable.label }
        },
        children = {
            {
                name = "layout",
                class = GUIListLayout,
                params = {
                    orientation = "vertical",
                },
                properties = {
                    { "FrontPadding", 32 },
                    { "BackPadding", 32 },
                    { "Spacing", 15 },
                },
                postInit = { SyncParentContentsSizeToLayout },
                children = paramsTable.children
            }
        }
    }
end

local function createPostInitFunctionFromParent(parent)
    assert(parent)
    if parent == "BETTERNS2_AV" then
        return function(self)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            self:SetExpanded(crazyAVSelected)
        end
    elseif parent == "BETTERNS2_AVStyle" then
        return function(self)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        local customAVStyleValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVStyle"):GetValue()
                        local customAVStyleSelected = customAVStyleValue ~= 0
                        self:SetExpanded(crazyAVSelected and customAVStyleSelected)
                    end)
            self:HookEvent(GetOptionsMenu(): GetOptionWidget("BETTERNS2_AVStyle"), "OnValueChanged",
                    function(self, value)
                        local customAVStyleSelected = value ~= 0
                        local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
                        local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected and customAVStyleSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            local customAVStyleValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVStyle"):GetValue()
            local customAVStyleSelected = customAVStyleValue ~= 0
            self:SetExpanded(crazyAVSelected and customAVStyleSelected)
        end
    elseif parent == "BETTERNS2_AVGorgeUnique" then
        return function(self)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        local avGorgeUniqueSelected = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVGorgeUnique"):GetValue()
                        self:SetExpanded(crazyAVSelected and avGorgeUniqueSelected)
                    end)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AVGorgeUnique"), "OnValueChanged",
                    function(self, value)
                        local avGorgeUniqueSelected = value
                        local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
                        local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected and avGorgeUniqueSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            local avGorgeUniqueSelected = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVGorgeUnique"):GetValue()
            self:SetExpanded(crazyAVSelected and avGorgeUniqueSelected)
        end
    elseif parent == "BETTERNS2_AVDesaturation" then
        return function(self)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        local avDesaturationValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVDesaturation"):GetValue()
                        local avDesaturationSelected = avDesaturationValue ~= 0
                        self:SetExpanded(crazyAVSelected and avDesaturationSelected)
                    end)
            self:HookEvent(GetOptionsMenu(): GetOptionWidget("BETTERNS2_AVDesaturation"), "OnValueChanged",
                    function(self, value)
                        local avDesaturationSelected = value ~= 0
                        local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
                        local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected and avDesaturationSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            local avDesaturationValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVDesaturation"):GetValue()
            local avDesaturationSelected = avDesaturationValue ~= 0
            self:SetExpanded(crazyAVSelected and avDesaturationSelected)
        end
    elseif parent == "BETTERNS2_AVViewModelStyle" then
        return function(self)
            self:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        local avViewModelStyleValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVViewModelStyle"):GetValue()
                        local avViewModelStyleSelected = avViewModelStyleValue ~= 1
                        self:SetExpanded(crazyAVSelected and avViewModelStyleSelected)
                    end)
            self:HookEvent(GetOptionsMenu(): GetOptionWidget("BETTERNS2_AVViewModelStyle"), "OnValueChanged",
                    function(self, value)
                        local avViewModelStyleSelected = value ~= 1
                        local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
                        local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected and avViewModelStyleSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            local avViewModelStyleValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AVViewModelStyle"):GetValue()
            local avViewModelStyleSelected = avViewModelStyleValue ~= 1
            self:SetExpanded(crazyAVSelected and avViewModelStyleSelected)
        end
    end
end

function PrepareCheckbox(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_Checkbox,
        params = {
            optionPath = option.name,
            optionType = "bool",
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        }
    }

    return preppedOption
end

function PrepareExpandableCheckbox(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_Expandable_Checkbox,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label},
        },
        postInit = {
            createPostInitFunctionFromParent(option.parent),
        }
    }

    return preppedOption
end

function PrepareDropdown(option)
    local choices = {}
    if option.optionType == "bool" then
        choices = {
            { value = false, displayString = option.choices[1] },
            { value = true, displayString = option.choices[2] }
        }
    elseif option.optionType == "string" then
        choices = option.choices
    else

        for i, v in ipairs(option.choices) do
            table.insert(choices, { value = i - 1, displayString = v})
        end
    end

    local preppedOption = {
        name = option.name,
        class = BNS2_Dropdown,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label},
            {"Choices", choices}
        }
    }

    return preppedOption
end

function PrepareExpandableDropdown(option)
    local choices = {}
    if option.optionType == "bool" then
        choices = {
            { value = false, displayString = option.choices[1] },
            { value = true, displayString = option.choices[2] }
        }
    else
        for i, v in ipairs(option.choices) do
            table.insert(choices, { value = i - 1, displayString = v})
        end
    end

    local preppedOption = {
        name = option.name,
        class = BNS2_Expandable_Dropdown,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label},
            {"Choices", choices},
        },
        postInit = {
            createPostInitFunctionFromParent(option.parent),
        }
    }
    return preppedOption
end

function PrepareColorPicker(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_ColorPicker,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        }
    }

    return preppedOption
end

function PrepareExpandableColorPicker(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_Expandable_ColorPicker,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        },
        postInit = {
            createPostInitFunctionFromParent(option.parent),
        }
    }

    return preppedOption
end

function PrepareSlider(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_Slider,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            minValue = option.minValue,
            maxValue = option.maxValue,
            decimalPlaces = option.decimalPlaces or 2,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        }
    }

    return preppedOption
end

function PrepareExpandableSlider(option)
    local preppedOption = {
        name = option.name,
        class = BNS2_Expandable_Slider,
        params = {
            optionPath = option.name,
            optionType = option.optionType,
            default = option.default,

            minValue = option.minValue,
            maxValue = option.maxValue,
            decimalPlaces = option.decimalPlaces or 2,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
            immediateUpdate = option.immediateUpdate
        },
        properties = {
            {"Label", option.label}
        },
        postInit = {
            createPostInitFunctionFromParent(option.parent),
        }
    }

    return preppedOption
end

function PrepareButton(button)
    local preppedButton = {
        name = button.name,
        class = BNS2_Expandable_Button,
        properties = {
            {"Label", button.label},
        },
        postInit = button.postInit,
    }

    return preppedButton
end

local factories = {
    checkbox = PrepareCheckbox,
    expandable_checkbox = PrepareExpandableCheckbox,
    dropdown = PrepareDropdown,
    expandable_dropdown = PrepareExpandableDropdown,
    colorpicker = PrepareColorPicker,
    expandable_colorpicker = PrepareExpandableColorPicker,
    slider = PrepareSlider,
    expandable_slider = PrepareExpandableSlider,
    button = PrepareButton,
}

local function CreateBetterNS2MenuHeaders(displayHeaders)
    local menu = {}

    for _, header in ipairs(displayHeaders) do
        menu[header] = {}
    end

    return menu
end

local function BetterNS2OptionGenerator(option)
    local optionType = option.type
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

    local groupedHeaders = CreateBetterNS2MenuHeaders(displayHeaders)

    for _, option in ipairs(options) do
        local preppedOption = BetterNS2OptionGenerator(option)

        assert(preppedOption, string.format("Failed to create option %s", option.name))
        table.insert(groupedHeaders[option.category], preppedOption)
    end

    local menu = {}

    for i,v in pairs(groupedHeaders) do
        local header = string.upper(i)
        table.insert(menu, CreateHeaderGroup {
            name = string.format("betterns2%sOptions", header),
            label = header,
            children = v
        })
    end

    -- TODO: Add a reset all button

    return menu
end

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
    optionType = "",
    values = {},
    default = x,
    category = "",
    sort = "",

    -- optional parameters
    immediateUpdate = function() FunctionName() end,
    parent = ""
    minValue = x,
    maxValue = y,
    decimalPlaces = z,
}
]]
BetterNS2Options = {
    {
        name = "BETTERNS2_AV",
        label = "Alien vision",
        tooltip = "Lets you choose between different Alien Vision types. Please note that Cr4zyAV may negatively impact the game's performance!",
        type = "dropdown",
        optionType = "string",
        choices  = {
            { value = "shaders/DarkVision.screenfx", displayString = "Default" },
            { value = "shaders/HuzeOldAV.screenfx", displayString = "Huze's Old AV" },
            { value = "shaders/HuzeMinAV.screenfx", displayString = "Huze's Minimal AV" },
            { value = "shaders/UkeAV.screenfx", displayString = "Uke's AV" },
            { value = "shaders/FantaVision.screenfx", displayString = "Old AV (Fanta)" },
            { value = "shaders/Cr4zyAV.screenfx", displayString = "Cr4zyAV Configurable" },
        },
        default = "shaders/DarkVision.screenfx",
        category = "alienvision",
        immediateUpdate = function() BetterNS2RestartInGameScripts({ "GUIAlienHUD" }) end,
        children = { "av_colormarine", "av_marineintensity", "av_coloralien", "av_alienintensity", "av_style", "av_offstyle", "av_closecolor", "av_closeintensity", "av_distantcolor", "av_distantintensity", "av_playercolor", "av_gorgeunique", "av_structurecolor", "av_blenddistance", "av_worldintensity", "av_edges", "av_edgesize", "av_desaturation", "av_viewmodelstyle", "av_activationeffect", "av_skybox", "av_colormarinestruct", "av_mstructintensity", "av_coloralienstruct", "av_astructintensity" },
        hideValues = { 0, 1, 2, 3, 4 },
        sort = "C02",
    },
    {
        name = "BETTERNS2_AVSave",
        label = "Save",
        type = "button",
        category = "alienvision",
        parent = "BETTERNS2_AV",
        postInit = function(createdObj)
            createdObj:HookEvent(createdObj, "OnPressed",
                    function()
                        HandleSaveAlienVision()
                    end)
            createdObj:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            createdObj:SetExpanded(crazyAVSelected)
        end
    },
    {
        name = "BETTERNS2_AVLoad",
        label = "Load",
        type = "button",
        category = "alienvision",
        parent = "BETTERNS2_AV",
        postInit = function(createdObj)
            createdObj:HookEvent(createdObj, "OnPressed",
                    function()
                        HandleLoadAlienVision()
                    end)
            createdObj:HookEvent(GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"), "OnValueChanged",
                    function(self, value)
                        local crazyAVSelected = value == "shaders/Cr4zyAV.screenfx"
                        self:SetExpanded(crazyAVSelected)
                    end)

            local betterns2AVValue = GetOptionsMenu():GetOptionWidget("BETTERNS2_AV"):GetValue()
            local crazyAVSelected = betterns2AVValue == "shaders/Cr4zyAV.screenfx"
            createdObj:SetExpanded(crazyAVSelected)
        end
    },
    {
        name = "BETTERNS2_AVStyle",
        label = "Alien Vision Style",
        tooltip = "Switches between different configurable styles of Alien Vision.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Minimal", "Original", "Depth Fog", "Edge and World" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        tooltipIcon = "ui/tooltipIcons/av_style.dds",
        tooltipIconSize = Vector(512, 256, 0),
        children = { "av_closecolor", "av_closeintensity", "av_distantcolor", "av_distantintensity" },
        hideValues = { 0 },
        sort = "C03",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVOffStyle",
        label = "Disabled Alien Vision Style",
        tooltip = "Switches between different options for when Alien Vision is disabled.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Nothing", "Minimal world edges", "Coloured edges", "Marine only edges" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        tooltipIcon = "ui/tooltipIcons/av_offstyle.dds",
        tooltipIconSize = Vector(512, 256, 0),
        sort = "C04",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVCloseColor",
        label = "Close Colour",
        tooltip = "Sets the close world colour.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0x0030FE,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C05",
        parent = "BETTERNS2_AVStyle",
    },
    {
        name = "BETTERNS2_AVCloseIntensity",
        label = "Close Intensity",
        tooltip = "Sets the 'brightness' value of the closer colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C068",
        parent = "BETTERNS2_AVStyle"
    },
    {
        name = "BETTERNS2_AVDistantColor",
        label = "Distant Colour",
        tooltip = "Sets the distant world colour.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0x49006E,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C07",
        parent = "BETTERNS2_AVStyle"
    },
    {
        name = "BETTERNS2_AVDistantIntensity",
        label = "Distant Intensity",
        tooltip = "Sets the 'brightness' value of the distant colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C08",
        parent = "BETTERNS2_AVStyle"
    },
    {
        name = "BETTERNS2_AVPlayerColor",
        label = "Players to Colour",
        tooltip = "Allows Players to be coloured separately.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "All Players", "Marines Only", "Alien Only", "No Players" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C09",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVColorMarine",
        label = "Marine Player Colour",
        tooltip = "Selects the colour for Marine players.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0xFF8900,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C10",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVMarineIntensity",
        label = "Marine Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Marine colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C11",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVColorAlien",
        label = "Alien Player Colour",
        tooltip = "Selects the colour for Alien players.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0x008CFE,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C12",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVAlienIntensity",
        label = "Alien Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Alien colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C13",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVGorgeUnique",
        label = "Colour Gorges Seperately",
        tooltip = "Allows you to seperately colour Gorges.\n Applies to babblers too.",
        type = "expandable_checkbox",
        optionType = "bool",
        default = false,
        category = "alienvision",
        hideValues = { 0 },
        children = { "av_colorgorge", "av_gorgeintensity" },
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C14",
        parent = "BETTERNS2_AV",
    },
    {
        name = "BETTERNS2_AVGorgeColor",
        label = "Gorge Colour",
        tooltip = "Selects the colour for Gorge and Babblers.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0x00FF00,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C15",
        parent = "BETTERNS2_AVGorgeUnique"
    },
    {
        name = "BETTERNS2_AVGorgeIntensity",
        label = "Gorge Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Gorge colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C16",
        parent = "BETTERNS2_AVGorgeUnique"
    },
    {
        name = "BETTERNS2_AVStructureColor",
        label = "Structures to Colour",
        tooltip = "Allows Structures to be coloured separately.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "All Structures", "Marines Structures Only", "Alien Structures Only", "No Structures" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C17",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVMStructColor",
        label = "Marine Structure Colour",
        tooltip = "Selects the colour for Marine structures.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0xFF0700,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C18",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVMStructIntensity",
        label = "Marine Structure Intensity",
        tooltip = "Sets the 'brightness' value of the Marine structure colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C19",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVAStructColor",
        label = "Alien Structure Colour",
        tooltip = "Selects the colour for Alien structures.",
        type = "expandable_colorpicker",
        optionType = "color",
        default = 0x00FE80,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C20",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVAStructIntensity",
        label = "Alien Structure Intensity",
        tooltip = "Sets the 'brightness' value of the Alien structure colour.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C21",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVBlendDistance",
        label = "Blend Distance",
        tooltip = "Allows you to modify the distance at which blending occurs for close and distant colors.",
        type = "expandable_slider",
        optionType = "float",
        default = 1.5,
        minValue = 0.0,
        maxValue = 10.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C22",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVEdges",
        label = "Edge Style",
        tooltip = "Switches between edge outlines that are uniform in size or ones that thicken in peripheral vision. Also reduce the fill colour if desired.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Normal", "Thicker Peripheral Edges", "Normal, No Fill", "Thicker Peripheral, No Fill" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C23",
        tooltipIcon = "ui/tooltipIcons/av_nofill.dds",
        tooltipIconSize = Vector(512, 256, 0),
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVEdgeSize",
        label = "Edge Thickness",
        tooltip = "Sets the thickness of edges in alien vision.",
        type = "expandable_slider",
        optionType = "float",
        default = 0.4,
        minValue = 0.0,
        maxValue = 4.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C24",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVEdgeClean",
        label = "Edge Redesign",
        tooltip = "Enables new math to improve edges in the distance. Will make edges smaller",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Old", "New" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        hideValues = { 0 },
        sort = "C25",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVWorldIntensity",
        label = "World Intensity",
        tooltip = "Sets the brightness value of the world.",
        type = "expandable_slider",
        optionType = "float",
        default = 1,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C26",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVDesaturation",
        label = "World Desaturation",
        tooltip = "Switches between different types of desaturation.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "None", "Full Scene", "Desaturate Distance", "Desaturate Close" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        children = { "av_desaturationintensity", "av_desaturationblend" },
        hideValues = { 0 },
        sort = "C27",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVDesaturationIntensity",
        label = "Desaturation Intensity",
        tooltip = "Sets the desaturation amount.",
        type = "expandable_slider",
        optionType = "float",
        default = 0.25,
        minValue = 0.0,
        maxValue = 1.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C28",
        parent = "BETTERNS2_AVDesaturation"
    },
    {
        name = "BETTERNS2_AVDesaturationBlend",
        label = "Desaturation Blend Distance",
        tooltip = "Sets the blending range for desaturation.",
        type = "expandable_slider",
        optionType = "float",
        default = 0.25,
        minValue = 0.0,
        maxValue = 10.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C29",
        parent = "BETTERNS2_AVDesaturation"
    },
    {
        name = "BETTERNS2_AVViewModelStyle",
        label = "View Model Style",
        tooltip = "Switches between default view model or view model with AV applied.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Alien Vision", "Default" },
        default = 1,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        children = { "av_viewmodelintensity" },
        hideValues = { 1 },
        sort = "C30",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVViewModelIntensity",
        label = "View Model Intensity",
        tooltip = "Sets the amount of Alien Vision applied to the viewmodel.",
        type = "expandable_slider",
        optionType = "float",
        default = 0.5,
        minValue = 0.0,
        maxValue = 1.0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C31",
        parent = "BETTERNS2_AVViewModelStyle"
    },
    {
        name = "BETTERNS2_AVSkybox",
        label = "Skybox Style",
        tooltip = "Lets you set the way the sky appears in Alien Vision.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Normal Sky", "Black", "Alien Vision" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C32",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVActivationEffect",
        label = "Activation Effect",
        tooltip = "Sets the transition effect when enabling Alien Vision.",
        type = "expandable_dropdown",
        optionType = "int",
        choices  = { "Distance Pulse", "Fade In", "Instant On" },
        default = 0,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        sort = "C33",
        parent = "BETTERNS2_AV"
    },
    {
        name = "BETTERNS2_AVNanoshield",
        label = "Nanoshield AV highlight",
        tooltip = "Improves nanoshield visibility by showing an inverted colour Nano effect on marine players and structures. May have side effects in some blue and brightly lit areas",
        type = "expandable_checkbox",
        optionType = "bool",
        default = false,
        category = "alienvision",
        immediateUpdate = function() updateAlienVisionInGame() end,
        tooltipIcon = "ui/tooltipIcons/av_nano.dds",
        tooltipIconSize = Vector(384, 192, 0),
        sort = "C34",
        parent = "BETTERNS2_AV",
    },
}
