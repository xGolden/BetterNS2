BetterNS2MainMenu = decoda_name == "Main"

Script.Load("lua/Shared/BetterNS2_Utility.lua")
Script.Load("lua/BetterNS2_Settings.lua")

if not GetBetterNS2Settings then return end

Script.Load("lua/BetterNS2_Options.lua")

Script.Load("lua/menu2/widgets/GUIMenuColorPickerWidget.lua") -- doesn't get loaded by vanilla menu

local kResetButtonTexture = PrecacheAsset("ui/newMenu/resetToDefaultIcon.dds")

local function SyncContentsSize(self, size)
    self:SetContentsSize(size)
end

local function SyncParentContentsSizeToLayout(self)
    local parent = self:GetParent():GetParent():GetParent()
    assert(parent)

    parent:HookEvent(self, "OnSizeChanged", SyncContentsSize)
end

local function CreateExpandableGroup(paramsTable)

    RequireType({"table", "nil"}, paramsTable.params, "paramsTable.params", 2)

    return
    {
        name = paramsTable.name,
        class = GUIMenuExpandableGroup,
        params = CombineParams(paramsTable.params or {},
                {
                    expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
                }),
        properties =
        {
            {"Label", paramsTable.label},
        },
        children =
        {
            {
                name = "layout",
                class = GUIListLayout,
                params =
                {
                    orientation = "vertical",
                },
                properties =
                {
                    {"FrontPadding", 32},
                    {"BackPadding", 32},
                    {"Spacing", 15},
                },
                postInit =
                {
                    SyncParentContentsSizeToLayout,
                },
                children = paramsTable.children
            },
        },
    }
end

local function sortOptionEntries(a, b)
    return a.sort < b.sort
end

local function CreateOptionMenuEntryPostInit(parentOptionTbl)

    assert(parentOptionTbl)
    assert(parentOptionTbl.valueType ~= nil)
    assert(parentOptionTbl.name ~= nil)
    assert(parentOptionTbl.hideValues ~= nil)

    local hideMap = {}
    for _, v in ipairs(parentOptionTbl.hideValues) do
        hideMap[v] = true
    end

    return function(self)
        self:HookEvent(GetOptionsMenu():GetOptionWidget(parentOptionTbl.name), "OnValueChanged",
                function(this, value)
                    this:SetExpanded(hideMap[value] == nil)
                end)

        local currentValue = GetOptionsMenu():GetOptionWidget(parentOptionTbl.name):GetValue()
        self:SetExpanded(hideMap[currentValue] == nil)
    end

end

OP_TT_ColorPicker = GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip"})

local function CreateColorOptionMenuEntry(option)
    option.sort = option.sort or string.format("Z%s", option.name)
    local entry = {
        name = option.name,
        sort = option.sort,
        class = OP_TT_ColorPicker,
        params =
        {
            optionPath = option.optionPath or option.name,
            optionType = "color",
            default = option.defaultValue,

            tooltip = option.tooltip,
            tooltipIcon = option.helpImage
        }
    }

    entry.properties =
    {
        {"Label", string.upper(option.label)},
    }

    return entry

end

local function CreateSelectOptionMenuEntry(option)
    option.sort = option.sort or string.format("Z%s", option.name)
    local entry = {
        name = option.name,
        sort = option.sort,
        class = OP_TT_Choice,
        params =
        {
            optionPath = option.name,
            optionType = option.valueType,
            default = option.defaultValue,

            tooltip = option.tooltip,
            tooltipIcon = option.helpImage
        }
    }

    local choices = {}
    if option.valueType == "bool" then
        choices =
        {
            { value = false, displayString = option.values[1] },
            { value = true,  displayString = option.values[2] },
        }
    else
        choices = {}
        for i, v in ipairs(option.values) do
            table.insert(choices, {value = i - 1, displayString = string.upper(v)})
        end
    end

    entry.properties =
    {
        {"Label", string.upper(option.label)},
        {"Choices",
         choices
        }
    }

    return entry

end

local function CreateSelectBoolOptionMenuEntry(option)
    local entry =
    {
        name = option.name,
        sort = option.sort or string.format("Z%s", option.name),
        class = OP_TT_Checkbox,
        params =
        {
            optionPath = option.name,
            optionType = option.valueType,
            default = option.defaultValue,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,
        }
    }

    entry.properties =
    {
        {"Label", string.upper(option.label)},
    }

    return entry

end

