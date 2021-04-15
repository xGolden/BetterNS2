kBetterNS2Version = 7

function isCompModLoaded()
    print("Compmod version: "..g_compModRevision)
    return g_compModRevision
end

function isShineLoaded()
    if Shine then
        print("Shine loaded")
    else
        print("Shine not loaded")
    end
    return Shine
end
