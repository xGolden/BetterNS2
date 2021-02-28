local originalAlienInit = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()
    originalAlienInit(self)

    Client.DestroyScreenEffect(Player.screenEffects.darkVision)
    Client.DestroyScreenEffect(HiveVision_screenEffect)
    HiveVision_screenEffect = Client.CreateScreenEffect("shaders/HiveVision.screenfx")
    Player.screenEffects.darkVision = Client.CreateScreenEffect(BetterNS2GetOption("BETTERNS2_AV"))

    if BetterNS2GetOption("BETTERNS2_AV") == "shaders/Cr4zyAV.screenfx" then
        UpdateAlienVision()
    end
end

function UpdateAlienVision()
    local useShader = Player.screenEffects.darkVision
    local av_edgesize = BetterNS2GetOption("BETTERNS2_AVEdgeSize") / 1000

    --to save on shader parameters (because theres a limit) bitshift values into a single var
    local av_bitshift_combine = math.abs(bit.lshift(BetterNS2GetOption("BETTERNS2_AVPlayerColor"), 22) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVEdgeClean"), 20) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVNanoshield"), 18) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVStyle"), 16) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVGorgeUnique"), 14) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVOffStyle"), 12) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVEdges"), 10) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVStructureColor"), 8) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVDesaturation"), 6) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVViewModelStyle"), 4) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVSkybox"), 2) +
            bit.lshift(BetterNS2GetOption("BETTERNS2_AVActivationEffect"), 0)
    )
    --bitshifted var
    useShader:SetParameter("avCombined", av_bitshift_combine)

    --world colors
    --close colours
    useShader:SetParameter("worldCloseRGBInt", BetterNS2GetOption("BETTERNS2_AVCloseColor"))
    useShader:SetParameter("closeIntensity", BetterNS2GetOption("BETTERNS2_AVCloseIntensity"))

    --distant colours
    useShader:SetParameter("worldFarRGBInt", BetterNS2GetOption("BETTERNS2_AVDistantColor"))
    useShader:SetParameter("distantIntensity", BetterNS2GetOption("BETTERNS2_AVDistantIntensity"))

    -- new 329+ marine/alien/gorge/structure colors
    useShader:SetParameter("marineRGBInt", BetterNS2GetOption("BETTERNS2_AVColorMarine"))
    useShader:SetParameter("marineIntensity", BetterNS2GetOption("BETTERNS2_AVMarineIntensity"))

    useShader:SetParameter("alienRGBInt", BetterNS2GetOption("BETTERNS2_AVColorAlien"))
    useShader:SetParameter("alienIntensity", BetterNS2GetOption("BETTERNS2_AVAlienIntensity"))

    useShader:SetParameter("gorgeRGBInt", BetterNS2GetOption("BETTERNS2_AVGorgeColor"))
    useShader:SetParameter("gorgeIntensity", BetterNS2GetOption("BETTERNS2_AVGorgeIntensity"))

    useShader:SetParameter("mStructRGBInt", BetterNS2GetOption("BETTERNS2_AVMStructColor"))
    useShader:SetParameter("mStructIntensity", BetterNS2GetOption("BETTERNS2_AVMStructIntensity"))

    useShader:SetParameter("aStructRGBInt", BetterNS2GetOption("BETTERNS2_AVAStructColor"))
    useShader:SetParameter("aStructIntensity", BetterNS2GetOption("BETTERNS2_AVAStructIntensity"))

    --edge values
    useShader:SetParameter("edgeSize", av_edgesize)

    --world values
    useShader:SetParameter("desatIntensity", BetterNS2GetOption("BETTERNS2_AVDesaturationIntensity"))
    useShader:SetParameter("avDesatBlend", BetterNS2GetOption("BETTERNS2_AVDesaturationBlend"))
    useShader:SetParameter("avWorldIntensity", BetterNS2GetOption("BETTERNS2_AVWorldIntensity"))
    useShader:SetParameter("avBlend", BetterNS2GetOption("BETTERNS2_AVBlendDistance"))

    --viewmodel
    useShader:SetParameter("avViewModel", BetterNS2GetOption("BETTERNS2_AVViewModelIntensity"))
    end