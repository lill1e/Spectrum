RegisterNetEvent("Spectrum:Staff:Add", function(type, item, count)
    local source = tostring(source)
    if Spectrum.players[source].staff >= 0 then
        if type == "clean_cash" then
            AddCash(source, true, count)
        elseif type == "dirty_cash" then
            AddCash(source, false, count)
        elseif type == "item" then
            AddItem(source, item, count)
        elseif type == "weapon" then
            AddWeapon(source, item)
        elseif type == "ammo" then
            AddAmmo(source, item, count)
        end
    else
        -- TODO: add logging
    end
end)
