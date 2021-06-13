-- Thanks Mendasp
local updateCheckInterval = BNS2ServerOptions["modupdatercheckinterval"].currentValue*60
local lastTimeChecked = Shared.GetTime(true) - updateCheckInterval
local mapChangeNeeded = false
local modsTable = {}
local updatedMods = {}
local DisableUpdater = false
local hasModBackup = #Server.GetConfigSetting("mod_backup_servers") > 0

local function BNS2DisplayModUpdateMessage()
    if not hasModBackup then
        SendBNS2Message("Detected mod update. New players won't be able to join until map change.")
    end
    local modsStringList = "Mods updated:"
    for _, value in pairs(updatedMods) do
        modsStringList = modsStringList .. " " .. value .. "."
    end
    SendBNS2Message(modsStringList)
end

-- Don't use this updater if the server is already using the Shine one
if isShineLoaded and Shine:IsExtensionEnabled( "workshopupdater" ) then
    DisableUpdater = true
    BNS2ServerOptions["modupdater"].shine = true
else
    DisableUpdater = BNS2ServerOptions["modupdater"].currentValue == false
end

function BNS2ParseModInfo(modInfo)
    if modInfo then
        local response = modInfo["response"]
        if response and response["result"] == 1 then
            for _, res in pairs(response["publishedfiledetails"]) do
                if res["result"] == 1 then
                    if modsTable[res["publishedfileid"]] and modsTable[res["publishedfileid"]] ~= res["time_updated"] then
                        mapChangeNeeded = true
                        -- Repeat the mod update message
                        updateCheckInterval = BNS2ServerOptions["modupdaterreminderinterval"].currentValue*60
                        updatedMods[res["publishedfileid"]] = res["title"]
                    end
                    modsTable[res["publishedfileid"]] = res["time_updated"]
                end
            end
            if not DisableUpdater and mapChangeNeeded then
                BNS2DisplayModUpdateMessage()
            end
        end
    end
end

function BNS2ModUpdater()
    -- Update values as soon as they are changed by console commands
    DisableUpdater = BNS2ServerOptions["modupdater"].currentValue == false

    -- Change the check interval and reset the last time checked
    if not mapChangeNeeded and updateCheckInterval ~= BNS2ServerOptions["modupdatercheckinterval"].currentValue*60 then
        updateCheckInterval = BNS2ServerOptions["modupdatercheckinterval"].currentValue*60
        lastTimeChecked = Shared.GetTime(true)
    end

    -- Change the reminder interval (only needed if it's already reminding)
    if mapChangeNeeded and updateCheckInterval ~= BNS2ServerOptions["modupdaterreminderinterval"].currentValue*60 then
        updateCheckInterval = BNS2ServerOptions["modupdaterreminderinterval"].currentValue*60
        lastTimeChecked = Shared.GetTime(true)
    end

    if mapChangeNeeded and Server.GetNumPlayers() == 0 and not DisableUpdater then
        SendBNS2Message("The server is empty. Changing map.")
        MapCycle_ChangeMap( Shared.GetMapName() )
    end

    -- Even if the updater is disabled, keep running so it can notify players of outdated mods in the server browser
    if lastTimeChecked < Shared.GetTime(true) - updateCheckInterval then
        lastTimeChecked = Shared.GetTime(true)

        if mapChangeNeeded then
            -- If we set the reminder to 0, don't show this message anymore.
            if updateCheckInterval > 0 and not DisableUpdater and not hasModBackup then
                BNS2DisplayModUpdateMessage()
            end
        else
            local params = {}
            params["itemcount"] = Server.GetNumActiveMods()
            for modNum = 1, Server.GetNumActiveMods() do
                params["publishedfileids[" .. modNum-1 .. "]"] = tonumber("0x" .. Server.GetActiveModId(modNum))
            end

            if params["itemcount"] > 0 then
                Shared.SendHTTPRequest("http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", "POST", params, function(result) BNS2ParseModInfo(json.decode(result)) end)
            end
        end
    end
end

Event.Hook("UpdateServer", BNS2ModUpdater)