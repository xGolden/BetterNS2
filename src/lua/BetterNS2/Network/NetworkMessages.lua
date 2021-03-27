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
    if (healthArmor + shieldAmount) > 0 then
        shieldAmount = shieldAmount or 0

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