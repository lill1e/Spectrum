RegisterNetEvent("Spectrum:UseItem", function(item)
    local source = tostring(source)

    if Spectrum.players[source].items[item] and (Spectrum.items[item].usable and Spectrum.items[item].usable or Spectrum.players[source].items[item] >= Spectrum.items[item].usable) and HasItemThreshold(source, item, (type(Spectrum.items[item].usable) == "number" and Spectrum.items[item].usable or 1)) then
        if Spectrum.items[item] then
            if Spectrum.items[item].removeOnUse then
                RemoveItem(source, item,
                    type(Spectrum.items[item].usable) == "number" and Spectrum.items[item].usable or 1)
            end
            if Spectrum.items[item].swapOnUse then
                SwapItem(source, item,
                    (type(Spectrum.items[item].usable) == "number" and Spectrum.items[item].usable or 1),
                    Spectrum.items[item].swapOnUse.item,
                    Spectrum.items[item].swapOnUse.quantity)
            end
            if Spectrum.items[item].handler then
                Spectrum.items[item].handler(source)
            end
            if Spectrum.items[item].event then
                Spectrum.items[item].handler(source)
                TriggerClientEvent(Spectrum.items[item].event.name, source, table.unpack(Spectrum.items[item].event.data))
            end
        end
    else
        -- TODO: This should not happen, maybe add some sort of protection/logging
    end
    TriggerClientEvent("Spectrum:InventoryRelease", source)
end)

RegisterNetEvent("Spectrum:Ammo", function(type, quantity)
    local source = tostring(source)

    if Spectrum.players[source] ~= nil then
        if quantity <= Spectrum.players[source].ammo[type] then
            Spectrum.players[source].ammo[type] = quantity
        else
            -- TODO: add some action here, this should not ever happen
        end
    end
end)

function AddItem(source, item, quantity)
    Spectrum.players[source].items[item] = Spectrum.players[source].items[item] and
        Spectrum.players[source].items[item] + quantity or quantity
    TriggerClientEvent("Spectrum:Inventory", source, item, quantity, 1, 1)
end

function RemoveItem(source, item, quantity)
    if HasItemThreshold(source, item, quantity) then
        Spectrum.players[source].items[item] = Spectrum.players[source].items[item] > quantity and
            Spectrum.players[source].items[item] - quantity or nil
        TriggerClientEvent("Spectrum:Inventory", source, item, quantity, 2, 1)
    end
end

function HasItemThreshold(source, item, quantity)
    return Spectrum.players[source].items[item] and Spectrum.players[source].items[item] >= quantity
end

function SwapItem(source, itemOne, quantityOne, itemTwo, quantityTwo)
    RemoveItem(source, itemOne, quantityOne)
    AddItem(source, itemTwo, quantityTwo)
end

function AddWeapon(source, weapon, id)
    if not Spectrum.players[source].weapons[weapon] then
        return
    end
    Spectrum.weapons[id].owner = Spectrum.players[source].id
    Spectrum.players[source].weapons[weapon] = id
    GiveWeaponToPed(PlayerPedId(), weapon, 0, false, false)
    TriggerClientEvent("Spectrum:Inventory", source, weapon, -1, 1, 2)
end

function RemoveWeapon(source, weapon)
    if not Spectrum.players[source].weapons[weapon] then
        return
    end
    Spectrum.weapons[Spectrum.players[source].weapons[weapon]].owner = nil
    Spectrum.players[source].weapons[weapon] = nil
    TriggerClientEvent("Spectrum:Inventory", source, weapon, -1, 2, 2)
end

function HasWeapon(source, weapon)
    return HasPedGotWeapon(source, weapon, false)
end

function AddAmmo(source, type, quantity)
    Spectrum.players[source].ammo[type] = Spectrum.players[source].ammo[type] + quantity
    TriggerClientEvent("Spectrum:Inventory", source, type, quantity, 1, 3)
end

function RemoveAmmo(source, type, quantity)
    if HasAmmoThreshold(source, type, quantity) then
        Spectrum.players[source].ammo[type] = Spectrum.players[source].ammo[type] > quantity and
            Spectrum.players[source].ammo[type] - quantity or 0
        TriggerClientEvent("Spectrum:Inventory", source, type, quantity, 2, 3)
    end
end

function HasAmmoThreshold(source, type, quantity)
    return Spectrum.players[source].ammo[type] >= quantity
end

function HasCash(source, clean, count)
    return Spectrum.players[source].money[clean and "clean" or "dirty"] >= count
end

function AddCash(source, clean, count)
    Spectrum.players[source].money[clean and "clean" or "dirty"] = Spectrum.players[source].money
        [clean and "clean" or "dirty"] + count
end

function RemoveCash(source, clean, count)
    if HasCash(source, clean, count) then
        Spectrum.players[source].money[clean and "clean" or "dirty"] = Spectrum.players[source].money
            [clean and "clean" or "dirty"] - count
    end
end
