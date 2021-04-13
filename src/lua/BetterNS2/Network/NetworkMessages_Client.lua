-- Show damage numbers for players.
function OnCommandDamage(message)
    PROFILE("NetworkMessages_Client:OnCommandDamage")
    local targetId, healthArmor, hitpos, shieldDamage = ParseDamageMessage(message)

    Client.AddWorldMessage(
            kWorldTextMessageType.Damage,
            {healthArmor = healthArmor, shieldDamage = shieldDamage},
            hitpos,
            targetId
    )
end

Client.HookNetworkMessage("Damage", OnCommandDamage)