local function BetterNS2RestartScripts(scripts)
    for _, currentScript in ipairs(scripts) do
        local script = ClientUI.GetScript(currentScript)
        if script then
            script:Uninitialize()
            script:Initialize()
        end
    end
end

local uiScaleTime = 0
local function BetterNS2ApplyNewUIScale()
    uiScaleTime = Shared.GetTime()
end

local function CheckUIScaleTime()
    if uiScaleTime ~= 0 and uiScaleTime + 1 < Shared.GetTime() then
        local xRes = Client.GetScreenWidth()
        local yRes = Client.GetScreenHeight()
        GetGUIManager():OnResolutionChanged(xRes, yRes, xRes, yRes)
        uiScaleTime = 0
    end
end

Event.Hook("UpdateRender", CheckUIScaleTime)

-- Register options categories here
BetterNS2OptionsCategories = {
    "alienvision"
}

--[[ Register Options here
optionname = {
    name = "",
    label = "",
    tooltip = "",
    type = "",
    values = {},
    defaultValue = x,
    category = "",
    valueType = "",
    sort = "",

    -- optional parameters
    applyFunction = function()
        FunctionName()
    end,
    parent = ""
    minValue = x,
    maxValue = y,
    decimalPlaces = z,
    applyOnLoadComplete = bool,
    resetSettingInBuild = t
}
]]
BetterNS2Options = {
    avstate = {
        name = "BETTERNS2_AVState",
        label = "Default AV state",
        tooltip = "Sets the state the alien vision will be in when you respawn.",
        type = "select",
        values  = { "Off", "On" },
        defaultValue = true,
        category = "alienvision",
        valueType = "bool",
        sort = "C01",
        resetSettingInBuild = 359
    },
    av = {
        name = "BETTERNS2_AV",
        label = "Alien vision",
        tooltip = "Lets you choose between different Alien Vision types. Please note that Cr4zyAV may negatively impact the game's performance!",
        type = "select",
        values  = { "Default", "Huze's Old AV", "Huze's Minimal AV", "Uke's AV", "Old AV (Fanta)", "Cr4zyAV Configurable" },
        valueTable = {
            "shaders/DarkVision.screenfx",
            "shaders/HuzeOldAV.screenfx",
            "shaders/HuzeMinAV.screenfx",
            "shaders/UkeAV.screenfx",
            "shaders/FantaVision.screenfx",
            "shaders/Cr4zyAV.screenfx",
        },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() BetterNS2RestartScripts({ "GUIAlienHUD" }) end,
        children = { "av_colormarine", "av_marineintensity", "av_coloralien", "av_alienintensity", "av_style", "av_offstyle", "av_closecolor", "av_closeintensity", "av_distantcolor", "av_distantintensity", "av_playercolor", "av_gorgeunique", "av_structurecolor", "av_blenddistance", "av_worldintensity", "av_edges", "av_edgesize", "av_desaturation", "av_viewmodelstyle", "av_activationeffect", "av_skybox", "av_colormarinestruct", "av_mstructintensity", "av_coloralienstruct", "av_astructintensity" },
        hideValues = { 0, 1, 2, 3, 4 },
        sort = "C02",
        resetSettingInBuild = 237,
    },
    av_style = {
        name = "BETTERNS2_AVStyle",
        label = "Alien Vision Style",
        tooltip = "Switches between different configurable styles of Alien Vision.",
        type = "select",
        values  = { "Minimal", "Original", "Depth Fog", "Edge and World" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        helpImage = "ui/helpImages/av_style.dds",
        helpImageSize = Vector(512, 256, 0),
        children = { "av_closecolor", "av_closeintensity", "av_distantcolor", "av_distantintensity" },
        hideValues = { 0 },
        sort = "C03",
        parent = "av"
    },
    av_offstyle = {
        name = "BETTERNS2_AVOffStyle",
        label = "Disabled Alien Vision Style",
        tooltip = "Switches between different options for when Alien Vision is disabled.",
        type = "select",
        values  = { "Nothing", "Minimal world edges", "Coloured edges", "Marine only edges" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        helpImage = "ui/helpImages/av_offstyle.dds",
        helpImageSize = Vector(512, 256, 0),
        sort = "C04",
        parent = "av"
    },
    av_closecolor = {
        name = "BETTERNS2_AVCloseColor",
        label = "Close Colour",
        tooltip = "Sets the close world colour.",
        defaultValue = 0x0030FE,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C05",
        resetSettingInBuild = 237,
        parent = "av_style"
    },
    av_closeintensity = {
        name = "BETTERNS2_AVCloseIntensity",
        label = "Close Intensity",
        tooltip = "Sets the 'brightness' value of the closer colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C068",
        parent = "av_style"
    },
    av_distantcolor = {
        name = "BETTERNS2_AVDistantColor",
        label = "Distant Colour",
        tooltip = "Sets the distant world colour.",
        defaultValue = 0x49006E,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C07",
        parent = "av_style"
    },
    av_distantintensity = {
        name = "BETTERNS2_AVDistantIntensity",
        label = "Distant Intensity",
        tooltip = "Sets the 'brightness' value of the distant colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C08",
        parent = "av_style"
    },
    av_playercolor = {
        name = "BETTERNS2_AVPlayerColor",
        label = "Players to Colour",
        tooltip = "Allows Players to be coloured separately.",
        type = "select",
        values  = { "All Players", "Marines Only", "Alien Only", "No Players" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        sort = "C09",
        parent = "av"
    },
    av_colormarine = {
        name = "BETTERNS2_AVColorMarine",
        label = "Marine Player Colour",
        tooltip = "Selects the colour for Marine players.",
        defaultValue = 0xFF8900,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C10",
        parent = "av"
    },
    av_marineintensity = {
        name = "BETTERNS2_AVMarineIntensity",
        label = "Marine Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Marine colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C11",
        parent = "av"
    },
    av_coloralien = {
        name = "BETTERNS2_AVColorAlien",
        label = "Alien Player Colour",
        tooltip = "Selects the colour for Alien players.",
        defaultValue = 0x008CFE,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C12",
        parent = "av"
    },
    av_alienintensity = {
        name = "BETTERNS2_AVAlienIntensity",
        label = "Alien Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Alien colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C13",
        parent = "av"
    },
    av_gorgeunique = {
        name = "BETTERNS2_AVGorgeUnique",
        label = "Colour Gorges Seperately",
        tooltip = "Allows you to seperately colour Gorges.\n Applies to babblers too.",
        type = "select",
        values  = { "Off", "On" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        hideValues = { 0 },
        children = { "av_colorgorge", "av_gorgeintensity" },
        applyFunction = function() updateAlienVision() end,
        sort = "C14",
        parent = "av",
    },
    av_colorgorge = {
        name = "BETTERNS2_AVGorgeColor",
        label = "Gorge Colour",
        tooltip = "Selects the colour for Gorge and Babblers.",
        defaultValue = 0x00FF00,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C15",
        parent = "av_gorgeunique"
    },
    av_gorgeintensity = {
        name = "BETTERNS2_AVGorgeIntensity",
        label = "Gorge Colour Intensity",
        tooltip = "Sets the 'brightness' value of the Gorge colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C16",
        parent = "av_gorgeunique"
    },
    av_structurecolor = {
        name = "BETTERNS2_AVStructureColor",
        label = "Structures to Colour",
        tooltip = "Allows Structures to be coloured separately.",
        type = "select",
        values  = { "All Structures", "Marines Structures Only", "Alien Structures Only", "No Structures" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        sort = "C17",
        parent = "av"
    },
    av_colormarinestruct = {
        name = "BETTERNS2_AVMstructColor",
        label = "Marine Structure Colour",
        tooltip = "Selects the colour for Marine structures.",
        defaultValue = 0xFF0700,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C18",
        parent = "av"
    },
    av_mstructintensity = {
        name = "BETTERNS2_AVMStructIntensity",
        label = "Marine Structure Intensity",
        tooltip = "Sets the 'brightness' value of the Marine structure colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C19",
        parent = "av"
    },
    av_coloralienstruct = {
        name = "BETTERNS2_AVAstructColor",
        label = "Alien Structure Colour",
        tooltip = "Selects the colour for Alien structures.",
        defaultValue = 0x00FE80,
        category = "alienvision",
        valueType = "color",
        applyFunction = function() updateAlienVision() end,
        sort = "C20",
        parent = "av"
    },
    av_astructintensity = {
        name = "BETTERNS2_AVAStructIntensity",
        label = "Alien Structure Intensity",
        tooltip = "Sets the 'brightness' value of the Alien structure colour.",
        type = "slider",
        defaultValue = 1.0,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C21",
        parent = "av"
    },
    av_blenddistance = {
        name = "BETTERNS2_AVBlendDistance",
        label = "Blend Distance",
        tooltip = "Allows you to modify the distance at which blending occurs for close and distant colors.",
        type = "slider",
        defaultValue = 1.5,
        minValue = 0.0,
        maxValue = 10.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C22",
        parent = "av"
    },
    av_edges = {
        name = "BETTERNS2_AVEdges",
        label = "Edge Style",
        tooltip = "Switches between edge outlines that are uniform in size or ones that thicken in peripheral vision. Also reduce the fill colour if desired.",
        type = "select",
        values  = { "Normal", "Thicker Peripheral Edges", "Normal, No Fill", "Thicker Peripheral, No Fill" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        sort = "C23",
        helpImage = "ui/helpImages/av_nofill.dds",
        helpImageSize = Vector(512, 256, 0),
        resetSettingInBuild = 237,
        parent = "av"
    },
    av_edgesize = {
        name = "BETTERNS2_AVEdgeSize",
        label = "Edge Thickness",
        tooltip = "Sets the thickness of edges in alien vision.",
        type = "slider",
        defaultValue = 0.4,
        minValue = 0.0,
        maxValue = 4.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C24",
        parent = "av"
    },
    av_edgeclean = {
        name = "BETTERNS2_AVEdgeClean",
        label = "Edge Redesign",
        tooltip = "Enables new math to improve edges in the distance. Will make edges smaller",
        type = "select",
        values  = { "Old", "New" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        hideValues = { 0 },
        sort = "C25",
        parent = "av"
    },
    av_worldintensity = {
        name = "BETTERNS2_AVWorldIntensity",
        label = "World Intensity",
        tooltip = "Sets the brightness value of the world.",
        type = "slider",
        defaultValue = 1,
        minValue = 0.0,
        maxValue = 2.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C26",
        parent = "av"
    },
    av_desaturation = {
        name = "BETTERNS2_AVDesaturation",
        label = "World Desaturation",
        tooltip = "Switches between different types of desaturation.",
        type = "select",
        values  = { "None", "Full Scene", "Desaturate Distance", "Desaturate Close" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        children = { "av_desaturationintensity", "av_desaturationblend" },
        hideValues = { 0 },
        sort = "C27",
        resetSettingInBuild = 237,
        parent = "av"
    },
    av_desaturationintensity = {
        name = "BETTERNS2_AVDesaturationIntensity",
        label = "Desaturation Intensity",
        tooltip = "Sets the desaturation amount.",
        type = "slider",
        defaultValue = 0.25,
        minValue = 0.0,
        maxValue = 1.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C28",
        parent = "av_desaturation"
    },
    av_desaturationblend = {
        name = "BETTERNS2_AVDesaturationBlend",
        label = "Desaturation Blend Distance",
        tooltip = "Sets the blending range for desaturation.",
        type = "slider",
        defaultValue = 0.25,
        minValue = 0.0,
        maxValue = 10.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C29",
        parent = "av_desaturation"
    },
    av_viewmodelstyle = {
        name = "BETTERNS2_AVViewModelStyle",
        label = "View Model Style",
        tooltip = "Switches between default view model or view model with AV applied.",
        type = "select",
        values  = { "Alien Vision", "Default" },
        defaultValue = 1,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        children = { "av_viewmodelintensity" },
        hideValues = { 1 },
        sort = "C30",
        parent = "av"
    },
    av_viewmodelintensity = {
        name = "BETTERNS2_AVViewModelIntensity",
        label = "View Model Intensity",
        tooltip = "Sets the amount of Alien Vision applied to the viewmodel.",
        type = "slider",
        defaultValue = 0.5,
        minValue = 0.0,
        maxValue = 1.0,
        category = "alienvision",
        valueType = "float",
        applyFunction = function() updateAlienVision() end,
        sort = "C31",
        parent = "av_viewmodelstyle"
    },
    av_skybox = {
        name = "BETTERNS2_AVSkybox",
        label = "Skybox Style",
        tooltip = "Lets you set the way the sky appears in Alien Vision.",
        type = "select",
        values  = { "Normal Sky", "Black", "Alien Vision" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        sort = "C32",
        parent = "av"
    },
    av_activationeffect = {
        name = "BETTERNS2_AVActivationEffect",
        label = "Activation Effect",
        tooltip = "Sets the transition effect when enabling Alien Vision.",
        type = "select",
        values  = { "Distance Pulse", "Fade In", "Instant On" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        sort = "C33",
        parent = "av"
    },
    av_nanoshield = {
        name = "BETTERNS2_AVNanoshield",
        label = "Nanoshield AV highlight",
        tooltip = "Improves nanoshield visibility by showing an inverted colour Nano effect on marine players and structures. May have side effects in some blue and brightly lit areas",
        type = "select",
        values  = { "Disabled", "Enabled" },
        defaultValue = 0,
        category = "alienvision",
        valueType = "int",
        applyFunction = function() updateAlienVision() end,
        helpImage = "ui/helpImages/av_nano.dds",
        helpImageSize = Vector(384, 192, 0),
        sort = "C34",
        parent = "av",
    },
}
