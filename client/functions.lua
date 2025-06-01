function HelpText(text, beep)
    AddTextEntry("HELPTEXT", text)
    BeginTextCommandDisplayHelp("HELPTEXT")
    EndTextCommandDisplayHelp(0, false, beep == nil and true or beep, -1)
end

function Notification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

function Input(text)
    AddTextEntry("input", text)
    DisplayOnscreenKeyboard(1, "input", "", "", "", "", "", 128)
    while UpdateOnscreenKeyboard() == 0 do Wait(0) end

    local input = UpdateOnscreenKeyboard()

    return GetOnscreenKeyboardResult()
end
