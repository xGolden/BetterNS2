Script.Load("lua/AdvancedOptions.lua")

Client.DamageNumberLifeTime = GetAdvancedOption("damagenumbertime")

local function setCommonWorldMessageProperties(position, messageType, time, entityId)
    local worldMessage = {}
    worldMessage.messageType = messageType
    worldMessage.position = position
    worldMessage.creationTime = time
    worldMessage.entityId = entityId
    worldMessage.animationFraction = 0

    return worldMessage
end

local function AddDamageWorldMessage(amount, position, healthArmorDamage, entityId)
    local time = Client.GetTime()
    local worldMessage = setCommonWorldMessageProperties(position, kWorldTextMessageType.Damage, time, entityId)
    worldMessage.message = math.floor(amount)
    worldMessage.decimalBuffer = amount - worldMessage.message
    worldMessage.healthArmorDamage = healthArmorDamage
    worldMessage.lifeTime = Client.DamageNumberLifeTime

    table.insert(Client.worldMessages, worldMessage)
end

local function AddNonDamageWorldMessage(message, position, entityId, messageType)
    local time = Client.GetTime()
    local worldMessage = setCommonWorldMessageProperties(position, messageType, time, entityId)
    worldMessage.message = message
    worldMessage.decimalBuffer = 0
    worldMessage.lifeTime = kWorldMessageLifeTime

    if messageType == kWorldTextMessageType.CommanderError then
        worldMessage.lifeTime = kCommanderErrorMessageLifeTime
        local commander = Client.GetLocalPlayer()
        if commander then
            commander:TriggerInvalidSound()
        end
    end

    table.insert(Client.worldMessages, worldMessage)
end

<<<<<<< HEAD
=======
local function GetShieldDamageNumberPosition(position)
    --local player = Client.GetLocalPlayer()
    --local distance = (position - player:GetOrigin()):GetLength()
    --local direction = GetNormalizedVector(position - player:GetViewCoords().origin)
    --local offsetVector = (direction * distance):CrossProduct(Vector(0,1,0))
    --return Vector(position.x + 0.2 * offsetVector.x, position.y + offsetVector.y, position.z + offsetVector.z)
    return position
end

>>>>>>> 2e5e58484d71c925046aab1e49de7daace910009
local function UpdateDamageWorldMessage(messageType, message, position, entityId)
    local time = Client.GetTime()
    local healthArmor = message.healthArmor
    local shield = message.shieldDamage
    local updatedHealthArmor = false
    local updatedShieldDamage = false
    for _, currentWorldMessage in ipairs(Client.worldMessages) do
        if currentWorldMessage.messageType == messageType and currentWorldMessage.entityId == entityId and entityId ~= nil and entityId ~= Entity.invalidId then
            local newWholePart
            local newDecimalPart
            local newPosition

            if currentWorldMessage.healthArmorDamage then
                newPosition = position
                currentWorldMessage.creationTime = time
                currentWorldMessage.previousNumber = healthArmor

                newWholePart = math.floor(healthArmor)
                newDecimalPart = healthArmor - newWholePart
                updatedHealthArmor = true
            elseif not currentWorldMessage.healthArmorDamage and shield > 0 then
<<<<<<< HEAD
                newPosition = position
=======
                newPosition = GetShieldDamageNumberPosition(position)
>>>>>>> 2e5e58484d71c925046aab1e49de7daace910009
                currentWorldMessage.creationTime = time
                currentWorldMessage.previousNumber = shield

                newWholePart = math.floor(shield)
                newDecimalPart = shield - newWholePart
                updatedShieldDamage = true
            else
                -- No more shield damage done
<<<<<<< HEAD
                newPosition = position
=======
                newPosition = GetShieldDamageNumberPosition(position)
>>>>>>> 2e5e58484d71c925046aab1e49de7daace910009
                newWholePart = 0
                newDecimalPart = 0
                updatedShieldDamage = true
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
        end
    end

    return updatedHealthArmor, updatedShieldDamage
end

function Client.AddWorldMessage(messageType, message, position, entityId)
    if messageType ~= kWorldTextMessageType.Damage then
        AddNonDamageWorldMessage(message, position, entityId, messageType)
    elseif Client.GetOptionBoolean( "drawDamage", false ) then
        local updatedHealthArmor, updatedShieldDamage = UpdateDamageWorldMessage(messageType, message, position, entityId)

        if not updatedHealthArmor and message.healthArmor > 0 then
            AddDamageWorldMessage(message.healthArmor, position, true, entityId)
        end

        if not updatedShieldDamage and message.shieldDamage > 0 then
<<<<<<< HEAD
            AddDamageWorldMessage(message.shieldDamage, position, false, entityId)
=======
            AddDamageWorldMessage(message.shieldDamage, GetShieldDamageNumberPosition(position), false, entityId)
>>>>>>> 2e5e58484d71c925046aab1e49de7daace910009
        end
    end
end