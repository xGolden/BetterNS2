-- GUI
ModLoader.SetupFileHook("lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua", "lua/BetterNS2/ModsMenuData.lua", "post")
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/BetterNS2/GUI/DisplayVersion.lua", "post")
ModLoader.SetupFileHook("lua/GUIAlienHUD.lua", "lua/BetterNS2/GUI/GUIAlienHUD.lua", "post")
ModLoader.SetupFileHook("lua/GUIWorldText.lua", "lua/BetterNS2/GUI/GUIWorldText.lua", "post")
ModLoader.SetupFileHook("lua/GUIDeathStats.lua", "lua/BetterNS2/GUI/GUIDeathStats.lua", "post")

-- Damage
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/BetterNS2/Damage/DamageTypes.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/LiveMixin.lua", "lua/BetterNS2/Mixins/LiveMixin.lua", "post")
ModLoader.SetupFileHook("lua/DamageMixin.lua", "lua/BetterNS2/Mixins/DamageMixin.lua", "post")
ModLoader.SetupFileHook("lua/BabblerClingMixin.lua", "lua/BetterNS2/Mixins/BabblerClingMixin.lua", "post")
ModLoader.SetupFileHook("lua/HitSounds.lua", "lua/BetterNS2/Sounds/HitSounds.lua", "post")

-- Network
ModLoader.SetupFileHook("lua/NetworkMessages.lua", "lua/BetterNS2/Network/NetworkMessages.lua", "post")
ModLoader.SetupFileHook("lua/NetworkMessages_Client.lua", "lua/BetterNS2/Network/NetworkMessages_Client.lua", "post")

-- Stats
ModLoader.SetupFileHook("lua/ServerStats.lua", "lua/BetterNS2/Stats/ServerStats.lua", "replace")

ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/BetterNS2/Base/Player_Client.lua", "post")
ModLoader.SetupFileHook("lua/PostLoadMod.lua", "lua/BetterNS2/PostLoad.lua", "pre")