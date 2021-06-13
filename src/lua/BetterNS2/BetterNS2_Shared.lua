kBetterNS2Version = 7

if not BNS2MainMenu then
    local kCHUDOptionMessage =
    {
        disabledOption = "string (32)"
    }

    Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
end