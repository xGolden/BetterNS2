ModLoader.SetupFileHook("lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua", "lua/BetterNS2/ModsMenuData.lua", "post")
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/BetterNS2/GUI/DisplayVersion.lua", "post")
ModLoader.SetupFileHook("lua/GUIAlienHUD.lua", "lua/BetterNS2/GUI/GUIAlienHUD.lua", "post")


ModLoader.SetupFileHook("lua/DamageMixin.lua", "lua/BetterNS2/Mixins/DamageMixin.lua", "post")
ModLoader.SetupFileHook("lua/BabblerClingMixin.lua", "lua/BetterNS2/Mixins/BabblerClingMixin.lua", "post")
ModLoader.SetupFileHook("lua/HitSounds.lua", "lua/BetterNS2/Sounds/HitSounds.lua", "post")


ModLoader.SetupFileHook("lua/NetworkMessages.lua", "lua/BetterNS2/Network/NetworkMessages.lua", "post")
ModLoader.SetupFileHook("lua/NetworkMessages_Client.lua", "lua/BetterNS2/Network/NetworkMessages_Client.lua", "post")

ModLoader.SetupFileHook("lua/PostLoadMod.lua", "lua/BetterNS2/PostLoad.lua", "pre")