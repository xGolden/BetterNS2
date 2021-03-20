function BabblerClingMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    local damage = damageTable.damage or 0
    if damage > 0 and self:GetApplyBabblerShield(damageType) then
        local amount = math.min(damage, self.babblerShieldRemaining)

        if Server then
            self.babblerShieldRemaining = self.babblerShieldRemaining - amount
            self:DestroyNumClingedBabbler(math.floor((self.numBabblers * self.babblerShieldPerBabbler - self.babblerShieldRemaining) / self.babblerShieldPerBabbler ))
            Print('BabblerClingMixin:ModifyDamageTaken overshield: '..amount)
            if GetAreEnemies(self, attacker) then
                if HitSound_IsEnabledForWeapon( weapon ) then
                    -- Damage message will be sent at the end of OnProcessMove by the HitSound system
                    HitSound_RecordHit( attacker, self, 0, hitPoint, 0, weapon, amount )
                else
                    -- BetterNS2: SendDamageMessage passed an unused 6th param 'weapon' here, removed
                    SendDamageMessage( attacker, self:GetId(), 0, hitPoint, 0, amount)
                end
            end

            SendMarkEnemyMessage( attacker, self, amount, weapon )

            if self.OnTakeDamage then
                self:OnTakeDamage(amount, attacker, doer, hitPoint, nil, damageType, false)
            end
        end

        damageTable.damage = damage - amount
    end
end