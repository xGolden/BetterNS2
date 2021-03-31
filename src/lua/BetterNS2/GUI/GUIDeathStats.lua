local statsTable = debug.getupvaluex(GUIDeathStats.SetStats, "statsTable", false)

function GUIDeathStats:SetStats()

    if statsTable ~= nil then
        self.titleBackground:SetColor(Color(statsTable.color.r, statsTable.color.g, statsTable.color.b, 0))
        local color = self.titleBackground:GetColor()
        color.a = 1
        self.titleBackgroundLeft:SetColor(color)
        self.titleBackgroundRight:SetColor(color)
    end

    self:ResetTableBackground()

    if statsTable ~= nil then
        self:AddRow("Last life accuracy", printNum(statsTable.lastAcc) .. "%")
        if statsTable.lastAccOnos > -1 then
            self:AddRow("Without Onos hits", printNum(statsTable.lastAccOnos) .. "%")
        end
        self:AddRow("Player damage", printNum(statsTable.pdmg))
        self:AddRow("Shield damage", printNum(statsTable.shieldDmg))
        self:AddRow("Structure damage", printNum(statsTable.sdmg))
        if statsTable.kills > 0 then
            self:AddRow("Kills", printNum(statsTable.kills))
        end
        self:AddRow()
        self:AddRow("Current accuracy", printNum(statsTable.currentAcc) .. "%")
        if statsTable.currentAccOnos > -1 then
            self:AddRow("Without Onos hits", printNum(statsTable.currentAccOnos) .. "%")
        end
    end

end