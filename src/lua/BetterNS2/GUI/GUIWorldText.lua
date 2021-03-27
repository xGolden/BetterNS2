local kMinDistanceToCenter = GUIScale(64)
GUIWorldText.kShieldDamageFont = Fonts.kAgencyFB_Smaller_Bordered

local function GetWorldPosition(message, animationFraction, viewCoords)
    local animationScalar = math.sin(animationFraction * math.pi / 2)
    local inFrontOfPlayer
    if message.healthArmorDamage then
        inFrontOfPlayer = viewCoords.origin + viewCoords.zAxis * 1 - viewCoords.yAxis * .15
        return Vector(inFrontOfPlayer.x + (message.position.x - inFrontOfPlayer.x) * animationScalar,
                inFrontOfPlayer.y + (message.position.y - inFrontOfPlayer.y) * animationScalar,
                inFrontOfPlayer.z + (message.position.z - inFrontOfPlayer.z) * animationScalar)
    else

        inFrontOfPlayer = viewCoords.origin + viewCoords.zAxis * 1 + viewCoords.yAxis * .05
        return Vector(inFrontOfPlayer.x + (message.position.x - inFrontOfPlayer.x) * animationScalar,
                inFrontOfPlayer.y + (inFrontOfPlayer.y - message.position.y) * animationScalar,
                inFrontOfPlayer.z + (message.position.z - inFrontOfPlayer.z) * animationScalar)
    end
end

function GUIWorldText:UpdateDamageMessage(message, messageItem, useColor, deltaTime)

    -- Updating messages with new numbers shouldn't reset animation - keep it big and faded-in intead of growing
    local animationFraction = message.animationFraction
    if message.minimumAnimationFraction then
        animationFraction = math.max(animationFraction, message.minimumAnimationFraction)
    end

    -- Remove commas from text and convert to number.
    local targetNumberStr = string.gsub(message.text, ",", "")
    local targetNumber = tonumber( targetNumberStr )
    messageItem:SetText("-" .. CommaValue(tostring(math.round(targetNumber))))

    local player = Client.GetLocalPlayer()
    local viewCoords = player:GetViewCoords()

    local worldInterpPosition = GetWorldPosition(message, animationFraction, viewCoords)

    local direction = GetNormalizedVector(worldInterpPosition - viewCoords.origin)
    local inFront = viewCoords.zAxis:DotProduct(direction) > 0
    messageItem:SetIsVisible(inFront and self.visible)

    local screenPos = Client.WorldToScreen(worldInterpPosition)

    if not self.screenCenter then
        self.screenCenter = Vector(Client.GetScreenWidth()/2, Client.GetScreenHeight()/2, 0)
    end

    local toCenter = screenPos - self.screenCenter

    if toCenter:GetLength() < kMinDistanceToCenter then
        screenPos = self.screenCenter + GetNormalizedVectorXY(toCenter) * kMinDistanceToCenter
    end
    local baseScale

    if not message.healthArmorDamage then
        messageItem:SetFontName(GUIWorldText.kShieldDamageFont)
        baseScale = 0.3
    else
        messageItem:SetFontName(GUIWorldText.kFont)
        baseScale = 1
    end

    messageItem:SetPosition(screenPos)

    -- Fades to invisible after half the life time
    useColor.a = Clamp(math.cos(animationFraction * math.pi / 2), 0, 1)
    messageItem:SetColor(useColor)

    local animationScalar = Clamp(math.sin( 2 * animationFraction * math.pi), 0, 1)

    -- Scale number's up the more damage we do
    local numberScalar = math.min(1 + (targetNumber / 500), 1)
    local scaleFactor = baseScale + animationScalar * 1 * numberScalar
    messageItem:SetScale(GUIScale(Vector(scaleFactor, scaleFactor, scaleFactor)) * GUIWorldText.kCustomScale)
    GUIMakeFontScale(messageItem)
end

function GUIWorldText:UpdateRegularMessage(message, messageItem, useColor)

    -- Animate as rising text
    local animYOffset = message.animationFraction * GUIWorldText.kYAnim
    local position = Client.WorldToScreen(message.position)
    position.y = position.y + animYOffset
    useColor.a = 1 - message.animationFraction

    if message.messageType == kWorldTextMessageType.CommanderError then
        position.y = position.y + kCommanderMessageVerticalOffset
    end

    messageItem:SetFontName(GUIWorldText.kFont)
    GUIMakeFontScale(messageItem)

    messageItem:SetText(message.text)
    messageItem:SetPosition(position)
    messageItem:SetColor(useColor)

    -- Don't display messages that are behind us
    messageItem:SetIsVisible(message.inFront and self.visible)

end