local function CreateSliderOptionMenuEntry(option)
    local entry = {
        name = option.name,
        sort = option.sort or string.format("Z%s", option.name),
        class = OP_TT_Number,
        params =
        {
            optionPath = option.name,
            optionType = option.valueType,
            default = option.defaultValue,

            minValue = option.minValue,
            maxValue = option.maxValue,
            decimalPlaces = option.decimalPlaces or 2,

            tooltip = option.tooltip,
            tooltipIcon = option.helpImage
        },
        properties =
        {
            {"Label", string.upper(option.label)},
        }
    }

    return entry

end

local factories = {
    select = CreateSelectOptionMenuEntry,
    selectBool = CreateSelectBoolOptionMenuEntry,
    slider = CreateSliderOptionMenuEntry,
    color = CreateColorOptionMenuEntry
}

-- Config is a GUIObject config.  postInit is either a function, or a list of functions.
-- config.postInit can be either nil, function, or list of functions.
-- Returns a copy of the config with the new postInit function(s) added.
local function AddPostInits(config, postInit)

    RequireType({"function", "table"}, postInit, "postInit", 2)
    if type(postInit) == "table" then
        assert(#postInit > 0)
    end

    -- Input table doesn't have postInit field, simple assignment.
    if config.postInit == nil then
        config.postInit = postInit
        return config
    end

    local newPostInit = {}
    -- Ensure result.postInit is a table, so we can hold multiple postInit functions.
    if type(config.postInit) == "function" then
        table.insert(newPostInit, config.postInit)
    else
        newPostInit = config.postInit
    end

    if type(postInit) == "function" then
        table.insert(newPostInit, postInit)
    else
        -- Append the postInit list to the result.postInit list.
        for i = 1, #postInit do
            table.insert(newPostInit, postInit[i])
        end
    end

    config.postInit = newPostInit

    return config

end

local function ResetOptionValue(option)
    local default = option.default
    if option:isa("GUIMenuColorPickerWidget") then
        default = ColorIntToColor(default)
    end

    option:SetValue(default)
end

local function SetupResetButton(option)
    local resetButton = option.resetButton
    assert(resetButton ~= nil)

    option:HookEvent(resetButton, "OnPressed", ResetOptionValue)
end

local function UpdateResetButtonOpacity(option)
    local resetButton = option.resetButton
    assert(resetButton ~= nil)

    local value = option:GetValue()
    local default = option.default
    if option:isa("GUIMenuColorPickerWidget") then
        default = ColorIntToColor(default)
    end

    local visible = not GetAreValuesTheSame(value, default)
    local opacityGoal = visible and 1.0 or 0.0

    resetButton:AnimateProperty("Opacity", opacityGoal, MenuAnimations.Fade)
end

local ResetButtonClass = GetMultiWrappedClass(GUIButton, {"MenuFX", "Tooltip"})
local GUIListLayout_Expandable = GetMultiWrappedClass(GUIListLayout, {"Expandable"})

local function AddResetButtonToOption(config, parentOptionTbl)

    if config.class == GUIListLayout then
        config = config.children[1]
    end

    local resetButtonClass = ResetButtonClass

    local wrappedOption =
    {
        sort = config.sort,
        name = string.format("%s_wrapped", config.name),
        class = parentOptionTbl and GUIListLayout_Expandable or GUIListLayout,
        params =
        {
            orientation = "horizontal",
            spacing = 16,
        },
        children =
        {
            -- Reset Button
            {
                name = "resetButton",
                class = resetButtonClass,
                params =
                {
                    defaultColor = HexToColor("971e1e"),
                    highlightColor = HexToColor("ff4141"),
                },
                postInit = function(self)
                    self:SetTexture(kResetButtonTexture)
                    self:SetSizeFromTexture()
                    self:AlignLeft()
                    self:SetTooltip(Locale.ResolveString("OPTION_RESET"))
                end,
            },

            -- Include original widget here.
            AddPostInits(config,
                    {
                        function(self)
                            local list = self:GetParent()
                            local resetButton = list:GetChild("resetButton")
                            assert(resetButton ~= nil)

                            self.resetButton = resetButton

                            -- Post init to adjust the resetButton's opacity based on whether or not the
                            -- value selected is the default value.
                            self:HookEvent(self, "OnValueChanged", UpdateResetButtonOpacity)
                            UpdateResetButtonOpacity(self)

                            -- Setup function for reset button
                            SetupResetButton(self)
                        end
                    }),
        },
    }

    if parentOptionTbl then
        AddPostInits(wrappedOption, CreateOptionMenuEntryPostInit(parentOptionTbl))
        wrappedOption.params.expansionMargin = 4.0
    end

    return wrappedOption
end

local optionNames = {}
local function ResetAllOptions()
    local optionMenu = GetOptionsMenu()
    assert(optionMenu)

    for i = 1, #optionNames do
        local name = optionNames[i]
        local widget = optionMenu:GetOptionWidget(name)
        assert(widget)

        ResetOptionValue(widget)
    end
end

local function ResetPopup()
    -- Make reset options a confirmation popup!
    local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
            {
                title = "RESET BETTERNS2 OPTIONS",
                message = "Reset ALL Better NS2 options to default?",
                buttonConfig =
                {
                    -- Confirm.
                    {
                        name = "confirmReset",
                        params =
                        {
                            label = "Yes, Reset",
                        },
                        callback = function(popup)
                            popup:Close()
                            ResetAllOptions()
                        end,
                    },
                    -- Cancel Button.
                    GUIPopupDialog.CancelButton,
                },
            })
