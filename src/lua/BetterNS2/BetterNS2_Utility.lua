function isCompModLoaded()
    return g_compModRevision
end

function isShineLoaded()
    return Shine
end

function BNS2WrapTextIntoTable(str, limit, indent, indent1)
    limit = limit or 72
    indent = indent or ""
    indent1 = indent1 or indent

    local here = 1 - #indent1

    str = indent1..str:gsub("(%s+)()(%S+)()",
        function(_, st, word, fi)
            if fi-here > limit then
                here = st - #indent
                return "\n"..indent..word
            end
        end)

    return StringSplit(str, "\n")
end

if Server then
    function SendBNS2Message(message)
        if message then
            local messageList = BNS2WrapTextIntoTable(message, kMaxChatLength)
            for m = 1, #messageList do
                Server.SendNetworkMessage("Chat", BuildChatMessage(false, "[BNS2]", -1, kTeamReadyRoom, kNeutralTeamType, messageList[m]), true)
                Shared.Message("Chat All - [BNS2]: " .. messageList[m])
                Server.AddChatToHistory(messageList[m], "[BNS2]", 0, kTeamReadyRoom, false)
            end

        end

    end

    function BetterNS2ServerAdminPrint(client, message)
        if client then
            local messageList = BNS2WrapTextIntoTable(message, kMaxChatLength)

            for m = 1, #messageList do
                Server.SendNetworkMessage(client:GetControllingPlayer(), "ServerAdminPrint",
                        { message = messageList[m] }, true)
            end
        end
    end
end
