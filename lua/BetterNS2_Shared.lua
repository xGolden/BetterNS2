kBetterNS2Version = 1

Script.Load("lua/Shared/BetterNS2_Utility.lua")

if not BetterNS2MainMenu then
    local kBetterNS2OptionMessage =
    {
        disabledOption = "string (32)"
    }

    Shared.RegisterNetworkMessage("BetterNS2Option", kBetterNS2OptionMessage)
end
