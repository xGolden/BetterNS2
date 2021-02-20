-- As seen here: http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function BetterNS2CopyTable(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[BetterNS2CopyTable(k, s)] = BetterNS2CopyTable(v, s) end
    return res
end

function BetterNS2WrapTextIntoTable( str, limit, indent, indent1 )

    limit = limit or 72
    indent = indent or ""
    indent1 = indent1 or indent

    local here = 1 - #indent1
    str = indent1..str:gsub( "(%s+)()(%S+)()",
            function( _, st, word, fi )
                if fi-here > limit then
                    here = st - #indent
                    --Print(indent..word)
                    return "\n"..indent..word
                end
            end )

    return StringSplit(str, "\n")
end

if Server then
    function SendBetterNS2Message(message)

        if message then

            local messageList = BetterNS2WrapTextIntoTable(message, kMaxChatLength)

            for m = 1, #messageList do
                Server.SendNetworkMessage("Chat", BuildChatMessage(false, "[BetterNS2]", -1, kTeamReadyRoom, kNeutralTeamType, messageList[m]), true)
                Shared.Message("Chat All - [BetterNS2]: " .. messageList[m])
                Server.AddChatToHistory(messageList[m], "[BetterNS2]", 0, kTeamReadyRoom, false)
            end

        end

    end

    function BetterNS2ServerAdminPrint(client, message)
        local kMaxPrintLength = 128

        if client then

            -- First we must split up the message into a list of messages no bigger than kMaxPrintLength each.
            local messageList = BetterNS2WrapTextIntoTable(message, kMaxPrintLength)

            for m = 1, #messageList do
                Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint", { message = messageList[m] }, true)
            end

        end

    end

    function GetBetterNS2TagBitmask()

        local tags = { }
        Server.GetTags(tags)

        for t = 1, #tags do
            local _, pos = string.find(tags[t], "BetterNS2_0x")
            if pos then
                return(tonumber(string.sub(tags[t], pos+1)))
            end
        end

    end

    function SetBetterNS2TagBitmask(bitmask)

        local tags = { }
        Server.GetTags(tags)

        for t = 1, #tags do
            if string.find(tags[t], "BetterNS2_0x") then
                Server.RemoveTag(tags[t])
            end
        end

        Server.AddTag("BetterNS2_0x" .. bitmask)

    end

    function AddBetterNS2TagBitmask(mask)
        local bitmask = GetBetterNS2TagBitmask() or 0
        bitmask = bit.bor(bitmask, mask)
        SetBetterNS2TagBitmask(bitmask)
    end

    function SubstractBetterNS2TagBitmask(mask)
        local bitmask = GetBetterNS2TagBitmask() or 0
        bitmask = bit.band(bitmask, bit.bnot(mask))
        SetBetterNS2TagBitmask(bitmask)
    end

end

function CheckBetterNS2TagOption(bitmask, option)
    return(bit.band(bitmask, option) > 0)
end

if Client then
    function BetterNS2GetGameTimeString()

        local gameTime, state = PlayerUI_GetGameLengthTime()
        if state < kGameState.PreGame then
            gameTime = 0
        end

        local minutes = math.floor(gameTime / 60)
        local seconds = math.floor(gameTime % 60)

        return (string.format("%d:%.2d", minutes, seconds))

    end

    function BetterNS2GetRealTimeString()
        local time = os.time()
        return os.date("%X", time)
    end
end

function BetterNS2FormatDateTimeString(dateTime)
    local tmpDate = os.date("*t", dateTime)
    local ordinal = "th"

    local lastDig = tmpDate.day % 10
    if (tmpDate.day < 11 or tmpDate.day > 13) and lastDig > 0 and lastDig < 4 then
        if lastDig == 1 then
            ordinal = "st"
        elseif lastDig == 2 then
            ordinal = "nd"
        else
            ordinal = "rd"
        end
    end

    return string.format("%s%s, %d @ %d:%02d", os.date("%A, %B %d", dateTime), ordinal, tmpDate.year, tmpDate.hour, tmpDate.min)
end

function BetterNS2GetWeaponAmmoString(weapon)
    local ammo = ""
    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ClipWeapon") then
            ammo = string.format("%d", weapon:GetClip() or 0)
        elseif weapon:isa("GrenadeThrower") then
            ammo = string.format("%d", weapon.grenadesLeft or 0)
        elseif weapon:isa("LayMines") then
            ammo = string.format("%d", weapon:GetMinesLeft() or 0)
        elseif weapon:isa("ExoWeaponHolder") then
            local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
            local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)
            local leftAmmo = -1
            local rightAmmo = -1
            if rightWeapon:isa("Railgun") then
                rightAmmo = rightWeapon:GetChargeAmount() * 100
                if leftWeapon:isa("Railgun") then
                    leftAmmo = leftWeapon:GetChargeAmount() * 100
                end
            elseif rightWeapon:isa("Minigun") then
                rightAmmo = rightWeapon.heatAmount * 100
                if leftWeapon:isa("Minigun") then
                    leftAmmo = leftWeapon.heatAmount * 100
                end
            end
            if leftAmmo > -1 and rightAmmo > -1 then
                ammo = string.format("%d%% / %d%%", leftAmmo, rightAmmo)
            elseif rightAmmo > -1 then
                ammo = string.format("%d%%", rightAmmo)
            end
        elseif weapon:isa("Builder") or weapon:isa("Welder") and PlayerUI_GetUnitStatusPercentage() > 0 then
            ammo = string.format("%d%%", PlayerUI_GetUnitStatusPercentage())
        end
    end

    return ammo
