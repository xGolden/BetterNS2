--local miscDataTable = debug.getupvaluex(GUIGameEndStats., "statsTable", false)

local kFriendlyWeaponNames = debug.getupvaluex(GUIGameEndStats, "kFriendlyWeaponNames", false)
local printNum = debug.getupvaluex(GUIGameEndStats, "printNum", false)
local printNum2 = debug.getupvaluex(GUIGameEndStats, "printNum2", false)
local cardsTable = debug.getupvaluex(GUIGameEndStats, "cardsTable", false)
local lastStatsMsg = debug.getupvaluex(GUIGameEndStats, "lastStatsMsg", false)
local kRowSize = debug.getupvaluex(GUIGameEndStats, "kRowSize", false)
local kRowBorderSize = debug.getupvaluex(GUIGameEndStats, "kRowBorderSize", false)
local kRowFontName = debug.getupvaluex(GUIGameEndStats, "kRowFontName", false)
local scaledVector = debug.getupvaluex(GUIGameEndStats, "scaledVector", false)
local kRowPlayerNameOffset = debug.getupvaluex(GUIGameEndStats, "kRowPlayerNameOffset", false)
local avgAccTable = debug.getupvaluex(GUIGameEndStats, "avgAccTable", false)
local finalStatsTable = debug.getupvaluex(GUIGameEndStats, "finalStatsTable", false)
local playerStatMap = debug.getupvaluex(GUIGameEndStats, "playerStatMap", false)
local kMarinePlayerStatsOddColor = debug.getupvaluex(GUIGameEndStats, "kMarinePlayerStatsOddColor", false)
local kAlienPlayerStatsOddColor = debug.getupvaluex(GUIGameEndStats, "kAlienPlayerStatsOddColor", false)
local kPlayerStatsTextColor = debug.getupvaluex(GUIGameEndStats, "kPlayerStatsTextColor", false)
local kMarinePlayerStatsEvenColor = debug.getupvaluex(GUIGameEndStats, "kMarinePlayerStatsEvenColor", false)
local kAlienPlayerStatsEvenColor = debug.getupvaluex(GUIGameEndStats, "kAlienPlayerStatsEvenColor", false)
local kCurrentPlayerStatsColor = debug.getupvaluex(GUIGameEndStats, "kCurrentPlayerStatsColor", false)
local kCurrentPlayerStatsTextColor = debug.getupvaluex(GUIGameEndStats, "kCurrentPlayerStatsTextColor", false)
local miscDataTable = debug.getupvaluex(GUIGameEndStats, "miscDataTable", false)
local statusSummaryTable = debug.getupvaluex(GUIGameEndStats, "statusSummaryTable", false)
local kStatusStatsColor = debug.getupvaluex(GUIGameEndStats, "kStatusStatsColor", false)
local kMarineStatsColor = debug.getupvaluex(GUIGameEndStats, "kMarineStatsColor", false)
local kAlienStatsColor = debug.getupvaluex(GUIGameEndStats, "kAlienStatsColor", false)
local kCommanderStatsColor = debug.getupvaluex(GUIGameEndStats, "kCommanderStatsColor", false)
local kCommanderStatsEvenColor = debug.getupvaluex(GUIGameEndStats, "kCommanderStatsEvenColor", false)
local kCommanderStatsOddColor = debug.getupvaluex(GUIGameEndStats, "kCommanderStatsOddColor", false)
local techLogTable = debug.getupvaluex(GUIGameEndStats, "techLogTable", false)
local buildingSummaryTable = debug.getupvaluex(GUIGameEndStats, "buildingSummaryTable", false)
local commanderStats = debug.getupvaluex(GUIGameEndStats, "commanderStats", false)
local hiveSkillGraphTable = debug.getupvaluex(GUIGameEndStats, "hiveSkillGraphTable", false)
local rtGraphTable = debug.getupvaluex(GUIGameEndStats, "rtGraphTable", false)
local killGraphTable = debug.getupvaluex(GUIGameEndStats, "killGraphTable", false)
local CreateCommStatsRow = debug.getupvaluex(GUIGameEndStats, "CreateCommStatsRow", false)
local kHeaderRowColor = debug.getupvaluex(GUIGameEndStats, "kHeaderRowColor", false)
local kMarineHeaderRowTextColor = debug.getupvaluex(GUIGameEndStats, "kMarineHeaderRowTextColor", false)
local kAverageRowColor = debug.getupvaluex(GUIGameEndStats, "kAverageRowColor", false)
local kAverageRowTextColor = debug.getupvaluex(GUIGameEndStats, "kAverageRowTextColor", false)
local kAlienHeaderRowTextColor = debug.getupvaluex(GUIGameEndStats, "kAlienHeaderRowTextColor", false)
local CreateTechLogRow = debug.getupvaluex(GUIGameEndStats, "CreateTechLogRow", false)
local kLostTechOddColor = debug.getupvaluex(GUIGameEndStats, "kLostTechOddColor", false)
local kLostTechEvenColor = debug.getupvaluex(GUIGameEndStats, "kLostTechEvenColor", false)
local GetXSpacing = debug.getupvaluex(GUIGameEndStats, "GetXSpacing", false)
local GetYSpacing = debug.getupvaluex(GUIGameEndStats, "GetYSpacing", false)

