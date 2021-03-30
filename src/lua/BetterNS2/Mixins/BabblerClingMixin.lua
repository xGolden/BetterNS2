function BabblerClingMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    local damage = damageTable.damage or 0
    if damage > 0 and self:GetApplyBabblerShield(damageType) then
        local amount = math.min(damage, self.babblerShieldRemaining)

        if Server then
            self.babblerShieldRemaining = self.babblerShieldRemaining - amount
            self:DestroyNumClingedBabbler(math.floor((self.numBabblers * self.babblerShieldPerBabbler - self.babblerShieldRemaining) / self.babblerShieldPerBabbler ))

            SendMarkEnemyMessage( attacker, self, amount, weapon )

            if self.OnTakeDamage then
                self:OnTakeDamage(amount, attacker, doer, hitPoint, nil, damageType, false)
            end
        end

        damageTable.damage = damage - amount
        damageTable.overshieldDamage = damageTable.overshieldDamage + amount
    end
end