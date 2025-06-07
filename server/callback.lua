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

Spectrum.libs.callbackFunctions.restoreVehicle = function(source, plate)
    if Spectrum.players[source].staff > 0 then
        local query = exports["pgcfx"]:update("vehicles", { "active" }, { "false" }, "id = ?",
            { plate })
        if query > 0 then
            local paddedPlate = PadPlate(plate)
            for _, entity in ipairs(GetAllVehicles()) do
                if GetEntityType(entity) == 2 and GetVehicleNumberPlateText(entity) == paddedPlate then
                    DeleteEntity(entity)
                end
            end
            local identifierQuery = exports["pgcfx"]:selectOne("vehicles", { "owner" }, "id = ?", { plate })
            local identifier = identifierQuery.owner
            for target, player in pairs(Spectrum.players) do
                if player.id == identifier then
                    TriggerClientEvent("Spectrum:Garage:Reset", target, plate)
                end
            end
            return true
        else
            return false
        end
    else
        return false
        -- TODO: add logging
    end
end

Spectrum.libs.callbackFunctions.alterPlate = function(source, target, plate, newPlate)
    target = tostring(target)
    if Spectrum.players[source].staff > 0 then
        if Spectrum.players[target] then
            if newPlate == "" or Whitespace(newPlate) then
                newPlate = RandomPlate()
            end
            local query = exports["pgcfx"]:update("vehicles", { "id" }, { newPlate }, "id = ? AND owner = ?",
                { plate, Spectrum.players[target].id })
            if query > 0 then
                TriggerClientEvent("Spectrum:Vehicles:Reassign", target, plate, newPlate)
                return newPlate
            end
        else
            return nil
        end
    else
        -- TODO: add logging
        return nil
    end
end

Spectrum.libs.callbackFunctions.auditDetails = function(source, target, type)
    target = tostring(target)
    if Spectrum.players[source].staff > 0 then
        if Spectrum.players[target] then
            if type == 0 then
                return Spectrum.players[target].identifiers
            elseif type == 1 then
                local query = exports["pgcfx"]:select("vehicles", {}, "owner = ?",
                    { Spectrum.players[target].id })
                local vehicles = {}
                for _, vehicle in pairs(query) do
                    table.insert(vehicles, {
                        plate = vehicle.id,
                        vehicle = vehicle.vehicle,
                        active = vehicle.active,
                        garage = vehicle.garage
                    })
                end
                return vehicles
            end
            -- type = 2, inventory
            -- type = 3, weapons
            -- type = 4, ammo
        else
            return nil
        end
    else
        -- TODO: add logging
        return nil
    end
end

Spectrum.libs.callbackFunctions.declareAmmo = function(source, token, ammoType, ammo)
    if token == nil then
        -- TODO: arity mismatch (this should not happen)
    end
    local isMatch = Spectrum.libs.tokens[token] == source
    if Spectrum.libs.tokens[token] == false then
        -- TODO: violation (this should not happen)
    end
    if isMatch then
        Spectrum.players[source].ammo[ammoType] = Spectrum.players[source].ammo[ammoType] + ammo
    end
    return isMatch
end