local function CreateScoreboardRow(container, bgColor, textColor, playerName, kills, assists, deaths, acc, pdmg, shieldDmg, sdmg, timeBuilding, timePlayed, timeComm, steamId, isRookie, hiveSkill)

    local containerSize = container:GetSize()
    container:SetSize(Vector(containerSize.x, containerSize.y + kRowSize.y, 0))

    local item = {}

    item.background = GUIManager:CreateGraphicItem()
    item.background:SetStencilFunc(GUIItem.NotEqual)
    item.background:SetColor(bgColor)
    item.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    item.background:SetPosition(Vector(kRowBorderSize, containerSize.y - kRowBorderSize, 0))
    item.background:SetLayer(kGUILayerMainMenu)
    item.background:SetSize(kRowSize)

    if steamId then
        item.steamId = steamId
    end

    if hiveSkill and GetPlayerSkillTier then
        local skillTier, skillTierName = GetPlayerSkillTier(hiveSkill, isRookie)
        item.hiveSkillTier = skillTier
        item.hiveSkillTierName = skillTierName
    end

    container:AddChild(item.background)

    item.playerName = GUIManager:CreateTextItem()
    item.playerName:SetStencilFunc(GUIItem.NotEqual)
    item.playerName:SetFontName(kRowFontName)
    item.playerName:SetColor(isRookie and Color(0, 0.8, 0.25, 1) or textColor)
    item.playerName:SetScale(scaledVector)
    GUIMakeFontScale(item.playerName)
    item.playerName:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.playerName:SetTextAlignmentY(GUIItem.Align_Center)
    item.playerName:SetPosition(Vector(kRowPlayerNameOffset, 0, 0))
    item.playerName:SetText(playerName or "")
    item.playerName:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.playerName)

    local playerNameLength = item.playerName:GetTextWidth(playerName or "") * item.playerName:GetScale().x + GUILinearScale(5)

    if timeComm then
        item.commIcon = GUIManager:CreateGraphicItem()
        item.commIcon:SetStencilFunc(GUIItem.NotEqual)
        item.commIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
        item.commIcon:SetTexture("ui/badges/commander_grey_20.dds")
        item.commIcon:SetIsVisible(true)
        item.commIcon:SetSize(GUILinearScale(Vector(20, 20, 0)))
        item.commIcon:SetPosition(Vector(kRowPlayerNameOffset + playerNameLength, -GUILinearScale(10), 0))
        item.commIcon:SetLayer(kGUILayerMainMenu)
        item.commIcon.tooltip = "Commander time: " .. timeComm
        item.background:AddChild(item.commIcon)
    end

    local kItemSize = GUILinearScale(50)
    local xOffset = kRowSize.x
    local kItemPaddingMediumLarge = GUILinearScale(50)
    local kItemPaddingMedium = GUILinearScale(40)
    local kItemPaddingSmallMedium = GUILinearScale(30)
    local kItemPaddingSmall = GUILinearScale(20)
    local kItemPaddingExtraSmall = GUILinearScale(10)

    xOffset = xOffset - kItemPaddingMedium + kItemPaddingExtraSmall

    item.timePlayed = GUIManager:CreateTextItem()
    item.timePlayed:SetStencilFunc(GUIItem.NotEqual)
    item.timePlayed:SetFontName(kRowFontName)
    item.timePlayed:SetColor(textColor)
    item.timePlayed:SetScale(scaledVector)
    GUIMakeFontScale(item.timePlayed)
    item.timePlayed:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.timePlayed:SetTextAlignmentY(GUIItem.Align_Center)
    item.timePlayed:SetTextAlignmentX(GUIItem.Align_Max)
    item.timePlayed:SetPosition(Vector(xOffset, 0, 0))
    item.timePlayed:SetText(timePlayed or "")
    item.timePlayed:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.timePlayed)

    xOffset = xOffset - kItemSize - kItemPaddingExtraSmall

    item.timeBuilding = GUIManager:CreateTextItem()
    item.timeBuilding:SetStencilFunc(GUIItem.NotEqual)
    item.timeBuilding:SetFontName(kRowFontName)
    item.timeBuilding:SetColor(textColor)
    item.timeBuilding:SetScale(scaledVector)
    GUIMakeFontScale(item.timeBuilding)
    item.timeBuilding:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.timeBuilding:SetTextAlignmentY(GUIItem.Align_Center)
    item.timeBuilding:SetTextAlignmentX(GUIItem.Align_Max)
    item.timeBuilding:SetPosition(Vector(xOffset, 0, 0))
    item.timeBuilding:SetText(timeBuilding or "")
    item.timeBuilding:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.timeBuilding)

    xOffset = xOffset - kItemSize - kItemPaddingSmallMedium

    item.sdmg = GUIManager:CreateTextItem()
    item.sdmg:SetStencilFunc(GUIItem.NotEqual)
    item.sdmg:SetFontName(kRowFontName)
    item.sdmg:SetColor(textColor)
    item.sdmg:SetScale(scaledVector)
    GUIMakeFontScale(item.sdmg)
    item.sdmg:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.sdmg:SetTextAlignmentY(GUIItem.Align_Center)
    item.sdmg:SetTextAlignmentX(GUIItem.Align_Max)
    item.sdmg:SetPosition(Vector(xOffset, 0, 0))
    item.sdmg:SetText(sdmg or "")
    item.sdmg:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.sdmg)

    xOffset = xOffset - kItemSize - kItemPaddingSmallMedium

    item.pdmg = GUIManager:CreateTextItem()
    item.pdmg:SetStencilFunc(GUIItem.NotEqual)
    item.pdmg:SetFontName(kRowFontName)
    item.pdmg:SetColor(textColor)
    item.pdmg:SetScale(scaledVector)
    GUIMakeFontScale(item.pdmg)
    item.pdmg:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.pdmg:SetTextAlignmentY(GUIItem.Align_Center)
    item.pdmg:SetTextAlignmentX(GUIItem.Align_Max)
    item.pdmg:SetPosition(Vector(xOffset, 0, 0))
    item.pdmg:SetText(pdmg or "")
    item.pdmg:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.pdmg)

    item.shieldDmg = GUIManager:CreateTextItem()
    item.shieldDmg:SetStencilFunc(GUIItem.NotEqual)
    item.shieldDmg:SetFontName(kRowFontName)
    item.shieldDmg:SetColor(textColor)
    item.shieldDmg:SetScale(scaledVector)
    GUIMakeFontScale(item.shieldDmg)
    item.shieldDmg:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.shieldDmg:SetTextAlignmentY(GUIItem.Align_Center)
    item.shieldDmg:SetTextAlignmentX(GUIItem.Align_Max)
    item.shieldDmg:SetPosition(Vector(xOffset, 0, 0))
    item.shieldDmg:SetText(shieldDmg or "")
    item.shieldDmg:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.shieldDmg)

    xOffset = xOffset - kItemSize - kItemSize

    item.acc = GUIManager:CreateTextItem()
    item.acc:SetStencilFunc(GUIItem.NotEqual)
    item.acc:SetFontName(kRowFontName)
    item.acc:SetColor(textColor)
    item.acc:SetScale(scaledVector)
    GUIMakeFontScale(item.acc)
    item.acc:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.acc:SetTextAlignmentY(GUIItem.Align_Center)
    item.acc:SetTextAlignmentX(GUIItem.Align_Max)
    item.acc:SetPosition(Vector(xOffset, 0, 0))
    item.acc:SetText(acc or "")
    item.acc:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.acc)

    xOffset = xOffset - kItemSize - ConditionalValue(avgAccTable.marineOnosAcc == -1, kItemPaddingSmall, kItemPaddingMediumLarge)*2

    item.deaths = GUIManager:CreateTextItem()
    item.deaths:SetStencilFunc(GUIItem.NotEqual)
    item.deaths:SetFontName(kRowFontName)
    item.deaths:SetColor(textColor)
    item.deaths:SetScale(scaledVector)
    GUIMakeFontScale(item.deaths)
    item.deaths:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.deaths:SetTextAlignmentY(GUIItem.Align_Center)
    item.deaths:SetTextAlignmentX(GUIItem.Align_Max)
    item.deaths:SetPosition(Vector(xOffset, 0, 0))
    item.deaths:SetText(deaths or "")
    item.deaths:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.deaths)

    xOffset = xOffset - kItemSize

    item.assists = GUIManager:CreateTextItem()
    item.assists:SetStencilFunc(GUIItem.NotEqual)
    item.assists:SetFontName(kRowFontName)
    item.assists:SetColor(textColor)
    item.assists:SetScale(scaledVector)
    GUIMakeFontScale(item.assists)
    item.assists:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.assists:SetTextAlignmentY(GUIItem.Align_Center)
    item.assists:SetTextAlignmentX(GUIItem.Align_Max)
    item.assists:SetPosition(Vector(xOffset, 0, 0))
    item.assists:SetText(assists or "")
    item.assists:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.assists)

    xOffset = xOffset - kItemSize

    item.kills = GUIManager:CreateTextItem()
    item.kills:SetStencilFunc(GUIItem.NotEqual)
    item.kills:SetFontName(kRowFontName)
    item.kills:SetColor(textColor)
    item.kills:SetScale(scaledVector)
    GUIMakeFontScale(item.kills)
    item.kills:SetAnchor(GUIItem.Left, GUIItem.Center)
    item.kills:SetTextAlignmentY(GUIItem.Align_Center)
    item.kills:SetTextAlignmentX(GUIItem.Align_Max)
    item.kills:SetPosition(Vector(xOffset, 0, 0))
    item.kills:SetText(kills or "")
    item.kills:SetLayer(kGUILayerMainMenu)
    item.background:AddChild(item.kills)

    return item

