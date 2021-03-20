Script.Load("lua/AdvancedOptions.lua")

kShieldDamageNumberOffset = Vector(0, 0, 1)

Client.DamageNumberLifeTime = GetAdvancedOption("damagenumbertime")

function Client.AddWorldMessage(messageType, message, position, entityId)
    Print('Enter AddWorldMessage with messageType: '..messageType)

    -- Only add damage messages if we have it enabled
    if messageType ~= kWorldTextMessageType.Damage or Client.GetOptionBoolean( "drawDamage", false ) then
        -- If we already have a message for this entity id, update existing message instead of adding new one
        local time = Client.GetTime()
        local updatedExisting = false

        if messageType == kWorldTextMessageType.Damage then
            for _, currentWorldMessage in ipairs(Client.worldMessages) do
                if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and entityId ~= nil and entityId ~= Entity.invalidId then
                    currentWorldMessage.creationTime = time
                    currentWorldMessage.previousNumber = tonumber(currentWorldMessage.message)

                    local newWholePart
                    local newDecimalPart
                    local newPosition

                    -- Offset position of damage number if damage is applied to a shield
                    -- Display only whole numbers, and save the decimal part to add later as it gets >= 1
                    if currentWorldMessage.healthArmorDamage then
                        newPosition = position

                        newWholePart = math.floor(message.healthArmorDamage)
                        newDecimalPart = message.healthArmorDamage - newWholePart
                    else
                        newPosition = position + kShieldDamageNumberOffset

                        newWholePart = math.floor(message.shieldDamage)
                        newDecimalPart = message.shieldDamage - newWholePart
                    end

                    currentWorldMessage.position = newPosition

                    currentWorldMessage.message = currentWorldMessage.message + newWholePart
                    currentWorldMessage.decimalBuffer = currentWorldMessage.decimalBuffer + newDecimalPart

                    if currentWorldMessage.decimalBuffer >= 1.0 then
                        local extraWholePart = math.floor(currentWorldMessage.decimalBuffer)
                        currentWorldMessage.message = currentWorldMessage.message + extraWholePart
                        currentWorldMessage.decimalBuffer = currentWorldMessage.decimalBuffer - extraWholePart
                    end

                    currentWorldMessage.minimumAnimationFraction = kWorldDamageRepeatAnimationScalar
                    updatedExisting = true
                    break
                end
            end
        end

        if not updatedExisting then
            local worldMessage = {}
            worldMessage.messageType = messageType

            local function setCommonWorldMessageProperties(worldMessage, position, time, entityId)
                worldMessage.position = position
                worldMessage.creationTime = time
                worldMessage.entityId = entityId
                worldMessage.animationFraction = 0
                return worldMessage
            end

            worldMessage = setCommonWorldMessageProperties(worldMessage, position, time, entityId)

            -- Only Damage message types add to existing messages.
            -- Others only have string messages.
            if messageType == kWorldTextMessageType.Damage then
                worldMessage.healthArmorDamage = true
                worldMessage.message = math.floor(message.healthArmor)
                worldMessage.decimalBuffer = (message.healthArmor - worldMessage.message)
                worldMessage.lifeTime = Client.DamageNumberLifeTime

                local shieldWorldMessage = {}
                shieldWorldMessage.messageType = messageType
                shieldWorldMessage = setCommonWorldMessageProperties(shieldWorldMessage, position + kShieldDamageNumberOffset, time, entityId)
                shieldWorldMessage.healthArmorDamage = false
                shieldWorldMessage.message = math.floor(message.shieldDamage)
                shieldWorldMessage.decimalBuffer = (message.shieldDamage - shieldWorldMessage.message)
                shieldWorldMessage.lifeTime = Client.DamageNumberLifeTime

                table.insert(Client.worldMessages, shieldWorldMessage)
            else
                worldMessage.message = message
                worldMessage.decimalBuffer = 0
            end

            if messageType == kWorldTextMessageType.CommanderError then
                worldMessage.lifeTime = kCommanderErrorMessageLifeTime
                local commander = Client.GetLocalPlayer()
                if commander then
                    commander:TriggerInvalidSound()
                end
            elseif messageType ~= kWorldTextMessageType.Damage then
                worldMessage.lifeTime = kWorldMessageLifeTime
            end

            table.insert(Client.worldMessages, worldMessage)
        end
    end
end