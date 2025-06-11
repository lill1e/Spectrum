Spectrum.libs.callbackFunctions.storageSync = function(source, storage, vehicle, vehicleClass)
    if vehicle and not Spectrum.storages[storage] then
        Spectrum.storages[storage] = {
            items = {},
            weapons = {},
            space = vehicleClass and Config.Vehicles.Storages[Config.Vehicles.Classes[vehicleClass]] or 0,
            temporary = true,
            vehicle = true,
            occupied = false,
            occupier = "-1"
        }
    end
    if vehicle and Spectrum.storages[storage].space == -1 then
        Spectrum.storages[storage].space = Config.Vehicles.Storages[Config.Vehicles.Classes[vehicleClass]]
    end
    if Spectrum.storages[storage] and not Spectrum.storages[storage].occupied then
        Spectrum.storages[storage].occupied = true
        Spectrum.storages[storage].occupier = source
        return {
            items = Spectrum.storages[storage].items,
            weapons = Spectrum.storages[storage].weapons,
            space = Spectrum
                .storages[storage].space
        }
    elseif Spectrum.storages[storage] and Spectrum.storages[storage].occupied then
        return nil
    end
end

Spectrum.libs.callbackFunctions.storagePull = function(source, storage, item, quantity)
    if quantity ~= nil then
        if Spectrum.storages[storage].occupied and Spectrum.storages[storage].occupier == source and Spectrum.storages[storage].items[item] >= quantity then
            if HasItemSpace(source, item, quantity) then
                local count = Spectrum.storages[storage].items[item] - quantity
                if count > 0 then
                    Spectrum.storages[storage].items[item] = count
                else
                    Spectrum.storages[storage].items[item] = nil
                end
                AddItem(source, item, quantity)
                return quantity
            else
                Notification(source,
                    "You are unable to hold an additional ~y~x" .. quantity .. "~s~ " .. Spectrum.items[item]
                    .displayName)
                return -1
            end
        else
            return -1
        end
    else
        if Spectrum.storages[storage].occupied and Spectrum.storages[storage].occupier == source and Spectrum.storages[storage].weapons[item] then
            if not HasWeapon(source, Spectrum.storages[storage].weapons[item].model) then
                AddWeapon(source, item, Spectrum.storages[storage].weapons[item].rounds)
                Spectrum.storages[storage].weapons[item] = nil
                return 1
            else
                Notification(source,
                    "You are unable to hold an additional ~y~x" .. quantity .. "~s~ " .. Spectrum.items[item]
                    .displayName)
                return -1
            end
        else
            return -1
        end
    end
end

Spectrum.libs.callbackFunctions.storagePush = function(source, storage, item, quantity, ammoType)
    if ammoType == nil then
        if Spectrum.storages[storage].occupied and Spectrum.storages[storage].occupier == source and HasItemThreshold(source, item, quantity) then
            if HasStorageSpace(storage, quantity) then
                RemoveItem(source, item, quantity)
                if Spectrum.storages[storage].items[item] then
                    Spectrum.storages[storage].items[item] = Spectrum.storages[storage].items[item] + quantity
                else
                    Spectrum.storages[storage].items[item] = quantity
                end
                return quantity
            else
                Notification(source,
                    "There's not enough room for ~y~x" .. quantity .. "~s~ " .. Spectrum.items[item].displayName)
                return -1
            end
        else
            return -1
        end
    else
        if Spectrum.storages[storage].occupied and Spectrum.storages[storage].occupier == source and Spectrum.weapons[item] and (quantity == 0 or HasAmmoThreshold(source, ammoType, quantity)) then
            if Spectrum.weapons[item].owner == Spectrum.players[source].id then
                if HasStorageSpace(storage, 5) then
                    RemoveWeapon(source, item)
                    if quantity > 0 then
                        RemoveAmmo(source, ammoType, quantity)
                    end
                    Spectrum.storages[storage].weapons[item] = {
                        model = Spectrum.weapons[item].model,
                        rounds = quantity,
                    }
                    return {
                        valid = true,
                        model = Spectrum.weapons[item].model,
                        rounds = quantity,
                        id = item
                    }
                else
                    Notification(source,
                        "There's not enough room for a ~b~" .. Config.Weapons[Spectrum.weapons[item].model])
                    return -1
                end
            else
                -- TODO: logging
                return -1
            end
        else
            return -1
        end
    end
end

function HasStorageSpace(storage, quantity)
    local space = Spectrum.storages[storage].space
    local count = 0
    for _, c in pairs(Spectrum.storages[storage].items) do
        count = count + c
        if space - count < quantity then
            return false
        end
    end
    for _, _ in pairs(Spectrum.storages[storage].weapons) do
        count = count + 5
        if space - count < quantity then
            return false
        end
    end
    return true
end

RegisterNetEvent("Spectrum:Storage:Unlock", function(storage)
    local source = tostring(source)
    if Spectrum.storages[storage] and Spectrum.storages[storage].occupied and Spectrum.storages[storage].occupier == source then
        Spectrum.storages[storage].occupied = false
        Spectrum.storages[storage].occupier = "-1"
    end
end)
