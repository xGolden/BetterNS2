Script.Load('lua/BetterNS2/widgets/GUIMenuSavePromptDialog.lua')
Script.Load('lua/BetterNS2/widgets/GUIMenuLoadPromptDialog.lua')
Script.Load('lua/NS2Utility.lua')

local alienvisionFilePath = "config://BetterNS2/Alienvision"

local function GetAlienvisionSettings()
    -- TODO: Get all of the alienvision options in a writeable type/format -- make sure to ignore any "button" option types
    return {}
end

function SaveAlienVision(filename)
    Print('enter SaveAlienVision: %s', filename)

    assert(filename ~= '', "Attempted to save alienvision to filename as an empty string")
    local saveAlienvisionFilePath = string.format("%s/%s.json",alienvisionFilePath, filename)
    local alienvisionFile = io.open(saveAlienvisionFilePath, "w+")
    if alienvisionFile then
        local AlienvisionOptionsJson = {
            details = {
                av_name = filename,
                date_created = FormatDateTimeString(Shared.GetSystemTime())
            },
            settings = GetAlienvisionSettings()
        }
        alienvisionFile:write(json.encode(AlienvisionOptionsJson, { indent = true }))
        Print("Saved alienvision options to %s", saveAlienvisionFilePath)
        alienvisionFile:close()
    end
end

function HandleSaveAlienVision()
    local filename = ''

    local saveCallback = function(popup2)
        Print('enter saveCallback')
        popup2:Close()
        SaveAlienVision(filename)
    end

    local popup = CreateGUIObject("popup", GUIMenuSavePromptDialog, nil,
            {
                title = "Save Alienvision",
                filename = filename,
                message = "Enter filename",
                buttonConfig = {
                    {
                        name = "save",
                        params = {
                            label = "Save"
                        },
                        callback = saveCallback,
                    },
                    GUIMenuPopupDialog.CancelButton
                }
            })

    local filenameEntry = popup:GetSaveFilename()
    assert(filenameEntry)

    popup:HookEvent(filenameEntry, "OnKey", function(popup2, key, down)
        if (key == InputKey.Return or key == InputKey.NumPadEnter) and down then
            saveCallback(popup2)
        end
    end)

    popup:HookEvent(filenameEntry, "OnValueChanged",
            function(popup2, value)
                filename = value
            end)
end

function LoadAlienVision(filename)
    Print('enter LoadAlienVision: %s', filename)
end

function HandleLoadAlienVision()
    local filename = ''

    local loadCallback = function(popup2)
        popup2:Close()
        LoadAlienVision(filename)
    end

    local popup = CreateGUIObject("popup", GUIMenuLoadPromptDialog, nil,
            {
                title = "Load Alienvision",
                filename = filename,
                message = "Select file to load",
                buttonConfig = {
                    {
                        name = "load",
                        params = {
                            label = "Load"
                        },
                        callback = loadCallback,
                    },
                    GUIMenuPopupDialog.CancelButton
                }
            })

    local filenameSelected = popup:GetLoadFilename()
    assert(filenameSelected)

    popup:HookEvent(filenameSelected, "OnKey", function(popup2, key, down)
        if (key == InputKey.Return or key == InputKey.NumPadEnter) and down then
            loadCallback(popup2)
        end
    end)

    popup:HookEvent(filenameSelected, "OnValueChanged",
        function(popup2, value)
            filename = value
        end)
end