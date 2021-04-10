function GUIInsight_Logout:SendKeyEvent(key, down)
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
        self.mousePressed = down

        -- Check if the button was pressed.
        if not self.mousePressed then
            local mouseX, mouseY = Client.GetCursorPosScreen()
            local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
            local player = Client.GetLocalPlayer()

            if containsPoint and player:isa("Spectator") then
                Shared.ConsoleCommand("ReadyRoom")
                return true
            end
        end
    end
    return false
end
