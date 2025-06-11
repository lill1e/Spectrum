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

function VehicleData(handle)
    SetVehicleModKit(handle, 0)
    local state = {
        Color = {
            Primary = table.pack(GetVehicleCustomPrimaryColour(handle)),
            Secondary = table.pack(GetVehicleCustomSecondaryColour(handle))
        },
        Tint = GetVehicleWindowTint(handle),
        Dirt = GetVehicleDirtLevel(handle),
        Health = GetVehicleEngineHealth(handle),
        Plate = GetVehicleNumberPlateTextIndex(handle),
        Mods = {}
    }
    if state.Tint == -1 then
        SetVehicleWindowTint(handle, 0)
        state.Tint = GetVehicleWindowTint(handle)
    end
    for mod, _ in pairs(Config.Vehicles.Mods.Mods) do
        state.Mods[mod] = GetVehicleMod(handle, mod)
    end
    return state
end

function ApplyVehicleData(handle, state)
    SetVehicleModKit(handle, 0)
    if state and state.Color and state.Dirt and state.Tint and state.Health and state.Plate and state.Mods then
        SetVehicleDirtLevel(handle, state.Dirt)
        SetVehicleCustomPrimaryColour(handle, table.unpack(state.Color.Primary))
        SetVehicleCustomSecondaryColour(handle, table.unpack(state.Color.Secondary))
        SetVehicleWindowTint(handle, state.Tint)
        SetVehicleEngineHealth(handle, state.Health * 10 / 10)
        SetVehicleNumberPlateTextIndex(handle, state.Plate)
        for mod, value in pairs(state.Mods) do
            SetVehicleMod(handle, tonumber(mod), value, false)
        end
    end
end

function GetClosestPlayer()
    local me = PlayerId()
    local meCoords = GetEntityCoords(PlayerPedId())
    local target = nil
    local dist = nil
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= me then
            local playerCoords = GetEntityCoords(GetPlayerPed(player))
            if (dist == nil and (#(meCoords - playerCoords) <= 3)) or #(meCoords - playerCoords) < dist then
                target = player
                dist = #(meCoords - playerCoords)
            end
        end
    end
    return target and GetPlayerServerId(target) or target
end
