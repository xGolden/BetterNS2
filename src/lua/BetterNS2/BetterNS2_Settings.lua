-- TODO: Refactor, read from registry
local categoryOrder = {
    ui = 1,
    hud = 2,
    alienvision = 3,
    damage = 4,
    minimap = 5,
    sound = 6,
    graphics = 7,
    stats = 8,
    misc = 9
}

-- Wrap the text so it fits on screen
local kConsoleFont = PrecacheAsset("fonts/Hack_13.fnt")
local kConsoleTextItem
function BetterNS2PrintConsoleText(text)
    if not kConsoleTextItem then
        kConsoleTextItem = GetGUIManager():CreateTextItem()
        kConsoleTextItem:SetFontName(kConsoleFont)
    end

    Shared.Message(WordWrap(kConsoleTextItem, text, 0, Client.GetScreenWidth()-10))
end

local function isInteger(x)
    return math.floor(x) == x
end

--function BetterNS2GetOption(key)
--    if BetterNS2Options[key] ~= nil then
--        if BetterNS2Options[key].disabled then
--            local ret = ConditionalValue(BetterNS2Options[key].disabledValue == nil, BetterNS2Options[key].defaultValue, BetterNS2Options[key].disabledValue)
--            return ret
--        elseif BetterNS2Options["castermode"] and BetterNS2Options["castermode"].currentValue and not BetterNS2Options[key].ignoreCasterMode then
--            return BetterNS2Options[key].defaultValue
--        else
--            return BetterNS2Options[key].currentValue
--        end
--    end
--
--    return nil
--end

function BetterNS2GetOptionParam(key, param)
    if BetterNS2Options[key][param] ~= nil then
        return BetterNS2Options[key][param]
    end

    return nil
end

function BetterNS2GetOptionAssocVal(key)
    if BetterNS2Options[key] ~= nil and BetterNS2Options[key].type == "select" and BetterNS2Options[key].valueType == "int" then
        local value
        if BetterNS2Options["castermode"] and BetterNS2Options["castermode"].currentValue and not BetterNS2Options[key].ignoreCasterMode then
            value = BetterNS2Options[key].defaultValue
        else
            value = BetterNS2Options[key].currentValue
        end

        return BetterNS2Options[key].valueTable[value+1]
    end

    return nil
end

function BetterNS2GetOptionVals(key)
    if BetterNS2Options[key] ~= nil and BetterNS2Options[key].type == "select" and BetterNS2Options[key].valueType == "int" then
        return BetterNS2Options[key].valueTable
    end

    return nil
end

function BetterNS2SetOption(key, value, updateOptionsMenu)
    local setValue

    if BetterNS2Options[key] ~= nil then

        local option = BetterNS2Options[key]
        local oldValue = option.currentValue
        local defaultValue = option.defaultValue

        if option.valueType == "bool" then
            if value == "true" or value == "1" or value == true then
                Client.SetOptionBoolean(option.name, true)
                option.currentValue = true
                setValue = option.currentValue
            elseif value == "false" or value == "0" or value == false then
                Client.SetOptionBoolean(option.name, false)
                option.currentValue = false
                setValue = option.currentValue
            elseif value == "cycle" then
                Client.SetOptionBoolean(option.name, not oldValue)
                option.currentValue = not oldValue
                setValue = option.currentValue
            elseif value == "reset" or value == "default" then
                Client.SetOptionBoolean(option.name, defaultValue)
                option.currentValue = defaultValue
                setValue = option.currentValue
            end

        elseif option.valueType == "float" then
            local number = tonumber(value)
            local multiplier = 1 -- option.multiplier or 1
            if IsNumber(number) and number >= option.minValue * multiplier and number <= option.maxValue * multiplier then
                number = number / multiplier
                Client.SetOptionFloat(option.name, number)
                option.currentValue = number
                setValue = option.currentValue
            elseif value == "reset" or value == "default" then
                Client.SetOptionFloat(option.name, defaultValue)
                option.currentValue = defaultValue
                setValue = option.currentValue
            end

        elseif option.valueType == "int" then
            local number = tonumber(value)
            if IsNumber(number) and isInteger(number) and number >= 0 and number < #option.values then
                Client.SetOptionInteger(option.name, number)
                option.currentValue = number
                setValue = option.currentValue
            elseif value == "cycle" then
                if oldValue == #option.values-1 then
                    Client.SetOptionInteger(option.name, 0)
                    option.currentValue = 0
                    setValue = option.currentValue
                else
                    Client.SetOptionInteger(option.name, oldValue+1)
                    option.currentValue = oldValue+1
                    setValue = option.currentValue
                end
            elseif value == "reset" or value == "default" then
                Client.SetOptionInteger(option.name, defaultValue)
                option.currentValue = defaultValue
                setValue = option.currentValue
            end

        elseif option.valueType == "color" then
            local number
            if type(value) == "cdata" and value:isa("Color") then
                number = ColorToColorInt(value)
            else
                number = tonumber(value)
            end

            if IsNumber(number) then
                Client.SetOptionInteger(option.name, number)
                option.currentValue = number
                setValue = option.currentValue
            elseif value == "reset" or value == "default" then
                Client.SetOptionInteger(option.name, defaultValue)
                option.currentValue = defaultValue
                setValue = option.currentValue
            end
        end

        -- Don't waste time reapplying settings we already have active
        if oldValue ~= option.currentValue and option.applyFunction and option.disabled == nil and not BetterNS2MainMenu then
            option.applyFunction()
        end

        if updateOptionsMenu then
            local optionsMenu = GetOptionsMenu and GetOptionsMenu()
            local optionWidget = optionsMenu and optionsMenu:GetOptionWidget(option.name)
            if optionWidget then
                -- ColorPickerWidget requires color type value
                local optionValue = setValue
                if option.valueType == "color" then
                    optionValue = ColorIntToColor(optionValue)
                end

                optionWidget:SetValue(optionValue)
            end
        end

    end

    return setValue
