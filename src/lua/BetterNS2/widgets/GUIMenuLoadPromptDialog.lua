Script.Load("lua/menu2/popup/GUIMenuPopupDialog.lua")
Script.Load("lua/menu2/widgets/GUIMenuDropdownWidget.lua")

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
    RequireType({"string", "nil"}, params.filename, "params.filename", errorDepth)

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
                label = "Filename",
                choices = self:GetChoices(),
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

    if params.filename then
        self.filename:SetValue(params.filename)
    end

    -- Convenience.  Enable editing on the filename field so user doesn't have to click it.
    self.filename:SetEditing(true)

end

function GUIMenuLoadPromptDialog:GetLoadFilename()
    return self.filename
end

function GUIMenuLoadPromptDialog:GetChoices()
    -- TODO: Lookup filenames
    return {
        {value = "file1path", displayString = "filename1"},
        {value = "file2path", displayString = "filename2"},
        {value = "file3path", displayString = "filename3"},
        {value = "file4path", displayString = "filename4"},
        {value = "file5path", displayString = "filename5"},
        {value = "file6path", displayString = "filename6"},
    }
end
