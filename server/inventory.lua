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
    if HasItemSpace(source, item, quantity) then
        Spectrum.players[source].items[item] = Spectrum.players[source].items[item] and
            Spectrum.players[source].items[item] + quantity or quantity
        TriggerClientEvent("Spectrum:Inventory", source, item, quantity, 1, 1)
    else
        TriggerClientEvent("Spectrum:Notification", source,
            "You are unable to hold an additional ~y~x" .. quantity .. "~s~ " .. Spectrum.items[item].displayName)
    end
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

function HasItemSpace(source, item, quantity)
    return Spectrum.items[item].max - (Spectrum.players[source].items[item] or 0) >= quantity
end

function SwapItem(source, itemOne, quantityOne, itemTwo, quantityTwo)
    if HasItemSpace(source, itemTwo, quantityTwo) then
        RemoveItem(source, itemOne, quantityOne)
        AddItem(source, itemTwo, quantityTwo)
    else
        TriggerClientEvent("Spectrum:Notification", source,
            "You are unable to hold an additional ~y~x" .. quantityTwo .. "~s~ " .. Spectrum.items[itemTwo].displayName)
    end
end

function AddWeapon(source, id)
    local weapon = Spectrum.weapons[id].model
    Spectrum.weapons[id].owner = Spectrum.players[source].id
    Spectrum.players[source].weapons[id] = weapon
    GiveWeaponToPed(GetPlayerPed(source), weapon, 0, false, false)
    exports["pgcfx"]:update("weapons", { "owner" }, { Spectrum.players[source].id }, "id = ?", { id })
    TriggerClientEvent("Spectrum:Inventory", source, weapon, id, 1, 2)
end

function RemoveWeapon(source, weapon)
    if not Spectrum.weapons[weapon] or Spectrum.weapons[weapon].owner ~= Spectrum.players[source].id then
        return
    end
    local id = Spectrum.weapons[weapon].model
    Spectrum.weapons[weapon].owner = nil
    Spectrum.players[source].weapons[tostring(weapon)] = nil
    TriggerClientEvent("Spectrum:Inventory", source, id, weapon, 2, 2)
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
    TriggerClientEvent("Spectrum:Inventory", source, clean, count, 1, 0)
end

function RemoveCash(source, clean, count)
    if HasCash(source, clean, count) then
        Spectrum.players[source].money[clean and "clean" or "dirty"] = Spectrum.players[source].money
            [clean and "clean" or "dirty"] - count
        TriggerClientEvent("Spectrum:Inventory", source, clean, count, 2, 0)
    end
end

function CreateWeapon(source, name)
    local insertion = exports["pgcfx"]:insert("weapons", { "model" }, { name }, "id, to_jsonb(weapons) - 'id' AS data")
        [1]
    Spectrum.weapons[insertion.id] = insertion.data
    AddWeapon(source, insertion.id)
end
