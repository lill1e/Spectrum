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
