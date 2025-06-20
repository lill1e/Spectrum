function GetSteamHex(source)
    return GetPlayerIdentifierByType(source, "steam") or (Spectrum.debug and "steam:debug" or nil)
end

function GetAllIdentifiers(source)
    local identifiers = {}
    for i = 1, GetNumPlayerIdentifiers(source) do
        table.insert(identifiers, GetPlayerIdentifier(source, i))
    end
    return identifiers
end

function Notification(source, text)
    TriggerClientEvent("Spectrum:Notification", source, text)
end

function GetClosestVehicle(source)
    if GetVehiclePedIsIn(GetPlayerPed(source), false) ~= 0 then
        return GetVehiclePedIsIn(GetPlayerPed(source), false)
    end
    local entPool = GetAllVehicles()
    local selfCoords = GetEntityCoords(GetPlayerPed(source))
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
    else
        return nil
    end
end
