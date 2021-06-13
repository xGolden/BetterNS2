BNS2ClientOptions = {}

BNS2ServerOptions = {
    modupdater = {
        label   = "Mod updater",
        tooltip = "Enables or disables the mod update checker.",
        valueType = "bool",
        defaultValue = true,
    },
    modupdatercheckinterval = {
        label   = "Mod updater check interval",
        tooltip = "Sets the update check interval for the mod updater (in minutes).",
        valueType = "float",
        defaultValue = 10,
        minValue = 1,
        maxValue = 999,
    },
    modupdaterreminderinterval = {
        label   = "Mod updater reminder interval",
        tooltip = "Sets the time between reminders when an update has been found. Set to 0 to disable (only shows once).",
        valueType = "float",
        defaultValue = 5,
        minValue = 0,
        maxValue = 999,
    }
}

local configFileName = "BNS2ServerConfig.json"

local function BNS2SaveServerConfig()
    local saveConfig = {}

    for i, option in pairs(BNS2ServerOptions) do
        saveConfig[i] = option.currentValue
    end

    SaveConfigFile(configFileName, saveConfig)
end

function BetterNS2SetServerOption(key, value)
    local setValue

    if BNS2ServerOptions[key] ~= nil then
        option = BNS2ServerOptions[key]
        oldValue = option.currentValue

        if option.valueType == "bool" then
            if value == "true" or value == "1" or value == true then
                option.currentValue = true
                setValue = option.currentValue
            elseif value == "false" or value == "0" or value == false then
                option.currentValue = false
                setValue = option.currentValue
            end

        elseif option.valueType == "float" then
            local number = tonumber(value)
            if IsNumber(number) and number >= option.minValue and number <= option.maxValue then
                option.currentValue = number
                setValue = option.currentValue
            end
        end

        if option.applyFunction then
            option.applyFunction()
        end

        if oldValue ~= option.currentValue then
            BNS2SaveServerConfig()
        end
    end

    return setValue
end

local function BNS2ServerHelp(...)
    local args = {...}
    local client = args[1]

    if #args == 1 then
        local SortedOptions = {}

        for i, _ in pairs(BNS2ServerOptions) do
            table.insert(SortedOptions, i)
            table.sort(SortedOptions)
        end

        BNS2ServerAdminPrint(client, "-------------------------------------")
        BNS2ServerAdminPrint(client, "NS2+ Server Settings")
        BNS2ServerAdminPrint(client, "-------------------------------------")

        for _, origOption in pairs(SortedOptions) do
            local option = BNS2ServerOptions[origOption]
            local helpStr = "sv_bns2 " .. origOption
            if option.valueType == "float" then
                helpStr = helpStr .. " <float> - Values: " .. option.minValue .. " to " .. option.maxValue
            elseif option.valueType == "bool" then
                helpStr = helpStr .. " <true/false> or <0/1>"
            end
            helpStr = helpStr .. " - " .. option.tooltip
            BNS2ServerAdminPrint(client, helpStr)
        end
    elseif #args == 2 then
        if BNS2ServerOptions[string.lower(args[2])] ~= nil then
            option = BNS2ServerOptions[string.lower(args[2])]
            BNS2ServerAdminPrint(client, "-------------------------------------")
            BNS2ServerAdminPrint(client, option.label)
            BNS2ServerAdminPrint(client, "-------------------------------------")
            BNS2ServerAdminPrint(client, option.tooltip)
            local helpStr = "Usage: sv_plus " .. args[2]
            if option.valueType == "float" then
                helpStr = helpStr .. " <float> - Values: " .. option.minValue .. " to " .. option.maxValue
            elseif option.valueType == "bool" then
                helpStr = helpStr .. " <true/false> or <0/1>"
            end
            BNS2ServerAdminPrint(client, helpStr)
            BNS2ServerAdminPrint(client, "Example (default value): sv_plus " .. args[2] .. " " .. tostring(option.defaultValue))
            BNS2ServerAdminPrint(client, "Current value: " .. tostring(option.currentValue))
            BNS2ServerAdminPrint(client, "-------------------------------------")

        else
            BNS2ServerHelp(client)
        end
    end
end

local function BNS2ServerSetting(...)
    local args = {...}
    local client = args[1]

    for idx, arg in pairs(args) do
        -- First parameter is the client that ran the cmd
        if idx > 1 then
            args[idx] = string.lower(arg)
        end
    end

    if #args == 1 then
        BNS2ServerHelp(client)
    elseif #args == 2 then
        BNS2ServerHelp(client, args[2])
    elseif #args == 3 then
        if BNS2ServerOptions[args[2]] ~= nil then
            option = BNS2ServerOptions[args[2]]
        end

        if setValue ~= nil then
            BNS2ServerAdminPrint(client, option.label .. " set to: " .. tostring(setValue))
        else
            BNS2ServerHelp(client, args[2])
        end
    else
        BNS2ServerHelp(client)
    end
end

local defaultBNS2Config = {}
for i, option in pairs(BNS2ServerOptions) do
    defaultBNS2Config[i] = option.defaultValue
end

WriteDefaultConfigFile(configFileName, defaultBNS2Config)

local config = LoadConfigFile(configFileName) or defaultBNS2Config

for option, value in pairs(config) do
    if BNS2ServerOptions[option] then
        BNS2ServerOptions[option].currentValue = value
        local setValue = BetterNS2SetServerOption(option, value)
        if setValue == nil and BNS2ServerOptions[option] then
            BetterNS2SetServerOption(option, BNS2ServerOptions[option].defaultValue)
        end
    end
end

for i, option in pairs(BNS2ServerOptions) do
    if option.currentValue == nil then
        BetterNS2SetServerOption(index, BNS2ServerOptions[i].defaultValue)
    end

    local _, pos = string.find(i, "allow_")
    if pos and BNS2ServerOptions[i].currentValue == false then
        local optionName = string.sub(i, pos + 1)
        table.insert(BNS2ClientOptions, optionName)
    end
end

CreateServerAdminCommand("Console_sv_bns2", BNS2ServerSetting, "Sets BNS2 server settings", false)