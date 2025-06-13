RegisterNetEvent("Spectrum:Staff:Add", function(type, item, count, target)
    local source = tostring(source)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Developer then
        if type == "clean_cash" then
            AddCash(player, true, true, count)
        elseif type == "dirty_cash" then
            AddCash(player, true, false, count)
        elseif type == "bank" then
            AddCash(player, false, true, count)
        elseif type == "item" then
            if HasItemSpace(player, item, count) then
                AddItem(player, item, count)
            end
        elseif type == "weapon" then
            if not HasWeapon(player, item) then
                AddWeapon(player, CreateWeapon(item), 0)
            end
        elseif type == "ammo" then
            AddAmmo(player, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Remove", function(type, item, count, target)
    local source = tostring(source)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Developer then
        if type == "clean_cash" then
            RemoveCash(player, true, true, count)
        elseif type == "dirty_cash" then
            RemoveCash(player, true, false, count)
        elseif type == "bank" then
            RemoveCash(player, false, true, count)
        elseif type == "item" then
            RemoveItem(player, item, count)
        elseif type == "weapon" then
            RemoveWeapon(player, item)
        elseif type == "ammo" then
            RemoveAmmo(player, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Smite", function(target)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 0, Spectrum.libs.Tokens.CreateToken(target))
        else
            Notification(source, "Please smite a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Revive", function(target, maxHealth)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 1, Spectrum.libs.Tokens.CreateToken(target))
            Spectrum.players[target].dead = false
            Spectrum.players[target].health = Spectrum.players[target].skin.Sex == 1 and 200 or 175
            Spectrum.players[target].armor = 0
        else
            Notification(source, "Please revive a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:DeleteVehicle", function()
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
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
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        if t == 1 then
            TriggerClientEvent("Spectrum:Warp", source, Spectrum.libs.Tokens.CreateToken(source),
                GetEntityCoords(GetPlayerPed(target)))
        elseif t == 2 then
            TriggerClientEvent("Spectrum:Warp", target, Spectrum.libs.Tokens.CreateToken(target),
                GetEntityCoords(GetPlayerPed(source)))
        end
    end
end)

RegisterNetEvent("Spectrum:Staff:TeleportCoords", function(coords, waypoint)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        TriggerClientEvent("Spectrum:Warp", source, Spectrum.libs.Tokens.CreateToken(source), coords, waypoint)
    else
        -- TODO: add logging
    end
end)

RegisterCommand("dv", function(source)
    source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        local v = GetClosestVehicle(source)
        if v then
            DeleteEntity(v)
        end
    else
        -- TODO: add logging
    end
end, false)
