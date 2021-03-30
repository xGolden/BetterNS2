local function ApplyTargetModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon, overshieldDamage)

    -- The host can provide an override for this function.
    if target.ComputeDamageOverride then
        damage, overshieldDamage = target:ComputeDamageOverride(attacker, damage, damageType, hitPoint, overshieldDamage)
    end

    -- Used by mixins.
    if target.ComputeDamageOverrideMixin then
        damage, overshieldDamage = target:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint, overshieldDamage)
    end

    if target.ShieldComputeDamageOverrideMixin then
        damage, overshieldDamage = target:ShieldComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint, overshieldDamage)
    end

    if target.GetArmorUseFractionOverride then
        armorFractionUsed = target:GetArmorUseFractionOverride(damageType, armorFractionUsed, hitPoint)
    end

    if target.GetHealthPerArmorOverride then
        healthPerArmor = target:GetHealthPerArmorOverride(damageType, healthPerArmor, hitPoint)
    end

    local damageTable = {}
    damageTable.damage = damage
    damageTable.armorFractionUsed = armorFractionUsed
    damageTable.healthPerArmor = healthPerArmor
    damageTable.overshieldDamage = overshieldDamage

    if target.ModifyDamageTaken then
        target:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    end

    return damageTable.damage, damageTable.armorFractionUsed, damageTable.healthPerArmor, damageTable.overshieldDamage

end

debug.setupvaluex(GetDamageByType, "ApplyTargetModifiers", ApplyTargetModifiers)