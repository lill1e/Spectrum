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

function GetClosest(pool)
    if pool == "CVehicle" and IsPedInAnyVehicle(PlayerPedId(), true) then
        return GetVehiclePedIsIn(PlayerPedId(), false)
    end
    local entPool = GetGamePool(pool)
    local selfCoords = GetEntityCoords(PlayerPedId())
    local minDist = nil
    local minHandle = nil
    for _, handle in ipairs(entPool) do
        local entCoords = GetEntityCoords(handle)
        local d = #(selfCoords - entCoords)
        if minDist == nil or d < minDist then
            minDist = d
            minHandle = handle
        end
    end
    if minHandle and minDist <= 3 then
        return minHandle
    end
end