end

function GetBetterNS2Settings()
    -- Set the default to something different than the current one
    local lastBetterNS2 = Client.GetOptionInteger("BetterNS2_LastBetterNS2Version", 0)

    if lastBetterNS2 < kBetterNS2Version then
        Client.SetOptionInteger("BetterNS2_LastBetterNS2Version", kBetterNS2Version)
    end

    for name, option in pairs(BetterNS2Options) do
        -- If setting is not what we expect we reset to default
        local value
        if option.valueType == "bool" then
            value = Client.GetOptionBoolean(option.name, option.defaultValue)
            if value == true or value == false then
                BetterNS2Options[name].currentValue = value
            else
                BetterNS2SetOption(name, option.defaultValue)
            end

        elseif option.valueType == "float" then
            value = Client.GetOptionFloat(option.name, option.defaultValue)
            local number = tonumber(value)
            if IsNumber(number) and number >= option.minValue and number <= option.maxValue then
                BetterNS2Options[name].currentValue = number
            else
                BetterNS2SetOption(name, option.defaultValue)
            end

        elseif option.valueType == "int" then
            value = Client.GetOptionInteger(option.name, option.defaultValue)
            local number = tonumber(value)
            if IsNumber(number) and isInteger(number) and number >= 0 and number < #option.values then
                BetterNS2Options[name].currentValue = number
            else
                BetterNS2SetOption(name, option.defaultValue)
            end

        elseif option.valueType == "color" then
            value = Client.GetOptionInteger(option.name, option.defaultValue)
            local number = tonumber(value)
            if IsNumber(number) and isInteger(number) then
                BetterNS2Options[name].currentValue = number
            else
                BetterNS2SetOption(name, option.defaultValue)
            end
        end

        if lastBetterNS2 < kBetterNS2Version and option.resetSettingInBuild and kBetterNS2Version >= option.resetSettingInBuild and lastBetterNS2 < option.resetSettingInBuild then
            BetterNS2PrintConsoleText(string.format("[BetterNS2] The default setting for \"%s\" was changed in BetterNS2 build %d, resetting to default.", option.label, option.resetSettingInBuild))
            if option.type == "slider" then
                local multiplier = option.multiplier or 1
                BetterNS2SetOption(name, option.defaultValue * multiplier )
            else
                BetterNS2SetOption(name, option.defaultValue )
            end
        end

        if option.applyOnLoadComplete and option.applyFunction and not BetterNS2MainMenu then
            option.applyFunction()
        end
    end
end

