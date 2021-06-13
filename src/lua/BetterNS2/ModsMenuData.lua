BNS2MainMenu = decoda_name == "Main"

Script.Load("lua/BetterNS2/BetterNS2_Options.lua")

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
        contents = CreateBetterNS2Menu()
    }
})
