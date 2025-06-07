RegisterNetEvent("Spectrum:Staff:Add", function(type, item, count)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if type == "clean_cash" then
            AddCash(source, true, true, count)
        elseif type == "dirty_cash" then
            AddCash(source, true, false, count)
        elseif type == "bank" then
            AddCash(source, false, true, count)
        elseif type == "item" then
            AddItem(source, item, count)
        elseif type == "weapon" then
            AddWeapon(source, CreateWeapon(item), 0)
        elseif type == "ammo" then
            AddAmmo(source, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Remove", function(type, item, count)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if type == "clean_cash" then
            RemoveCash(source, true, true, count)
        elseif type == "dirty_cash" then
            RemoveCash(source, true, false, count)
        elseif type == "bank" then
            RemoveCash(source, false, true, count)
        elseif type == "item" then
            RemoveItem(source, item, count)
        elseif type == "weapon" then
            RemoveWeapon(source, item)
        elseif type == "ammo" then
            RemoveAmmo(source, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Smite", function(target)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 0, Spectrum.libs.Tokens.CreateToken(source))
        else
            Notification(source, "Please revive a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Revive", function(target)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 1, Spectrum.libs.Tokens.CreateToken(source))
        else
            Notification(source, "Please revive a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:DeleteVehicle", function()
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        local v = GetClosestVehicle(source)
        if v then
            DeleteEntity(v)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Teleport", function(t, target)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if t == 1 then
            TriggerClientEvent("Spectrum:Warp", source, Spectrum.libs.Tokens.CreateToken(source),
                GetEntityCoords(GetPlayerPed(target)))
        elseif t == 2 then
            TriggerClientEvent("Spectrum:Warp", target, Spectrum.libs.Tokens.CreateToken(target),
                GetEntityCoords(GetPlayerPed(source)))
        end
    end
end)

RegisterCommand("dv", function(source)
    source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        local v = GetClosestVehicle(source)
        if v then
            DeleteEntity(v)
        end
    else
        -- TODO: add logging
    end
end, false)