end

local function CHUDSetWeaponStats(message)

    local weaponName

    local wTechId = message.wTechId

    if wTechId > 1 and wTechId ~= kTechId.None then
        if kFriendlyWeaponNames[wTechId] then
            weaponName = kFriendlyWeaponNames[wTechId]
        else
            local techdataName = LookupTechData(wTechId, kTechDataMapName) or Locale.ResolveString(LookupTechData(wTechId, kTechDataDisplayName, ""))
            weaponName = techdataName:gsub("^%l", string.upper)
        end
    else
        weaponName = "Others"
    end

    local cardEntry = {}
    cardEntry.text = weaponName
    cardEntry.teamNumber = message.teamNumber
    cardEntry.logoTexture = kInventoryIconsTexture
    cardEntry.logoCoords = { GetTexCoordsForTechId(wTechId) }
    cardEntry.logoSizeX = 64
    cardEntry.logoSizeY = 32
    cardEntry.message = message

    cardEntry.rows = {}

    local row = {}
    row.title = "Kills"
    row.value = printNum(message.kills)
    table.insert(cardEntry.rows, row)

    if message.accuracy > 0 then
        row = {}
        row.title = "Accuracy"
        row.value = printNum(message.accuracy) .. "%"
        table.insert(cardEntry.rows, row)

        if message.accuracyOnos > -1 then
            row = {}
            row.title = "Accuracy (No Onos)"
            row.value = printNum(message.accuracyOnos) .. "%"
            table.insert(cardEntry.rows, row)
        end
    end

    if message.pdmg > 0 then
        row = {}
        row.title = "Player damage"
        row.value = printNum(message.pdmg)
        table.insert(cardEntry.rows, row)
    end

    if message.shieldDmg > 0 then
        row = {}
        row.title = "Shield damage"
        row.value = printNum(message.shieldDmg)
        table.insert(cardEntry.rows, row)
    end

    if message.sdmg > 0 then
        row = {}
        row.title = "Structure damage"
        row.value = printNum(message.sdmg)
        table.insert(cardEntry.rows, row)
    end

    table.insert(cardsTable, cardEntry)

    lastStatsMsg = Shared.GetTime()
end

