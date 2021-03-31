--For damage numbers
local kDamageMessage =
{
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    targetId = "entityid",
    healthArmor = "float (0 to 2048 by 0.0625)", -- 1/16, 16 bits total
    shieldAmount = "float (0 to 512 by 0.0625)"
}

function BuildDamageMessage(targetEntityId, healthArmor, hitpos, shieldAmount)
    local t = {}
    t.posx = hitpos.x
    t.posy = hitpos.y
    t.posz = hitpos.z
    t.healthArmor = math.min( math.max( healthArmor, 0 ), 2048 )
    t.targetId = (targetEntityId or Entity.invalidId)
    t.shieldAmount = math.min( math.max( shieldAmount, 0 ), 512 )
    return t
end

function ParseDamageMessage(message)
    local position = Vector(message.posx, message.posy, message.posz)
    return message.targetId, message.healthArmor, position, message.shieldAmount
end

function SendDamageMessage( attacker, targetEntityId, healthArmor, point, overkill, shieldAmount)
    shieldAmount = shieldAmount or 0
    if (healthArmor + shieldAmount) > 0 then
        local msg = BuildDamageMessage(targetEntityId, healthArmor, point, shieldAmount)

        -- damage reports must always be reliable when not spectating
        Server.SendNetworkMessage(attacker, "Damage", msg, true)

        for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
            if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
                Server.SendNetworkMessage(spectator, "Damage", msg, false)
            end
        end
    end
end

Shared.RegisterNetworkMessage( "Damage", kDamageMessage )

local kPlayerStatsMessage =
{
    isMarine = "boolean",
    playerName = string.format("string (%d)", kMaxNameLength * 4 ),
    kills = string.format("integer (0 to %d)", kMaxKills),
    assists = string.format("integer (0 to %d)", kMaxKills),
    deaths = string.format("integer (0 to %d)", kMaxDeaths),
    score = string.format("integer (0 to %d)", kMaxScore),
    accuracy = "float (0 to 100 by 0.01)",
    accuracyOnos = "float (-1 to 100 by 0.01)",
    pdmg = "float (0 to 524287 by 0.01)",
    shieldDmg = "float (0 to 524287 by 0.01",
    sdmg = "float (0 to 524287 by 0.01)",
    minutesBuilding = "float (0 to 1023 by 0.01)",
    minutesPlaying = "float (0 to 1023 by 0.01)",
    minutesComm = "float (0 to 1023 by 0.01)",
    killstreak = "integer (0 to 254)",
    steamId = "integer",
    hiveSkill = "integer",
    isRookie = "boolean",
}
Shared.RegisterNetworkMessage("PlayerStats", kPlayerStatsMessage)

local kEndStatsWeaponMessage =
{
    wTechId = "enum kTechId",
    accuracy = "float (0 to 100 by 0.01)",
    accuracyOnos = "float (-1 to 100 by 0.01)",
    kills = string.format("integer (0 to %d)", kMaxKills),
    teamNumber = "integer (1 to 2)",
    pdmg = "float (0 to 524287 by 0.01)",
    shieldDmg = "float (0 to 524287 by 0.01",
    sdmg = "float (0 to 524287 by 0.01)",
}
Shared.RegisterNetworkMessage("EndStatsWeapon", kEndStatsWeaponMessage)

local kDeathStatsMessage =
{
    lastAcc = "float (0 to 100 by 0.01)",
    lastAccOnos = "float (-1 to 100 by 0.01)",
    currentAcc = "float (0 to 100 by 0.01)",
    currentAccOnos = "float (-1 to 100 by 0.01)",
    pdmg = "float (0 to 524287 by 0.01)",
    shieldDmg = "float (0 to 524287 by 0.01",
    sdmg = "float (0 to 524287 by 0.01)",
    kills = string.format("integer (0 to %d)", kMaxKills),
}
Shared.RegisterNetworkMessage("DeathStats", kDeathStatsMessage)