local SortedOptions = { }
local function BetterNS2PrintCommandsPage(page)

    -- Internally pages start at 0, but we display from 1 to n
    page = page - 1
    -- Sort the options if they aren't sorted yet
    if #SortedOptions == 0 then
        for idx, _ in pairs(BetterNS2Options) do
            table.insert(SortedOptions, idx)
        end
        table.sort(SortedOptions)
    end

    local linesPerPage = math.floor((Client.GetScreenHeight() / 18)/2) - 5
    local numPages = math.ceil(#SortedOptions/linesPerPage)
    local curPage = page >= 0 and page < numPages and page or 0

    BetterNS2PrintConsoleText("-------------------------------------")
    BetterNS2PrintConsoleText("BetterNS2 Commands")
    BetterNS2PrintConsoleText("-------------------------------------")
    for i = 1 + (linesPerPage * curPage), linesPerPage * curPage + linesPerPage do
        local option = BetterNS2Options[SortedOptions[i]]
        if option then
            local helpStr = "betterns2 " .. SortedOptions[i]
            if option.valueType == "float" then
                local multiplier = option.multiplier or 1
                helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier .. " or reset/default"
            elseif option.valueType == "int" then
                helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle or reset/default"
            elseif option.valueType == "bool" then
                helpStr = helpStr .. " <true/false> or <0/1> or cycle or reset/default"
            elseif option.valueType == "color" then
                helpStr = helpStr .. " <Red (0-255)> <Green (0-255)> <Blue (0-255> or reset/default"
            end
            helpStr = helpStr .. " - " .. option.tooltip
            BetterNS2PrintConsoleText(helpStr)
        end
    end
    BetterNS2PrintConsoleText("-------------------------------------")
    BetterNS2PrintConsoleText(string.format("Page %d of %d. Type \"betterns2 page <number>\" to see other pages.", curPage+1, numPages))
    BetterNS2PrintConsoleText("-------------------------------------")
end

local function BetterNS2Help(optionName)

    if BetterNS2Options[optionName] ~= nil then
        local option = BetterNS2Options[optionName]
        local multiplier = option.multiplier or 1
        BetterNS2PrintConsoleText("-------------------------------------")
        BetterNS2PrintConsoleText(option.label)
        BetterNS2PrintConsoleText("-------------------------------------")
        BetterNS2PrintConsoleText(option.tooltip)
        local default = option.defaultValue
        local helpStr = "Usage: betterns2 " .. optionName
        if option.valueType == "float" then
            helpStr = helpStr .. " <float> - Values: " .. option.minValue * multiplier .. " to " .. option.maxValue * multiplier .. " or reset/default"
            default = default * multiplier
        elseif option.valueType == "int" then
            helpStr = helpStr .. " <integer> - Values: 0 to " .. #option.values-1 .. " or cycle or reset/default"
        elseif option.valueType == "bool" then
            helpStr = helpStr .. " <true/false> or <0/1> or cycle or reset/default"
        elseif option.valueType == "color" then
            helpStr = helpStr .. " <Red (0-255)> <Green (0-255)> <Blue (0-255> or reset/default"
            local tmpColor = ColorIntToColor(default)
            default = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
        end
        BetterNS2PrintConsoleText(helpStr .. " - Example (default value): betterns2 " .. optionName .. " " .. tostring(default))
        if option.type == "select" then
            if option.valueType == "int" then
                for index, value in pairs(option.values) do
                    BetterNS2PrintConsoleText("betterns2 " .. optionName .. " " .. index-1 .. " - " .. value)
                end
                BetterNS2PrintConsoleText("-------------------------------------")
                helpStr = option.values[option.currentValue+1]
            elseif option.valueType == "bool" then
                if option.currentValue then
                    helpStr = option.values[2]
                else
                    helpStr = option.values[1]
                end
                helpStr = helpStr .. " (" .. tostring(option.currentValue) .. ")"
            end
        elseif option.valueType == "color" then
            local tmpColor = ColorIntToColor(option.currentValue)
            helpStr = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
        else
            helpStr = tostring(Round(option.currentValue * multiplier), 4)
        end
        BetterNS2PrintConsoleText("Current value: " .. helpStr)
        BetterNS2PrintConsoleText("-------------------------------------")

    else
        BetterNS2PrintConsoleText(kBetterNS2UnrecognizedOptionMsg)
    end
end

local function OnCommandBetterNS2(...)
    local args = {...}

    for idx, arg in ipairs(args) do
        args[idx] = string.lower(arg)
    end

    if #args == 0 then
        BetterNS2PrintCommandsPage(1)

    elseif #args == 1 then
        BetterNS2Help(args[1])

    elseif #args > 1 and args[1] ~= "page" then
        if BetterNS2Options[args[1]] ~= nil then
            local option = BetterNS2Options[args[1]]
            local multiplier = option.multiplier or 1

            if option.valueType == "color" and args[2] ~= "reset" and args[2] ~= "default" then
                local r = tonumber(args[2])
                local g = tonumber(args[3]) or 0
                local b = tonumber(args[4]) or 0
                if IsNumber(r) and IsNumber(g) and IsNumber(b) then
                    r = math.max(0, math.min(r, 255))
                    g = math.max(0, math.min(g, 255))
                    b = math.max(0, math.min(b, 255))
                    args[2] = bit.lshift(r, 16) + bit.lshift(g, 8) + b
                else
                    args[2] = nil
                end
            end

            local setValue = BetterNS2SetOption(args[1], args[2], true)
            local helpStr = ""

            if option.type == "select" then
                if option.valueType == "bool" then
                    if option.currentValue then
                        helpStr = option.values[2]
                    else
                        helpStr = option.values[1]
                    end
                    helpStr = helpStr .. " (" .. tostring(option.currentValue) .. ")"
                else
                    helpStr = option.values[option.currentValue+1]
                end
            elseif option.valueType == "color" then
                local tmpColor = ColorIntToColor(option.currentValue)
                helpStr = tostring(math.floor(tmpColor.r * 255)) .. " " .. tostring(math.floor(tmpColor.g * 255)) .. " " .. tostring(math.floor(tmpColor.b*255))
            else
                helpStr = tostring(option.currentValue * multiplier)
            end

            if setValue ~= nil then
                BetterNS2PrintConsoleText(option.label .. " set to: " .. helpStr)
                if option.disabled then
                    BetterNS2PrintConsoleText("The server admin has disabled this option (" .. option.label .. "). The option will get saved, but the blocked value will be used." )
                end
            else
                BetterNS2Help(args[1])
            end
        else
            BetterNS2PrintConsoleText(kBetterNS2UnrecognizedOptionMsg)
        end
    elseif #args == 2 and args[1] == "page" and IsNumber(tonumber(args[2])) then
        BetterNS2PrintCommandsPage(args[2])
    else
        BetterNS2PrintConsoleText(kBetterNS2UnrecognizedOptionMsg)
    end
end

local function OnBetterNS2Option(msg)
    local key = msg.disabledOption

    if BetterNS2Options[key] ~= nil then
        BetterNS2Options[key].disabled = true
        if BetterNS2Options[key].applyFunction then
            BetterNS2Options[key].applyFunction()
        end
    end
end

local function OnCommandBetterNS2Export()
    local settingsFileName = "config://BetterNS2/ExportedSettings.txt"
    local settingsFile = io.open(settingsFileName, "w+")
    if settingsFile then
        local skipOptions = { }
        local OptionsMenuTable = {}

        -- If an option has hidden children, add them (and their children...) to the skip table
        local function SkipChildren(option)
            if option.children then
                local show = true
                for _, value in pairs(option.hideValues) do
                    if option.currentValue == value then
                        show = false
                    end
                end

                -- Skip children if we skipped the parent
                if skipOptions[option.name] then
                    show = false
                end

                for _, optionIndex in pairs(option.children) do
                    local optionName = BetterNS2GetOptionParam(optionIndex, "name")
                    if optionName and not show then
                        skipOptions[optionName] = true

                        SkipChildren(BetterNS2Options[optionIndex])
                    end
                end
            end
        end

        for idx, option in pairs(BetterNS2Options) do
            if not OptionsMenuTable[option.category] then
                OptionsMenuTable[option.category] = {}
            end
            table.insert(OptionsMenuTable[option.category], BetterNS2Options[idx])

            -- Add the options that are hidden in the options menu here so we don't print them later
            SkipChildren(option)
        end

        local function BetterNS2OptionsSort(a, b)
            if a.sort == nil then
                a.sort = "Z" .. a.name
            end
            if b.sort == nil then
                b.sort = "Z" .. b.name
            end

            return a.sort < b.sort
        end

        local BetterNS2OptionsMenu = {}
        for name, category in pairs(OptionsMenuTable) do
            table.sort(category, BetterNS2OptionsSort)
            table.insert(BetterNS2OptionsMenu, {
                name = string.upper(name) .. " TAB",
                options = OptionsMenuTable[name],
                sort = categoryOrder[name],
            })
        end

        table.sort(BetterNS2OptionsMenu, BetterNS2OptionsSort)

        local function PrintSetting(optionIdx)
            if not skipOptions[optionIdx.name] then
                local currentValue = optionIdx.currentValue
                if optionIdx.valueType == "float" then
                    currentValue = tostring(Round(currentValue * (optionIdx.multiplier or 1), 4))
                elseif optionIdx.valueType == "bool" then
                    if optionIdx.currentValue == true then
                        currentValue = optionIdx.values[2]
                    else
                        currentValue = optionIdx.values[1]
                    end
                elseif optionIdx.valueType == "int" then
                    currentValue = optionIdx.values[currentValue+1]
                elseif optionIdx.valueType == "color" then
                    if currentValue == optionIdx.defaultValue then
                        currentValue = "Default"
                    else
                        local tmpColor = ColorIntToColor(currentValue)
                        currentValue = tostring(math.floor(tmpColor.r*255)) .. " " .. tostring(math.floor(tmpColor.g*255)) .. " " .. tostring(math.floor(tmpColor.b*255))
                    end
                end
                local optionString = optionIdx.label .. ": " .. currentValue .. "\r\n"
                settingsFile:write(optionString)
            end
        end

        for _, category in pairs(BetterNS2OptionsMenu) do
            settingsFile:write(category.name .. "\r\n-----------\r\n")
            for _, option in ipairs(category.options) do
                PrintSetting(option)
            end
            settingsFile:write("\r\n")
        end

        settingsFile:write("\r\nDate exported: " .. BetterNS2FormatDateTimeString(Shared.GetSystemTime()))

        BetterNS2PrintConsoleText("Exported BetterNS2 config. You can find it in \"%APPDATA%\\Natural Selection 2\\BetterNS2\\ExportedSettings.txt\"")
        io.close(settingsFile)
    end
end

Event.Hook("Console_betterns2_export", OnCommandBetterNS2Export)

local function OnCommandBetterNS2ExportOptionTable()
    local settingsFileName = "config://BetterNS2/ExportedOptions.csv"
    local settingsFile = io.open(settingsFileName, "w+")
    if settingsFile then
        local OptionsMenuTable = {}

        local function AddParent(option)
            if option.children then
                for i = 1, #option.children do
                    local child = option.children[i]
                    BetterNS2Options[child].parent = option.label
                end
            end
        end

        for idx, option in pairs(BetterNS2Options) do
            if not OptionsMenuTable[option.category] then
                OptionsMenuTable[option.category] = {}
            end
            AddParent(option)
            table.insert(OptionsMenuTable[option.category], BetterNS2Options[idx])
        end

        local function BetterNS2OptionsSort(a, b)
            if a.sort == nil then
                a.sort = "Z" .. a.name
            end
            if b.sort == nil then
                b.sort = "Z" .. b.name
            end

            return a.sort < b.sort
        end

        local BetterNS2OptionsMenu = {}
        for name, category in pairs(OptionsMenuTable) do
            table.sort(category, BetterNS2OptionsSort)
            table.insert(BetterNS2OptionsMenu, {
                name = string.upper(name) .. " TAB",
                options = OptionsMenuTable[name],
                sort = categoryOrder[name],
            })
        end

        table.sort(BetterNS2OptionsMenu, BetterNS2OptionsSort)

        local function PrintSetting(optionIdx)
            local parent = optionIdx.parent or ""

            local values = ""
            local default = ""
            local valueType = optionIdx.valueType

            if valueType == "float" then
                local multi = optionIdx.multiplier or 1
                default = tostring(optionIdx.defaultValue * multi)
                values = string.format("%s - %s", optionIdx.minValue * multi, optionIdx.maxValue * multi)
            elseif valueType == "bool" then
                default = optionIdx.defaultValue and optionIdx.values[2] or optionIdx.values[1]
                values = table.concat(optionIdx.values, ";")
            elseif valueType == "int" then
                default = optionIdx.values[optionIdx.defaultValue + 1]
                values = table.concat(optionIdx.values, ";")
            elseif valueType == "color" then
                local tmpColor = ColorIntToColor(optionIdx.defaultValue)
                default = string.format("(%s;%s;%s)", math.floor(tmpColor.r*255), math.floor(tmpColor.g*255), math.floor(tmpColor.b*255))
                values = "(0;0;0) to (255;255;255)"
            end
            local optionString = optionIdx.label .. "," .. optionIdx.tooltip:gsub(",", ";"):gsub("\n", " ") .. "," .. optionIdx.category .. "," ..
                    parent .. "," .. valueType .. "," .. values .. "," .. default .. ",".. "\r\n"

            settingsFile:write(optionString)
        end

        settingsFile:write("Name,Description,Category,Parent,Typ,Values,Default\r\n")
        for _, category in pairs(BetterNS2OptionsMenu) do
            for _, option in ipairs(category.options) do
                PrintSetting(option)
            end
        end

        io.close(settingsFile)
    end
end
Event.Hook("Console_betterns2_export_option_table", OnCommandBetterNS2ExportOptionTable)

Event.Hook("Console_betterns2", OnCommandBetterNS2)
Client.HookNetworkMessage("BetterNS2Option", OnBetterNS2Option)

local function OnCommandSetBetterNS2Version(version)
    if Shared.GetCheatsEnabled() then
        Client.SetOptionInteger("BetterNS2_LastBetterNS2Version", tonumber(version))
        Print("Version set to: " .. version)
    end
end

Event.Hook("Console_setbetterns2version", OnCommandSetBetterNS2Version)