function GUIGameEndStats:ProcessStats()
    table.sort(finalStatsTable, function(a, b)
        a.teamNumber = a.isMarine and 1 or 2
        b.teamNumber = b.isMarine and 1 or 2
        a.realAccuracy = a.accuracyOnos == -1 and a.accuracy or a.accuracyOnos
        b.realAccuracy = b.accuracyOnos == -1 and b.accuracy or b.accuracyOnos
        a.lowerCaseName = string.UTF8Lower(a.playerName)
        b.lowerCaseName = string.UTF8Lower(b.playerName)
        if a.teamNumber == b.teamNumber then
            if a.kills == b.kills then
                if a.assists == b.assists then
                    if a.deaths == b.deaths then
                        if a.realAccuracy == b.realAccuracy then
                            if a.pdmg == b.pdmg then
                                if a.shieldDmg == b.shieldDmg then
                                    if a.sdmg == b.sdmg then
                                        if a.minutesBuilding == b.minutesBuilding then
                                            return a.lowerCaseName < b.lowerCaseName
                                        else
                                            return a.minutesBuilding > b.minutesBuilding
                                        end
                                    else
                                        return a.sdmg > b.sdmg
                                    end
                                else
                                    return a.shieldDmg > b.shieldDmg
                                end
                            else
                                return a.pdmg > b.pdmg
                            end
                        else
                            return a.accuracy > b.accuracy
                        end
                    else
                        return a.deaths < b.deaths
                    end
                else
                    return a.assists > b.assists
                end
            else
                return a.kills > b.kills
            end
        else
            return a.teamNumber < b.teamNumber
        end
    end)

    table.sort(cardsTable, function(a, b)
        if a.order and b.order then
            return a.order < b.order
        elseif a.teamNumber == b.teamNumber then
            if a.message.kills and b.message.kills then
                a.message.realAccuracy = a.message.accuracyOnos == -1 and a.message.accuracy or a.message.accuracyOnos
                b.message.realAccuracy = b.message.accuracyOnos == -1 and b.message.accuracy or b.message.accuracyOnos
                if a.message.kills == b.message.kills then
                    return a.message.realAccuracy > b.message.realAccuracy
                else
                    return a.message.kills > b.message.kills
                end
            end
        else
            return a.teamNumber < b.teamNumber
        end
    end)

    local totalKills1 = 0
    local totalKills2 = 0
    local totalAssists1 = 0
    local totalAssists2 = 0
    local totalDeaths1 = 0
    local totalDeaths2 = 0
    local totalPdmg1 = 0
    local totalPdmg2 = 0
    local totalShieldDmg1 = 0
    local totalShieldDmg2 = 0
    local totalSdmg1 = 0
    local totalSdmg2 = 0
    local totalTimeBuilding1 = 0
    local totalTimeBuilding2 = 0
    local totalTimePlaying1 = 0
    local totalTimePlaying2 = 0
    local avgAccuracy1 = 0
    local avgAccuracy1Onos = 0
    local avgAccuracy2 = 0
    local team1Comm = 0
    local team2Comm = 0
    local team1CommTime = 0
    local team2CommTime = 0

    self:Uninitialize()
    self:Initialize()

    for _, message in ipairs(finalStatsTable) do
        -- Initialize the values in case there's something missing
        message.isMarine = message.isMarine or false
        message.playerName = message.playerName or "NSPlayer"
        message.kills = message.kills or 0
        message.assists = message.assists or 0
        message.deaths = message.deaths or 0
        message.accuracy = message.accuracy or 0
        message.accuracyOnos = message.accuracyOnos or -1
        message.pdmg = message.pdmg or 0
        message.shieldDmg = message.shieldDmg or 0
        message.sdmg = message.sdmg or 0
        message.minutesBuilding = message.minutesBuilding or 0
        message.minutesPlaying = message.minutesPlaying or 0
        message.minutesComm = message.minutesComm or 0
        message.killstreak = message.killstreak or 0
        message.steamId = message.steamId or 1
        message.isRookie = message.isRookie or false
        message.hiveSkill = message.hiveSkill or -1

        local isMarine = message.isMarine

        -- save player stats into a map for later usage (e.g. hive skill graph)
        local teamNumber = isMarine and 1 or 2
        if not playerStatMap[teamNumber] then playerStatMap[teamNumber] = {} end
        playerStatMap[teamNumber][message.steamId] = message

        local minutes = math.floor(message.minutesBuilding)
        local seconds = (message.minutesBuilding % 1)*60

        local pMinutes = math.floor(message.minutesPlaying)
        local pSeconds = (message.minutesPlaying % 1)*60

        local cMinutes = math.floor(message.minutesComm)
        local cSeconds = (message.minutesComm % 1)*60

        local teamObj

        if isMarine then
            teamObj = self.team1UI
            totalKills1 = totalKills1 + message.kills
            totalAssists1 = totalAssists1 + message.assists
            totalDeaths1 = totalDeaths1 + message.deaths
            totalPdmg1 = totalPdmg1 + message.pdmg
            totalShieldDmg1 = totalShieldDmg1 + message.shieldDmg
            totalSdmg1 = totalSdmg1 + message.sdmg
            totalTimeBuilding1 = totalTimeBuilding1 + message.minutesBuilding
            totalTimePlaying1 = totalTimePlaying1 + message.minutesPlaying
            avgAccuracy1 = avgAccTable.marineAcc
            avgAccuracy1Onos = avgAccTable.marineOnosAcc
        else
            teamObj = self.team2UI
            totalKills2 = totalKills2 + message.kills
            totalAssists2 = totalAssists2 + message.assists
            totalDeaths2 = totalDeaths2 + message.deaths
            totalPdmg2 = totalPdmg2 + message.pdmg
            totalShieldDmg2 = totalShieldDmg2 + message.shieldDmg
            totalSdmg2 = totalSdmg2 + message.sdmg
            totalTimeBuilding2 = totalTimeBuilding2 + message.minutesBuilding
            totalTimePlaying2 = totalTimePlaying2 + message.minutesPlaying
            avgAccuracy2 = avgAccTable.alienAcc
        end

        local playerCount = #teamObj.playerRows
        local bgColor = isMarine and kMarinePlayerStatsOddColor or kAlienPlayerStatsOddColor
        local playerTextColor = kPlayerStatsTextColor
        if playerCount % 2 == 0 then
            bgColor = isMarine and kMarinePlayerStatsEvenColor or kAlienPlayerStatsEvenColor
        end

        -- Color our own row in a different color
        if message.steamId == Client.GetSteamId() then
            bgColor = kCurrentPlayerStatsColor
            playerTextColor = kCurrentPlayerStatsTextColor
        end

        table.insert(teamObj.playerRows, CreateScoreboardRow(teamObj.tableBackground, bgColor, playerTextColor, message.playerName, printNum(message.kills), printNum(message.assists), printNum(message.deaths), message.accuracyOnos == -1 and string.format("%s%%", printNum(message.accuracy)) or string.format("%s%% (%s%%)", printNum(message.accuracy), printNum(message.accuracyOnos)), printNum2(message.pdmg), printNum2(message.sdmg), string.format("%d:%02d", minutes, seconds), string.format("%d:%02d", pMinutes, pSeconds), message.minutesComm > 0 and string.format("%d:%02d", cMinutes, cSeconds) or nil, message.steamId, message.isRookie, message.hiveSkill), printNum2(message.shieldDmg))
        -- Store some of the original info so we can sort afterwards
        teamObj.playerRows[#teamObj.playerRows].originalOrder = playerCount
        teamObj.playerRows[#teamObj.playerRows].message = message

        if isMarine and message.minutesComm > team1CommTime then
            team1Comm = playerCount+1
            team1CommTime = message.minutesComm
        elseif not isMarine and message.minutesComm > team2CommTime then
            team2Comm = playerCount+1
            team2CommTime = message.minutesComm
        end
    end

    if team1Comm > 0 then
        if self.team1UI.playerRows[team1Comm].message then
            self.team1UI.playerRows[team1Comm].commIcon:SetTexture("ui/badges/commander_20.dds")
        end
    end

    if team2Comm > 0 then
        if self.team2UI.playerRows[team2Comm] then
            self.team2UI.playerRows[team2Comm].commIcon:SetTexture("ui/badges/commander_20.dds")
        end
    end

    local numPlayers1 = #self.team1UI.playerRows-1
    local numPlayers2 = #self.team2UI.playerRows-1
    self:SetPlayerCount(self.team1UI, numPlayers1)
    self:SetPlayerCount(self.team2UI, numPlayers2)
    miscDataTable.team1PlayerCount = numPlayers1
    miscDataTable.team2PlayerCount = numPlayers2
    self:SetTeamName(self.team1UI, miscDataTable.team1Name or "Frontiersmen")
    self:SetTeamName(self.team2UI, miscDataTable.team2Name or "Kharaa")
    local team1Result, team2Result = "DRAW", "DRAW"
    if miscDataTable.winningTeam > 0 then
        team1Result = miscDataTable.winningTeam == kMarineTeamType and "WINNER" or "LOSER"
        team2Result = miscDataTable.winningTeam == kAlienTeamType and "WINNER" or "LOSER"
    end
    self:SetGameResult(self.team1UI, team1Result)
    self:SetGameResult(self.team2UI, team2Result)

    local minutes1 = math.floor(totalTimeBuilding1)
    local seconds1 = (totalTimeBuilding1 % 1)*60
    totalTimeBuilding1 = totalTimeBuilding1/numPlayers1
    local minutes1Avg = math.floor(totalTimeBuilding1)
    local seconds1Avg = (totalTimeBuilding1 % 1)*60

    totalTimePlaying1 = totalTimePlaying1/numPlayers1
    local minutes1PAvg = math.floor(totalTimePlaying1)
    local seconds1PAvg = (totalTimePlaying1 % 1)*60

    local minutes2 = math.floor(totalTimeBuilding2)
    local seconds2 = (totalTimeBuilding2 % 1)*60
    totalTimeBuilding2 = totalTimeBuilding2/numPlayers2
    local minutes2Avg = math.floor(totalTimeBuilding2)
    local seconds2Avg = (totalTimeBuilding2 % 1)*60

    totalTimePlaying2 = totalTimePlaying2/numPlayers2
    local minutes2PAvg = math.floor(totalTimePlaying2)
    local seconds2PAvg = (totalTimePlaying2 % 1)*60

    -- When there's only one player in a team, the total and the average will be the same
    -- Don't even bother displaying this, it looks odd
    if numPlayers1 > 1 then
        table.insert(self.team1UI.playerRows, CreateScoreboardRow(self.team1UI.tableBackground, kHeaderRowColor, kMarineHeaderRowTextColor, "Total", printNum(totalKills1), printNum(totalAssists1), printNum(totalDeaths1), " ", printNum2(totalPdmg1), printNum2(totalSdmg1), string.format("%d:%02d", minutes1, seconds1), printNum2(totalShieldDmg1)))
        table.insert(self.team1UI.playerRows, CreateScoreboardRow(self.team1UI.tableBackground, kAverageRowColor, kAverageRowTextColor, "Average", printNum(totalKills1/numPlayers1), printNum(totalAssists1/numPlayers1), printNum(totalDeaths1/numPlayers1), avgAccuracy1Onos == -1 and string.format("%s%%", printNum(avgAccuracy1)) or string.format("%s%% (%s%%)", printNum(avgAccuracy1), printNum(avgAccuracy1Onos)), printNum2(totalPdmg1/numPlayers1), printNum2(totalSdmg1/numPlayers1), string.format("%d:%02d", minutes1Avg, seconds1Avg), string.format("%d:%02d", minutes1PAvg, seconds1PAvg), printNum2(totalShieldDmg1/numPlayers1)))
    end
    if numPlayers2 > 1 then
        table.insert(self.team2UI.playerRows, CreateScoreboardRow(self.team2UI.tableBackground, kHeaderRowColor, kAlienHeaderRowTextColor, "Total", printNum(totalKills2), printNum(totalAssists2), printNum(totalDeaths2), " ", printNum2(totalPdmg2), printNum2(totalSdmg2), string.format("%d:%02d", minutes2, seconds2), printNum2(totalShieldDmg2)))
        table.insert(self.team2UI.playerRows, CreateScoreboardRow(self.team2UI.tableBackground, kAverageRowColor, kAverageRowTextColor, "Average", printNum(totalKills2/numPlayers2), printNum(totalAssists2/numPlayers2), printNum(totalDeaths2/numPlayers2), string.format("%s%%", printNum(avgAccuracy2)), printNum2(totalPdmg2/numPlayers2), printNum2(totalSdmg2/numPlayers2), string.format("%d:%02d", minutes2Avg, seconds2Avg), string.format("%d:%02d", minutes2PAvg, seconds2PAvg), printNum2(totalShieldDmg2/numPlayers2)))
    end

    local gameInfo = GetGameInfoEntity()
    local teamStatsVisible = gameInfo.showEndStatsTeamBreakdown

    self.team1UI.background:SetIsVisible(teamStatsVisible)
    self.team2UI.background:SetIsVisible(teamStatsVisible)
    self.teamStatsTextShadow:SetIsVisible(teamStatsVisible)

    self.roundDate:SetText(string.format("Round date: %s", miscDataTable.roundDateString))
    self.gameLength:SetText(string.format("Game length: %s", miscDataTable.gameLength))
    self.serverName:SetText(string.format("Server name: %s", miscDataTable.serverName))
    self.mapName:SetText(string.format("Map: %s", miscDataTable.mapName))

    if #statusSummaryTable > 0 then
        table.sort(statusSummaryTable, function(a, b)
            if a.timeMinutes == b.timeMinutes then
                return a.className < b.className
            else
                return a.timeMinutes > b.timeMinutes
            end
        end)

        local bgColor = kStatusStatsColor
        local statCard = self:CreateGraphicHeader("Class time distribution", bgColor)
        statCard.rows = {}
        statCard.teamNumber = -2

        local totalTime = 0
        for _, row in ipairs(statusSummaryTable) do
            totalTime = totalTime + row.timeMinutes
        end

        for index, row in ipairs(statusSummaryTable) do
            bgColor = ConditionalValue(index % 2 == 0, kMarinePlayerStatsEvenColor, kMarinePlayerStatsOddColor)
            local minutes = math.floor(row.timeMinutes)
            local seconds = (row.timeMinutes % 1)*60
            local percentage = row.timeMinutes / totalTime * 100
            table.insert(statCard.rows, CreateHeaderRow(statCard.tableBackground, bgColor, Color(1,1,1,1), row.className, string.format("%d:%02d (%s%%)", minutes, seconds, printNum(percentage))))
        end
        table.insert(self.statsCards, statCard)
    end

    for _, card in ipairs(cardsTable) do
        local bgColor
        if card.teamNumber == 1 then
            bgColor = kMarineStatsColor
        elseif card.teamNumber == 2 then
            bgColor = kAlienStatsColor
        else
            bgColor = kCommanderStatsColor
        end
        local statCard = self:CreateGraphicHeader(card.text, bgColor, card.logoTexture, card.logoCoords, card.logoSizeX, card.logoSizeY)
        statCard.rows = {}
        statCard.teamNumber = card.teamNumber

        for index, row in ipairs(card.rows) do
            if card.teamNumber == 1 then
                bgColor = ConditionalValue(index % 2 == 0, kMarinePlayerStatsEvenColor, kMarinePlayerStatsOddColor)
            elseif card.teamNumber == 2 then
                bgColor = ConditionalValue(index % 2 == 0, kAlienPlayerStatsEvenColor, kAlienPlayerStatsOddColor)
            else
                bgColor = ConditionalValue(index % 2 == 0, kCommanderStatsEvenColor, kCommanderStatsOddColor)
            end

            table.insert(statCard.rows, CreateHeaderRow(statCard.tableBackground, bgColor, Color(1,1,1,1), row.title, row.value))
        end
        table.insert(self.statsCards, statCard)
    end

    if #techLogTable > 0 or #buildingSummaryTable > 0 then
        table.sort(techLogTable, function(a, b)
            if a.teamNumber == b.teamNumber then
                if a.finishedMinute == b.finishedMinute then
                    return a.name > b.name
                else
                    return a.finishedMinute < b.finishedMinute
                end
            else
                return a.teamNumber < b.teamNumber
            end
        end)

        table.sort(buildingSummaryTable, function(a, b)
            if a.teamNumber == b.teamNumber then
                if a.built == b. built then
                    if a.lost == b.lost then
                        return a.techId < b.techId
                    else
                        return a.lost > b.lost
                    end
                else
                    return a.built > b.built
                end
            else
                return a.teamNumber < b.teamNumber
            end
        end)

        local team1Name = miscDataTable.team1Name or "Frontiersmen"
        local team2Name = miscDataTable.team2Name or "Kharaa"

        self.techLogs[1] = {}
        self.techLogs[1].header = self:CreateTechLogHeader(1, team1Name)
        self.techLogs[1].rows = {}

        self.techLogs[2] = {}
        self.techLogs[2].header = self:CreateTechLogHeader(2, team2Name)
        self.techLogs[2].rows = {}

        -- Right now we only have marine comm stats so...
        if commanderStats then
            table.insert(self.techLogs[1].rows, CreateCommStatsRow(self.techLogs[1].header.tableBackground, kHeaderRowColor, kMarineHeaderRowTextColor, "Commander Stats", "Acc.", "Effic.", "Refilled", "Picked", "Expired"))

            local row = 1

            if commanderStats.medpackResUsed > 0 or commanderStats.medpackResExpired > 0 then
                table.insert(self.techLogs[1].rows, CreateCommStatsRow(self.techLogs[1].header.tableBackground, row % 2 == 0 and kMarinePlayerStatsEvenColor or kMarinePlayerStatsOddColor, kMarineHeaderRowTextColor, "Medpacks", printNum(commanderStats.medpackAccuracy) .. "%", printNum(commanderStats.medpackEfficiency) .. "%", commanderStats.medpackRefill, commanderStats.medpackResUsed, commanderStats.medpackResExpired, "ui/buildmenu.dds", GetTextureCoordinatesForIcon(kTechId.MedPack), 24, 24, kIconColors[1]))
                row = row + 1
            end

            if commanderStats.ammopackResUsed > 0 or commanderStats.ammopackResExpired > 0 then
                table.insert(self.techLogs[1].rows, CreateCommStatsRow(self.techLogs[1].header.tableBackground, row % 2 == 0 and kMarinePlayerStatsEvenColor or kMarinePlayerStatsOddColor, kMarineHeaderRowTextColor, "Ammopacks", "-", printNum(commanderStats.ammopackEfficiency) .. "%", commanderStats.ammopackRefill, commanderStats.ammopackResUsed, commanderStats.ammopackResExpired, "ui/buildmenu.dds", GetTextureCoordinatesForIcon(kTechId.AmmoPack), 24, 24, kIconColors[1]))
                row = row + 1
            end

            if commanderStats.catpackResUsed > 0 or commanderStats.catpackResExpired > 0 then
                table.insert(self.techLogs[1].rows, CreateCommStatsRow(self.techLogs[1].header.tableBackground, row % 2 == 0 and kMarinePlayerStatsEvenColor or kMarinePlayerStatsOddColor, kMarineHeaderRowTextColor, "Catpacks", "-", printNum(commanderStats.catpackEfficiency) .. "%", "-", commanderStats.catpackResUsed, commanderStats.catpackResExpired, "ui/buildmenu.dds", GetTextureCoordinatesForIcon(kTechId.CatPack), 24, 24, kIconColors[1]))
            end
        end

        if #buildingSummaryTable > 0 then
            if buildingSummaryTable[1].teamNumber == 1 then
                table.insert(self.techLogs[1].rows, CreateTechLogRow(self.techLogs[1].header.tableBackground, kHeaderRowColor, kMarineHeaderRowTextColor, "", "Tech", "Built", "Lost"))
            end

            if buildingSummaryTable[#buildingSummaryTable].teamNumber == 2 then
                table.insert(self.techLogs[2].rows, CreateTechLogRow(self.techLogs[2].header.tableBackground, kHeaderRowColor, kAlienHeaderRowTextColor, "", "Tech", "Built", "Lost"))
            end

            for index, buildingEntry in ipairs(buildingSummaryTable) do
                local isMarine = buildingEntry.teamNumber == 1
                local rowTextColor = isMarine and kMarineHeaderRowTextColor or kAlienHeaderRowTextColor
                local logoColor = kIconColors[buildingEntry.teamNumber]
                local bgColor = isMarine and kMarinePlayerStatsOddColor or kAlienPlayerStatsOddColor
                if index % 2 == 0 then
                    bgColor = isMarine and kMarinePlayerStatsEvenColor or kAlienPlayerStatsEvenColor
                end

                table.insert(self.techLogs[buildingEntry.teamNumber].rows, CreateTechLogRow(self.techLogs[buildingEntry.teamNumber].header.tableBackground, bgColor, rowTextColor, "", buildingEntry.name, buildingEntry.built, buildingEntry.lost, buildingEntry.iconTexture, buildingEntry.iconCoords, buildingEntry.iconSizeX, buildingEntry.iconSizeY, logoColor))
            end

        end

        if #techLogTable > 0 then
            if techLogTable[1].teamNumber == 1 then
                table.insert(self.techLogs[1].rows, CreateTechLogRow(self.techLogs[1].header.tableBackground, kHeaderRowColor, kMarineHeaderRowTextColor, "Time", "Tech", "RTs", "Res"))
            end

            if techLogTable[#techLogTable].teamNumber == 2 then
                table.insert(self.techLogs[2].rows, CreateTechLogRow(self.techLogs[2].header.tableBackground, kHeaderRowColor, kAlienHeaderRowTextColor, "Time", "Tech", "RTs", "Res"))
            end

            for index, techLogEntry in ipairs(techLogTable) do
                local isMarine = techLogEntry.teamNumber == 1
                local isLost = techLogEntry.destroyed == true
                local rowTextColor = isMarine and kMarineHeaderRowTextColor or kAlienHeaderRowTextColor
                local logoColor = kIconColors[techLogEntry.teamNumber]
                local bgColor = isLost and kLostTechOddColor or isMarine and kMarinePlayerStatsOddColor or kAlienPlayerStatsOddColor
                if index % 2 == 0 then
                    bgColor = isLost and kLostTechEvenColor or isMarine and kMarinePlayerStatsEvenColor or kAlienPlayerStatsEvenColor
                end

                table.insert(self.techLogs[techLogEntry.teamNumber].rows, CreateTechLogRow(self.techLogs[techLogEntry.teamNumber].header.tableBackground, bgColor, rowTextColor, techLogEntry.finishedTime, techLogEntry.name, techLogEntry.activeRTs, techLogEntry.teamRes, techLogEntry.iconTexture, techLogEntry.iconCoords, techLogEntry.iconSizeX, techLogEntry.iconSizeY, logoColor))
            end
        end
    end

    self.hiveSkillGraphs = {}
    if #hiveSkillGraphTable > 0 then
        table.sort(hiveSkillGraphTable, function(a, b)
            return a.gameMinute < b.gameMinute
        end)

        self.hiveSkillGraphs[1] = {}
        self.hiveSkillGraphs[2] = {}
        local hiveSkill = {0, 0}
        local lineOffset = {0, 0.5}
        local maxHiveSkill = 0
        local minHiveSkill = 0
        local avgTeam1Skill = 0
        local avgTeam2Skill = 0

        -- Keep track of players in each team to filter out duplicate hiveSkillGraphTable join/leave entries
        local players = {{}, {}}
        -- Counting set size is not easy so keep separate track
        local playerCount = {0, 0}

        -- Iterate over the graph data table but only add a new data point after advancing in time
        -- It's not uncommon for more than 1 player to change their team at any given point in time
        -- Specially at the very begining of a round
        -- The iteration limit is #hiveSkillGraphTable + 1 to add the last data point at the very end
        local graphTime = 0
        local roundEndTime = miscDataTable.gameLengthMinutes
        for i = 1, #hiveSkillGraphTable + 1 do
            local entry = hiveSkillGraphTable[i]
            local entryTime = entry and entry.gameMinute

            -- Add data point after advancing in time or reaching the end of the data table (entry == nil) / round
            local atEnd = entry == nil or entryTime >= roundEndTime
            if atEnd or graphTime ~= entry.gameMinute then
                local gameSeconds = graphTime * 60

                if gameSeconds == 0 then
                    -- Dont show graph going from 0 to start average hive skill
                    -- The total hive skill is larger than the min average hive skill.
                    minHiveSkill = math.min(hiveSkill[1], hiveSkill[2])
                else
                    table.insert(self.hiveSkillGraphs[1], Vector(gameSeconds, avgTeam1Skill + lineOffset[1], 0))
                    table.insert(self.hiveSkillGraphs[2], Vector(gameSeconds, avgTeam2Skill + lineOffset[2], 0))
                end

                avgTeam1Skill, avgTeam2Skill = hiveSkill[1] / math.max(playerCount[1], 1) , hiveSkill[2] / math.max(playerCount[2], 1)
                maxHiveSkill = math.max(maxHiveSkill, avgTeam1Skill, avgTeam2Skill)
                minHiveSkill = math.min(minHiveSkill, avgTeam1Skill, avgTeam2Skill)

                table.insert(self.hiveSkillGraphs[1], Vector(gameSeconds, avgTeam1Skill + lineOffset[1], 0))
                table.insert(self.hiveSkillGraphs[2], Vector(gameSeconds, avgTeam2Skill + lineOffset[2], 0))

                -- Reached the end, exit here
                if atEnd then
                    break
                end

                graphTime = entryTime
            end

            local id = entry.steamId
            local teamNumber = entry.teamNumber
            local isHuman = id > 0 -- don't track bots
            local playerEntry = isHuman and playerStatMap[teamNumber] and playerStatMap[teamNumber][id]
            local isPlaying = isHuman and players[teamNumber] and players[teamNumber][id]

            -- Filter out invalid data table entries
            if playerEntry and entry.joined ~= isPlaying then
                local playerSkill = math.max(playerEntry.hiveSkill, 0)
                players[teamNumber][id] = entry.joined
                playerCount[teamNumber] = playerCount[teamNumber] + ConditionalValue(entry.joined, 1, -1)
                hiveSkill[teamNumber] = hiveSkill[teamNumber] + ConditionalValue(entry.joined, playerSkill, -playerSkill)
            end
        end

        self.hiveSkillGraph:SetPoints(1, self.hiveSkillGraphs[1])
        self.hiveSkillGraph:SetPoints(2, self.hiveSkillGraphs[2])

        minHiveSkill = Round(math.max(minHiveSkill - 100, 0), -2)
        maxHiveSkill = Round(maxHiveSkill + 100, -2)
        self.hiveSkillGraph:SetYBounds(minHiveSkill, maxHiveSkill, true)

        local gameLength = miscDataTable.gameLengthMinutes * 60
        local xSpacing = GetXSpacing(gameLength)

        self.hiveSkillGraph:SetXBounds(0, gameLength)
        self.hiveSkillGraph:SetXGridSpacing(xSpacing)

        local diff = maxHiveSkill - minHiveSkill
        local yGridSpacing = diff <= 200 and 25 or diff <= 400 and 50 or diff <= 800 and 100 or Round(diff/8,-2)
        self.hiveSkillGraph:SetYGridSpacing(yGridSpacing)
    end

    self.rtGraphs = {}
    if #rtGraphTable > 0 then
        table.sort(rtGraphTable, function(a, b)
            return a.gameMinute < b.gameMinute
        end)

        self.rtGraphs[1] = {}
        self.rtGraphs[2] = {}
        local rtCount = {0, 0}
        local lineOffset = {0, 0.05}
        local maxRTs = 0

        for _, entry in ipairs(rtGraphTable) do
            local teamNumber = entry.teamNumber
            table.insert(self.rtGraphs[teamNumber], Vector(entry.gameMinute*60, rtCount[teamNumber]+lineOffset[teamNumber], 0))
            rtCount[teamNumber] = rtCount[teamNumber] + ConditionalValue(entry.destroyed, -1, 1)
            table.insert(self.rtGraphs[teamNumber], Vector(entry.gameMinute*60, rtCount[teamNumber]+lineOffset[teamNumber], 0))
            maxRTs = math.max(maxRTs,rtCount[teamNumber])
        end

        self.rtGraph:SetPoints(1, self.rtGraphs[1])
        self.rtGraph:SetPoints(2, self.rtGraphs[2])
        self.rtGraph:SetYBounds(0, maxRTs+1, true)
        local gameLength = miscDataTable.gameLengthMinutes*60
        local xSpacing = GetXSpacing(gameLength)

        self.rtGraph:SetXBounds(0, gameLength)
        self.rtGraph:SetXGridSpacing(xSpacing)

        self.builtRTsComp:SetValues(miscDataTable.marineRTsBuilt, miscDataTable.alienRTsBuilt)
        self.lostRTsComp:SetValues(miscDataTable.marineRTsLost, miscDataTable.alienRTsLost)

        if miscDataTable.marineRTsBuilt > 0 then
            self.builtRTsComp:SetLeftText("(" .. printNum(miscDataTable.marineRTsBuilt/miscDataTable.gameLengthMinutes) .. "/min)  " .. tostring(miscDataTable.marineRTsBuilt))
        end
        if miscDataTable.alienRTsBuilt > 0 then
            self.builtRTsComp:SetRightText(tostring(miscDataTable.alienRTsBuilt) .. "  (" .. printNum(miscDataTable.alienRTsBuilt/miscDataTable.gameLengthMinutes) .. "/min)")
        end
        if miscDataTable.marineRTsLost > 0 then
            self.lostRTsComp:SetLeftText("(" .. printNum(miscDataTable.marineRTsLost/miscDataTable.gameLengthMinutes) .. "/min)  " .. tostring(miscDataTable.marineRTsLost))
        end
        if miscDataTable.alienRTsLost > 0 then
            self.lostRTsComp:SetRightText(tostring(miscDataTable.alienRTsLost) .. "  (" .. printNum(miscDataTable.alienRTsLost/miscDataTable.gameLengthMinutes) .. "/min)")
        end
    end

    self.killGraphs = {}
    if #killGraphTable > 0 then
        table.sort(killGraphTable, function(a, b)
            return a.gameMinute < b.gameMinute
        end)

        self.killGraphs[1] = {}
        self.killGraphs[2] = {}
        local teamKills = {0, 0}
        local lineOffsets = {0, 0.05}

        for _, entry in ipairs(killGraphTable) do
            local teamNumber = entry.teamNumber
            table.insert(self.killGraphs[teamNumber], Vector(entry.gameMinute*60, teamKills[teamNumber]+lineOffsets[teamNumber], 0))
            teamKills[teamNumber] = teamKills[teamNumber] + 1
            table.insert(self.killGraphs[teamNumber], Vector(entry.gameMinute*60, teamKills[teamNumber]+lineOffsets[teamNumber], 0))
        end

        self.killGraph:SetPoints(1, self.killGraphs[1])
        self.killGraph:SetPoints(2, self.killGraphs[2])
        local yElems = math.max(teamKills[1], teamKills[2])+1
        self.killGraph:SetYBounds(0, yElems, true)
        local gameLength = miscDataTable.gameLengthMinutes*60
        local xSpacing = GetXSpacing(gameLength)
        local ySpacing = GetYSpacing(yElems)

        self.killGraph:SetXBounds(0, gameLength)
        self.killGraph:SetXGridSpacing(xSpacing)
        self.killGraph:SetYGridSpacing(ySpacing)

        self.killComparison:SetValues(teamKills[1], teamKills[2])

        if teamKills[1] > 0 then
            self.killComparison:SetLeftText("(" .. printNum(teamKills[1]/miscDataTable.gameLengthMinutes) .. "/min)  " .. tostring(teamKills[1]))
        end
        if teamKills[2] > 0 then
            self.killComparison:SetRightText(tostring(teamKills[2]) .. "  (" .. printNum(teamKills[2]/miscDataTable.gameLengthMinutes) .. "/min)")
        end
    end

    self:RepositionStats()

    pcall(self.SaveLastRoundStats, self)

    finalStatsTable = {}
    playerStatMap = {}
    avgAccTable = {}
    miscDataTable = {}
    cardsTable = {}
    hiveSkillGraphTable = {}
    rtGraphTable = {}
    commanderStats = nil
    killGraphTable = {}
    buildingSummaryTable = {}
    statusSummaryTable = {}
    techLogTable = {}
end

Client.HookNetworkMessage("EndStatsWeapon", CHUDSetWeaponStats)