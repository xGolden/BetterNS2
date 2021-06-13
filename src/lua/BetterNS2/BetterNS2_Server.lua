Script.Load("lua/BetterNS2/Server/BetterNS2_ServerSettings.lua")
Script.Load("lua/BetterNS2/Server/BetterNS2_ModUpdater.lua")

Shared.Message("------[BNS2 Server Settings]------")

if #BNS2ClientOptions > 0 then
    local blockedString = ""
    for _, option in ipairs(BNS2ClientOptions) do
        if blockedString ~= "" then
            blockedString = blockedString .. ", " .. option
        else
            blockedString = option
        end
    end

    Shared.Message("Blocked client options: " .. blockedString)
end

-- Mod updater setting also depends on shine
if BNS2ServerOptions["modupdater"].shine then
    Shared.Message("Shine workshop updater is enabled. Disabling BNS2 mod updater.")
else
    local modUpdStr = ConditionalValue(BNS2ServerOptions["modupdater"].currentValue == false, "Disabled", "Enabled")
    Shared.Message("Mod updater: " .. modUpdStr)
    if BNS2ServerOptions["modupdater"].currentValue == true then
        Shared.Message("\t- Check every: " .. BNS2ServerOptions["modupdatercheckinterval"].currentValue .. " min.")
        Shared.Message("\t- Reminder interval: " .. BNS2ServerOptions["modupdaterreminderinterval"].currentValue .. " min.")
    end
end

Shared.Message("----------------------------------")