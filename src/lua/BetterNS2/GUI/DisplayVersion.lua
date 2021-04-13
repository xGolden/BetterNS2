kBetterNS2Version = 6

local originalFeedbackInit = GUIFeedback.Initialize
function  GUIFeedback:Initialize()
    originalFeedbackInit(self)

    self.buildText:SetText(self.buildText:GetText() .. " (BetterNS2 v"  .. kBetterNS2Version .. ")")
end