end

function BetterNS2GetWeaponAmmoFraction(weapon)
    local fraction = -1
    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ClipWeapon") then
            fraction = weapon:GetClip()/weapon:GetClipSize()
        elseif weapon:isa("GrenadeThrower") then
            fraction = weapon.grenadesLeft/kMaxHandGrenades
        elseif weapon:isa("LayMines") then
            fraction = weapon:GetMinesLeft()/kNumMines
        elseif weapon:isa("ExoWeaponHolder") then
            local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
            local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)

            if rightWeapon:isa("Railgun") then
                fraction = rightWeapon:GetChargeAmount()
                if leftWeapon:isa("Railgun") then
                    fraction = (fraction + leftWeapon:GetChargeAmount()) / 2.0
                end
            elseif rightWeapon:isa("Minigun") then
                fraction = rightWeapon.heatAmount
                if leftWeapon:isa("Minigun") then
                    fraction = (fraction + leftWeapon.heatAmount) / 2.0
                end
                fraction = 1 - fraction
            end
        elseif weapon:isa("Builder") or weapon:isa("Welder") then
            fraction = PlayerUI_GetUnitStatusPercentage()/100
        end
    end

    return fraction
end

function BetterNS2GetWeaponReserveAmmoString(weapon)
    local ammo = ""
    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ClipWeapon") then
            ammo = string.format("%d", weapon:GetAmmo() or 0)
        end
    end

    return ammo
end

function BetterNS2GetWeaponReserveAmmoFraction(weapon)
    local fraction = -1
    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ClipWeapon") then
            fraction = weapon:GetAmmo()/weapon:GetMaxAmmo()
        end
    end

    return fraction
end

local function ScreenSmallAspect()
    return ConditionalValue(Client.GetScreenWidth() > Client.GetScreenHeight(), Client.GetScreenHeight(), Client.GetScreenWidth())
end

local function GUILinearScale(size)
    local kScreenScaleAspect = 1280
    -- 25% bigger so it's similar size to the "normal" GUIScale
    local scale = 1.25
    -- Text is hard to read on lower res, so make it bigger for them
    if Client.GetScreenWidth() < 1920 then
        scale = 1.5
    end
    return (ScreenSmallAspect() / kScreenScaleAspect)*size*scale
end

-- Todo: Merge into vanilla
function Class_AddMethod( className, methodName, method )
    assert( _G[className][methodName] == nil or _G[className][methodName] == method, "Attempting to add new method when class already has one -- use Class_ReplaceMethod instead" )

    _G[className][methodName] = method

    local derived = Script.GetDerivedClasses(className)
    if derived == nil then return end

    for _, d in ipairs(derived) do
        Class_AddMethod(d, methodName, method )
    end
end
