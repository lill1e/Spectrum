RegisterNetEvent("Spectrum:Garage:Grant", function(target, vehicle, vehicleClass)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Admin then
        local plate = RandomPlate()
        local query = exports["pgcfx"]:insert("vehicles", { "id", "owner", "vehicle" },
            { plate, Spectrum.players[target].id, vehicle })
        if query > 0 then
            TriggerClientEvent("Spectrum:Vehicles:Add", target, vehicle, plate)
        end
    end
end)

RegisterNetEvent("Spectrum:Garage:Revoke", function(target, plate)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Admin then
        local query = exports["pgcfx"]:delete("vehicles", "id = ? AND owner = ?", { plate, Spectrum.players[target].id })
        if query > 0 then
            local paddedPlate = PadPlate(plate)
            for _, entity in ipairs(GetAllVehicles()) do
                if GetEntityType(entity) == 2 and GetVehicleNumberPlateText(entity) == paddedPlate then
                    DeleteEntity(entity)
                end
            end
            TriggerClientEvent("Spectrum:Vehicles:Remove", target, plate)
        else
            Notification(source, "~b~" .. plate .. " ~s~does not exist for the provided player")
        end
    end
end)
