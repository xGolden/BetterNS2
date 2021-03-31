function PlayerUI_GetWorldMessages()

    local messageTable = {}
    local player = Client.GetLocalPlayer()

    if player then

        for _, worldMessage in ipairs(Client.GetWorldMessages()) do

            local tableEntry = {}

            tableEntry.position = worldMessage.position
            tableEntry.messageType = worldMessage.messageType
            tableEntry.previousNumber = worldMessage.previousNumber
            tableEntry.text = worldMessage.message
            tableEntry.animationFraction = worldMessage.animationFraction
            tableEntry.distance = (worldMessage.position - player:GetOrigin()):GetLength()
            tableEntry.minimumAnimationFraction = worldMessage.minimumAnimationFraction
            tableEntry.entityId = worldMessage.entityId
            if worldMessage.messageType == kWorldTextMessageType.Damage then
                tableEntry.healthArmorDamage = worldMessage.healthArmorDamage
            end

            local direction = GetNormalizedVector(worldMessage.position - player:GetViewCoords().origin)
            tableEntry.inFront = player:GetViewCoords().zAxis:DotProduct(direction) > 0

            table.insert(messageTable, tableEntry)

        end

    end

    return messageTable

end