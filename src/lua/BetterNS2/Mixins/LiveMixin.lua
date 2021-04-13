local SetLastDamage = debug.getupvaluex(LiveMixin.TakeDamage, "SetLastDamage", true)

function LiveMixin:TakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
    -- Use AddHealth to give health.
    assert(damage >= 0)

    local killedFromDamage = false
    local oldHealth = self:GetHealth()
    local oldArmor = self:GetArmor()

    if self.OnTakeDamage then
        self:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
    end

    -- Remember time we were last hurt to track combat
    SetLastDamage(self, Shared.GetTime(), attacker)

    if Server then

        -- If a Hive dies, we'll log the biomass level (For Stats)
        local className
        local biomassLevel

        if self.GetClassName then

            className = self:GetClassName()

            if className == "Hive" then
                biomassLevel = self:GetTeam():GetBioMassLevel()-self:GetBioMassLevel()
            end
        end

        -- Damage types that do not ignore health give us leftover damage after armor depletion regardless of us ignoring health.
        if self.healthIgnored then
            healthUsed = 0
        end

        --[[
            NOTE(Salads): An entity's health/armor is set to zero when killed, so
            make sure to use the values as they were before the entity was killed so that
            the damage popup numbers do not add damage from health or armor that wasn't actually
            used.
        --]]
        local newArmor = math.max(0, self:GetArmor() - armorUsed)
        local newHealth = math.max(0, self:GetHealth() - healthUsed)
        self.armor = newArmor
        self.health = newHealth

        local killedFromHealth = oldHealth > 0 and self:GetHealth() == 0 and not self.healthIgnored
        local killedFromArmor = oldArmor > 0 and self:GetArmor() == 0 and self.healthIgnored
        if killedFromHealth or killedFromArmor then

            if not self.AttemptToKill or self:AttemptToKill(damage, attacker, doer, point) then

                self:Kill(attacker, doer, point, direction)
                killedFromDamage = true

            end

        end

        local damageDone = (oldHealth - newHealth) + ((oldArmor - newArmor) * 2)

        local targetTeam = self:GetTeamNumber()

        -- Handle Stats for killing stuff
        if killedFromDamage then

            if self:isa("ResourceTower") then

                StatsUI_AddRTStat(targetTeam, self:GetIsBuilt(), true, false, tostring(self:GetOrigin()), self:GetLocationName())

            elseif not self:isa("Player") and not self:isa("Weapon") then

                if StatsUI_GetTechLoggedAsBuilding(self.GetTechId and self:GetTechId()) or className == "Drifter" then
                    StatsUI_AddExportBuilding(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), true, true, false) -- Destroyed drifter/tech 110
                end

                if className then

                    if not StatsUI_GetBuildingBlockedFromLog(className) then
                        StatsUI_AddBuildingStat(targetTeam, self.GetTechId and self:GetTechId(), true)
                    end

                    if StatsUI_GetBuildingLogged(className) then

                        StatsUI_AddTechStat(self:GetTeamNumber(), self.GetTechId and self:GetTechId(), self:GetIsBuilt(), true, false)

                        -- If a hive died, we add the biomass level to the tech log
                        -- If all hives died, we show biomass 1 as lost
                        -- This makes it possible to see the biomass level during the game
                        if biomassLevel then
                            StatsUI_AddTechStat(self:GetTeamNumber(), StatsUI_GetBiomassTechIdFromLevel(Clamp(biomassLevel, 1, 9)), true, biomassLevel == 0, false)
                        end
                    end
                end
            end
        end

        -- Handle stats for damage
        local attackerSteamId, attackerWeapon, attackerTeam = StatsUI_GetAttackerWeapon(attacker, doer)
        if attackerSteamId then

            -- Don't count friendly fire towards damage counts
            -- Check if there is a doer, because when alien structures are off infestation
            -- it will count as an attack for the last person that shot it, only log actual attacks
            if attackerTeam ~= targetTeam and damage and doer then
                if self:isa("Player") and not (self:isa("Hallucination") or self.isHallucination) then
                    StatsUI_AddPlayerDamageStat(attackerSteamId, damageDone, attackerWeapon, attackerTeam)
                else
                    StatsUI_AddStructureDamageStat(attackerSteamId, damageDone, attackerWeapon, attackerTeam)
                end
            end
        end

        return killedFromDamage, damageDone

    end

    -- things only die on the server
    return false, false
end
