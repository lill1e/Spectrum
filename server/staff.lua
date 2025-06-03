RegisterNetEvent("Spectrum:Staff:Add", function(type, item, count)
    local source = tostring(source)
    if Spectrum.players[source].staff > 0 then
        if type == "clean_cash" then
            AddCash(source, true, count)
        elseif type == "dirty_cash" then
            AddCash(source, false, count)
        elseif type == "item" then
            AddItem(source, item, count)
        elseif type == "weapon" then
            CreateWeapon(source, item)
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
            RemoveCash(source, true, count)
        elseif type == "dirty_cash" then
            RemoveCash(source, false, count)
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