end

function CreateOptionMenuEntry(option)
    local optionType = option.type or option.valueType -- color option have no type declared

    -- use checkbox type wherever possible
    if optionType == "select" and option.valueType == "bool" and option.values and option.values[1] == "Off" and option.values[2] == "On" then
        optionType = "selectBool"
    end

    local factory = factories[optionType]
    if not factory then
        Print("BetterNS2 option entry %s (%s) is not yet supported!", option.name, optionType)
        return
    end

    local result = factory(option)

    AddPostInits(result, function(self)
        local function ApplyOptions(this)
            local value = this:GetValue()
            local key = option.key
            BetterNS2SetOption(key, value)

            local immediateUpdate = option.immediateUpdate
            if immediateUpdate then
                immediateUpdate(this)
            end
        end
        self:HookEvent(self, "OnValueChanged", ApplyOptions)
    end)

    -- Add a "reset to default" button to the left of the option that will appear if the option is a
    -- non-default value.
    local parentOptionTbl
    if option.parent then
        parentOptionTbl = BetterNS2Options[option.parent]
        assert(parentOptionTbl) -- option.parent must be the name of an option.
    end
    local wrappedOption = AddResetButtonToOption(result, parentOptionTbl)

    return wrappedOption

end

local function CreateHeadingGroup(paramsTable)
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

local function CreateCheckboxOption(option)
    return {
        name = option.name,
        sort = option.sort or string.format("Z%s", option.name),
        class = OP_TT_Checkbox,
        params = {
            optionPath = option.name,
            optionType = "bool",
            default = option.default,

            tooltip = option.tooltip,
            tooltipIcon = option.tooltipIcon,

            immediateUpdate = option.immediateUpdate
        },
        properties = {
            { "Label", string.upper(option.label) }
        },
    }
end


function CreateBetterNS2OptionsMenu()
    local categories = {
    }

    local options = {
    }

    local menu = {}

    optionNames = {}

    for k, v in pairs(BetterNS2Options) do
        v.key = k
        table.insert(optionNames, v.name)

        local category = v.category
        local entry = CreateOptionMenuEntry(v)

        if entry then
            if not options[category] then
                table.insert(categories, category)
                options[category] = {}
            end

            table.insert(options[category], entry)
        end

    end

    for i = 1, #categories do
        local category = categories[i]
        local categoryOptions = options[category]

        if categoryOptions and #categoryOptions > 0 then
            table.sort(categoryOptions, sortOptionEntries)

            category = string.upper(category)
            local entry = CreateExpandableGroup {
                name = string.format("BetterNS2%sOptions", category),
                label = category,
                children = categoryOptions
            }

            table.insert(menu, entry)
        end
    end

    local resetButton = {
        name = "ResetAll",
        class = GUIMenuButton,
        properties = {
            {"Label", "RESET BETTERNS2 OPTIONS"}
        },
        postInit = {
            function(self)
                self:HookEvent(self, "OnPressed", ResetPopup)
            end
        }
    }

    table.insert(menu, resetButton)

    return menu
end

table.insert(gModsCategories, {
    categoryName = "BetterNS2",
    entryConfig = {
        name = "BetterNS2ModEntry",
        class = GUIMenuCategoryDisplayBoxEntry,
        params = {
            label = "Better NS2"
        }
    },
    contentsConfig = ModsMenuUtils.CreateBasicModsMenuContents
    {
        layoutName = "BetterNS2Options",
        contents = CreateBetterNS2OptionsMenu()
    }
})
