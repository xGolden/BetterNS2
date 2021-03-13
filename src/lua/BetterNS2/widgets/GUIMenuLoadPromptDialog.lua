Script.Load("lua/menu2/popup/GUIMenuPopupDialog.lua")
Script.Load("lua/menu2/widgets/GUIMenuDropdownWidget.lua")
Script.Load("lua/menu/FancyUtilities.lua")

---@class GUIMenuLoadPromptDialog : GUIMenuPopupDialog
class "GUIMenuLoadPromptDialog" (GUIMenuPopupDialog)

-- Spacing between edge of inner box and the visible contents.
local kInnerPopupContentsPadding = Vector(72, 48, 0)

-- Spacing between contents of dialog (when there is more than one type of content).
local kContentsSpacing = 16

GUIMenuLoadPromptDialog:AddCompositeClassProperty("Message", "message", "Text")

local function UpdateScrollPaneHeight(self)
    self.scrollPane:SetPaneHeight(self.message:GetSize().y + kInnerPopupContentsPadding.y * 2)
end

local function UpdateMessageParagraphSize(self)
    self.message:SetParagraphSize(math.max(100, self.scrollPane:GetSize().x - kInnerPopupContentsPadding.x * 2), -1)
end

local function UpdateScrollPaneWidth(self)
    self.scrollPane:SetWidth(math.max(100, self.contentsHolder:GetSize().x - kInnerPopupContentsPadding.x*2))
end

local function UpdateScrollPaneViewHeight(self)
    self.scrollPane:SetHeight(self.contentsHolder:GetSize().y - self.layout:GetSpacing() - self.layout:GetFrontPadding() - self.layout:GetBackPadding() - self.filename:GetSize().y)
end

function GUIMenuLoadPromptDialog:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    RequireType({"string", "nil"}, params.message, "params.message", errorDepth)
    RequireType("table", params.buttonConfig, "params.buttonConfig", errorDepth)
    RequireType({"string", "nil"}, params.filepath, "params.filepath", errorDepth)

    self:ConvertNS2PlusFormatToBetterNS2(params.oldFilepath, params.filepath)

    GUIMenuPopupDialog.Initialize(self, params, errorDepth)

    self.layout = CreateGUIObject("layout", GUIListLayout, self.contentsHolder,
            {
                orientation = "vertical",
                spacing = kContentsSpacing,
                frontPadding = kInnerPopupContentsPadding.y,
                backPadding = kInnerPopupContentsPadding.y,
            })
    self.layout:SetX(kInnerPopupContentsPadding.x)

    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self.layout,
            {
                horizontalScrollBarEnabled = false,
            })

    -- Make width of scroll pane match width of contents holder.
    self:HookEvent(self.contentsHolder, "OnSizeChanged", UpdateScrollPaneWidth)
    UpdateScrollPaneWidth(self)

    self.message = CreateGUIObject("message", GUIParagraph, self.scrollPane,
            {
                text = params.message or "Popup dialog message goes here!",
                fontFamily = "Agency",
                fontSize = 55,
                color = MenuStyle.kOptionHeadingColor,
            })

    -- Make height of scroll pane equal height of paragraph text.
    self:HookEvent(self.message, "OnSizeChanged", UpdateScrollPaneHeight)
    UpdateScrollPaneHeight(self)

    -- Make width of paragraph-size resize with the popup.
    self:HookEvent(self.scrollPane, "OnSizeChanged", UpdateMessageParagraphSize)
    UpdateMessageParagraphSize(self)

    self.filename = CreateGUIObject("filename", GUIMenuDropdownWidget, self.layout,
            {
                label = "AV Name",
                choices = self:GetChoices(params.filepath),
            })
    self.filename:AlignTop()

    -- Resize the scroll pane's display height to make room for the filename at the bottom.
    self:HookEvent(self.filename, "OnSizeChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnFrontPaddingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnBackPaddingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnSpacingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.contentsHolder, "OnSizeChanged", UpdateScrollPaneViewHeight)
    UpdateScrollPaneViewHeight(self)
    UpdateScrollPaneHeight(self)
end

function GUIMenuLoadPromptDialog:ConvertNS2PlusFormatToBetterNS2(oldFilePath, newFilePath)
    local ns2PlusFiles = {}
    Shared.GetMatchingFileNames(oldFilePath..'*.json', false, ns2PlusFiles)

    local existingAlienvisions = self:GetExistingBetterNS2Alienvisions(newFilePath)

    for _, ns2PlusFilePath in ipairs(ns2PlusFiles) do
        local settingsFile = io.open('config://'..ns2PlusFilePath, "r")
        if settingsFile then
            local ns2PlusSettings = settingsFile:read("*all")

            ns2PlusSettings = string.gsub(ns2PlusSettings, "CHUD", "BETTERNS2")
            ns2PlusSettings = string.gsub(ns2PlusSettings, "BETTERNS2_AV\":5", "BETTERNS2_AV\":\"shaders/Cr4zyAV.screenfx\"")

            local betterNs2Settings, _, errStr = json.decode(ns2PlusSettings)

            if not errStr then
                local avFilename = betterNs2Settings.details['av_name']
                if not table.contains(existingAlienvisions, avFilename) then
                    betterNs2Settings.details['date_migrated'] = FormatDateTimeString(Shared.GetSystemTime())
                    local newAlienvisionFile = io.open(newFilePath..avFilename..'.json', "w+")
                    if newAlienvisionFile then
                        newAlienvisionFile:write(json.encode(betterNs2Settings, { indent = true }))
                    end
                    newAlienvisionFile:close()
                end
            else
                Print("Error converting file "..ns2PlusFilePath..': '..errStr)
            end
        else
            settingsFile:close()
        end
    end
end

function GUIMenuLoadPromptDialog:GetExistingBetterNS2Alienvisions(filepath)
    local existingAlienvisionFiles = {}
    local existingAlienvisionFilenames = {}
    Shared.GetMatchingFileNames(filepath..'*.json', false, existingAlienvisionFiles)

    for _, existingFile in ipairs(existingAlienvisionFiles) do
        table.insert(existingAlienvisionFilenames, Fancy_SplitStringIntoTable(Fancy_SplitStringIntoTable(existingFile, '.json')[1], '/')[3])
    end

    return existingAlienvisionFilenames
end

function GUIMenuLoadPromptDialog:GetLoadFilename()
    return self.filename
end

function GUIMenuLoadPromptDialog:GetChoices(filepath)
    local filenames = {}
    local choices = {}

    Shared.GetMatchingFileNames(filepath..'*.json', false, filenames)

    for _, filename in ipairs(filenames) do
        local displayName = Fancy_SplitStringIntoTable(Fancy_SplitStringIntoTable(filename, '.json')[1], '/')[3]
        table.insert(choices, {value = 'config://'..filename, displayString = displayName})
    end

    return choices
end
