if Server then
    local hits = {}

    local kHitSoundHighXenoHitCount = 4
    local kHitSoundMidXenoHitCount = 2

    function HitSound_RecordHit( attacker, target, amount, point, overkill, weapon, shieldAmount )
        attacker = (attacker and attacker:GetId()) or Entity.invalidId
        target = (target and target:GetId()) or Entity.invalidId

        Print('Got hit with shieldAmount: '..shieldAmount)

        local hit
        for i=1,#hits do
            hit = hits[i]
            if hit.attacker == attacker and hit.target == target and hit.weapon == weapon then
                if (amount + shieldAmount) > 0 then
                    hit.point = point -- always use the last point that caused damage
                end
                hit.amount = hit.amount + amount
                hit.overkill = hit.overkill + overkill
                hit.hitcount = hit.hitcount + 1
                hit.shieldAmount = hit.shieldAmount + shieldAmount
                return
            end
        end

        if (amount + shieldAmount) > 0 then
            hits[#hits+1] =
            {
                attacker = attacker,
                target = target,
                amount = amount,
                point = point,
                overkill = overkill,
                weapon = weapon,
                hitcount = 1,
                shieldAmount = shieldAmount
            }
        end

    end

    function HitSound_DispatchHits()
        local hitsounds = {}
        local attackers = {}
        local xenocounts = {}
        local xenoattacker = {}

        for i = 1, #hits do
            local hit = hits[i]
            local attacker = Shared.GetEntity(hit.attacker)
            local target = Shared.GetEntity(hit.target)

            if attacker and target and target:isa("Player") and not target:isa("Embryo") then

                local sound = HitSound_ChooseSound(hit)

                -- I suppose this doesn't make Xeno hitsounds super moddable, but...
                if hit.weapon == kTechId.Xenocide then
                    -- Xenocide hitsound is based on number of people hit
                    xenocounts[attacker] = ( xenocounts[attacker] or 0 ) + 1
                    if xenocounts[attacker] == 1 then
                        table.insert(xenoattacker, attacker)
                    end
                end

                if not hitsounds[attacker] then
                    table.insert(attackers, attacker)
                end

                -- Prefer sending an event only for the best hit
                hitsounds[attacker] = math.max( hitsounds[attacker] or 0, sound )
            end

            -- Send the accumulated damage message
            if attacker then
                Print('Sending message for: '..hit.shieldAmount)
                SendDamageMessage( attacker, hit.target, hit.amount, hit.point, hit.overkill, hit.shieldAmount )
            end

        end

        -- Xenocide hitsound is based on number of people hit
        for i = 1, #xenoattacker do
            local sound = 1
            local attacker = xenoattacker[i]
            local xenocount = xenocounts[attacker]

            if kHitSoundHighXenoHitCount <= xenocount then
                sound = 3
            elseif kHitSoundMidXenoHitCount <= xenocount then
                sound = 2
            end

            -- Prefer sending an event only for the best hit
            hitsounds[attacker] = math.max( hitsounds[attacker] or 0, sound )
        end

        for i = 1, #attackers do
            local attacker = attackers[i]
            local sound = hitsounds[attacker]

            local msg = BuildHitSoundMessage(sound)

            -- damage reports must be reliable when not spectating
            Server.SendNetworkMessage(attacker, "HitSound", msg, true)
        end

        -- Clear the record
        hits = {}
    end
end