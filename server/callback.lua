while not Spectrum.loaded do
    Wait(0)
end

RegisterNetEvent("Spectrum:Callback", function(type, ...)
    local source = tostring(source)

    local n = Spectrum.libs.callbackCounts[source] or 0
    Spectrum.libs.callbackCounts[source] = n + 1

    if Spectrum.libs.callbackFunctions[type] == nil then
        -- TODO: violation (this should not happen)
        return
    end
    Spectrum.libs.callbacks[n] = "waiting"
    Citizen.CreateThread(function()
        while Spectrum.libs.callbacks[n] == "waiting" do
            Wait(0)
        end
        TriggerClientEvent("Spectrum:Callback", source, n, Spectrum.libs.callbacks[n])
    end)
    Spectrum.libs.callbacks[n] = Spectrum.libs.callbackFunctions[type](source, ...)
end)

Spectrum.libs.callbackFunctions.verifyToken = function(source, token)
    if token == nil then
        -- TODO: arity mismatch (this should not happen)
    end
    local isMatch = Spectrum.libs.tokens[token] == source
    if Spectrum.libs.tokens[token] == false then
        -- TODO: violation (this should not happen)
    end
    return isMatch
end

Spectrum.libs.callbackFunctions.verifyVehicle = function(source, vehicle, plate)
    local vehicleQuery = exports["pgcfx"]:selectOne("vehicles", {},
        "id = ? AND vehicle = ? AND owner = ? AND active = false",
        { plate, vehicle, Spectrum.players[source].id })
    if vehicleQuery then
        exports["pgcfx"]:update("vehicles", { "active" }, { "true" }, "id = ?", { plate })
    end
    return vehicleQuery ~= nil
end

Spectrum.libs.callbackFunctions.verifyVehiclePlate = function(source, plate, garage)
    local query = exports["pgcfx"]:update("vehicles", { "active", "garage" }, { "false", garage }, "id = ? AND owner = ?",
        { plate, Spectrum.players[source].id })
    return query > 0
end
