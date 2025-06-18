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

Spectrum.libs.callbackFunctions.verifyVehiclePlate = function(source, plate, garage, data)
    local query = exports["pgcfx"]:update("vehicles", { "active", "garage", "data" }, { "false", garage, data },
        "id = ? AND owner = ?",
        { plate, Spectrum.players[source].id })
    if query > 0 then
        Spectrum.storages[plate].occupied = false
        Spectrum.storages[plate].occupier = "-1"
    end
    return query > 0
end

Spectrum.libs.callbackFunctions.restoreVehicle = function(source, plate)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
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

Spectrum.libs.callbackFunctions.locationChange = function(source, plate, garage)
    if Spectrum.players[source].staff >= Config.Permissions.Admin then
        local query = exports["pgcfx"]:update("vehicles", { "garage" }, { garage }, "id = ?",
            { plate })
        if query > 0 then
            local identifierQuery = exports["pgcfx"]:selectOne("vehicles", { "owner" }, "id = ?", { plate })
            if identifierQuery == nil then
                return false
            end
            local identifier = identifierQuery.owner
            for target, player in pairs(Spectrum.players) do
                if player.id == identifier then
                    TriggerClientEvent("Spectrum:Garage:Location", target, plate, garage)
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
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            if newPlate == "" or Whitespace(newPlate) then
                newPlate = RandomPlate()
            end
            local query = exports["pgcfx"]:update("vehicles", { "id" }, { newPlate }, "id = ? AND owner = ?",
                { plate, Spectrum.players[target].id })
            if query > 0 then
                Spectrum.storages[newPlate] = Spectrum.storages[plate]
                Spectrum.storages[plate] = nil
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
            if type == 0 and Spectrum.players[source].staff >= Config.Permissions.Trial then
                return Spectrum.players[target].identifiers
            elseif type == 1 and Spectrum.players[source].staff >= Config.Permissions.Staff then
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
            elseif type == 2 and Spectrum.players[source].staff >= Config.Permissions.Admin then
                return Spectrum.players[target].items
            elseif type == 3 and Spectrum.players[source].staff >= Config.Permissions.Admin then
                return Spectrum.players[target].money
            end
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
    if isMatch and ammoType and ammo then
        Spectrum.players[source].ammo[ammoType] = Spectrum.players[source].ammo[ammoType] + ammo
    end
    return isMatch
end

Spectrum.libs.callbackFunctions.depositBank = function(source, count)
    if HasCash(source, true, true, count) then
        RemoveCash(source, true, true, count)
        AddCash(source, false, true, count)
        return true
    else
        return false
    end
end

Spectrum.libs.callbackFunctions.withdrawBank = function(source, count)
    if HasCash(source, false, true, count) then
        RemoveCash(source, false, true, count)
        AddCash(source, true, true, count)
        return true
    else
        return false
    end
end

Spectrum.libs.callbackFunctions.parking = function(source, spots)
    if spots == nil then
        return -1
    end
    local vehicles = GetAllVehicles()
    for i, spot in ipairs(spots) do
        local position = spot[1]
        local available = true
        for _, handle in ipairs(vehicles) do
            local dist = #(position - GetEntityCoords(handle))
            if dist <= 5 then
                available = false
                break
            end
        end
        if available then
            return i
        end
    end
    return -1
end

Spectrum.libs.callbackFunctions.createBill = function(source, cost, target)
    target = tostring(target)
    if not Spectrum.players[target] or not Spectrum.players[target].active then
        return false
    end
    local id = GetGameTimer() + math.random(999)
    while Spectrum.bills[id] ~= nil do
        id = GetGameTimer() + math.random(999)
    end
    Spectrum.bills[id] = {
        cost = cost,
        biller = source,
        target = target
    }
    TriggerClientEvent("Spectrum:Bills:Create", target, id, Spectrum.bills[id])
    return true
end

Spectrum.libs.callbackFunctions.payBill = function(source, id)
    if Spectrum.bills[id] and HasCash(source, false, true, Spectrum.bills[id].cost) then
        RemoveCash(source, false, true, Spectrum.bills[id].cost)
        AddCash(Spectrum.bills[id].biller, false, true, Spectrum.bills[id].cost)
        Notification(source, "You have paid the ~y~bill ~s~of ~g~$" .. FormatMoney(Spectrum.bills[id].cost))
        Notification(Spectrum.bills[id].biller,
            "You have recieved ~g~$" .. FormatMoney(Spectrum.bills[id].cost) .. " ~s~for Bill #" .. id)
        return true
    else
        Notification(source, "You do not have enough ~g~money ~s~for this")
        return false
    end
end

Spectrum.libs.callbackFunctions.saveOutfit = function(source, components, props)
    if Spectrum.players[source] then
        local query = exports["pgcfx"]:insert("outfits", { "owner", "components", "props", "created" },
            { Spectrum.players[source].id, components, props, os.time() }, "id")
        return query
    else
        return {}
    end
end

Spectrum.libs.callbackFunctions.staffAdd = function(source, type, item, count, target)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Admin then
        if type == "clean_cash" then
            AddCash(player, true, true, count)
        elseif type == "dirty_cash" then
            AddCash(player, true, false, count)
        elseif type == "bank" then
            AddCash(player, false, true, count)
        elseif type == "item" then
            if HasItemSpace(player, item, count) then
                AddItem(player, item, count)
            else
                return false
            end
        elseif type == "weapon" then
            if HasWeapon(player, item) then
                return false
            else
                AddWeapon(player, CreateWeapon(item), 0)
            end
        elseif type == "ammo" then
            AddAmmo(player, item, count)
        end
        return true
    else
        -- TODO: add logging
        return false
    end
end

Spectrum.libs.callbackFunctions.staffRemove = function(source, type, item, count, target)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Admin then
        if type == "clean_cash" then
            RemoveCash(player, true, true, count)
        elseif type == "dirty_cash" then
            RemoveCash(player, true, false, count)
        elseif type == "bank" then
            RemoveCash(player, false, true, count)
        elseif type == "item" then
            if HasItemThreshold(player, item, count) then
                RemoveItem(player, item, count)
            else
                return false
            end
        elseif type == "weapon" then
            RemoveWeapon(player, item)
        elseif type == "ammo" then
            RemoveAmmo(player, item, count)
        end
        return true
    else
        -- TODO: add logging
        return false
    end
end

Spectrum.libs.callbackFunctions.legalPlateChange = function(source, plate, newPlate)
    if Spectrum.jobs.Legal[source] then
        plate = StripPlate(plate:upper())
        newPlate = StripPlate(newPlate:upper())
        local identifierQuery = exports["pgcfx"]:selectOne("vehicles", { "owner" }, "id = ?", { plate })
        local identifier = nil
        local target = nil
        if identifierQuery then
            identifier = identifierQuery.owner
            for id, player in pairs(Spectrum.players) do
                if player.id == identifier and player.active then
                    target = id
                end
            end
        else
            Notification(source, "This ~b~vehicle ~s~is not owned by anyone, this has been reported")
            -- TODO: add logging
            return nil
        end
        if target then
            local query = exports["pgcfx"]:update("vehicles", { "active", "garage" }, { "false", "Alta" }, "id = ?",
                { plate })
            if query > 0 then
                Spectrum.storages[newPlate] = Spectrum.storages[plate]
                Spectrum.storages[plate] = nil
                local paddedPlate = PadPlate(plate)
                for _, entity in ipairs(GetAllVehicles()) do
                    if GetEntityType(entity) == 2 and GetVehicleNumberPlateText(entity) == paddedPlate then
                        DeleteEntity(entity)
                    end
                end
                TriggerClientEvent("Spectrum:Garage:Reset", target, plate, "Alta")
                if newPlate == "" or Whitespace(newPlate) then
                    newPlate = RandomPlate()
                end
                local updateQuery = exports["pgcfx"]:update("vehicles", { "id" }, { newPlate },
                    "id = ? AND owner = ?",
                    { plate, Spectrum.players[target].id })
                if updateQuery > 0 then
                    TriggerClientEvent("Spectrum:Vehicles:Reassign", target, plate, newPlate)
                    return newPlate
                else
                    Notification(source, "There was an issue performing this action, please report this")
                    return nil
                end
            end
        else
            Notification(source, "The ~b~owner ~s~of the vehicle must be around to perform this action")
            return nil
        end
    end
end

Spectrum.libs.callbackFunctions.getShipments = function(source, job)
    if Spectrum.players[source] and Spectrum.jobs[job][source] then
        -- if os.time() >= Spectrum.Shipment.Last + 60 then
        --     Spectrum.Shipment.Last = os.time()
        -- end
        local ret = {
            shipments = {},
            dist = Spectrum.Shipment.Last and ((Spectrum.Shipment.Last + Spectrum.Shipment.Cooldown) - os.time()) * 1000 or
                0
        }
        for k, shipment in pairs(Spectrum.shipments) do
            if job == shipment.job or (shipment.jobs and shipment.jobs[job]) then
                ret.shipments[k] = {
                    name = shipment.displayName,
                    cost = shipment.cost,
                    method = {
                        vehicle = shipment.method.vehicle and shipment.method.model or nil,
                        object = not shipment.method.vehicle
                    }
                }
            end
        end
        return ret
    else
        -- TODO: add logging
    end
end

Spectrum.libs.callbackFunctions.orderShipment = function(source, job, shipment)
    if Spectrum.players[source] and Spectrum.jobs[job][source] then
        if Spectrum.shipments[shipment].job == job or (Spectrum.shipments[shipment].jobs and Spectrum.shipments[shipment].jobs[job]) then
            if HasCash(source, true, false, Spectrum.shipments[shipment].cost) then
                if Spectrum.Shipment.Last == nil or os.time() >= Spectrum.Shipment.Last + Spectrum.Shipment.Cooldown then
                    Spectrum.Shipment.Last = os.time()
                    TriggerClientEvent("Spectrum:Job:NicheTerminate", -1,
                        ((Spectrum.Shipment.Last + Spectrum.Shipment.Cooldown) - os.time()) * 1000)
                    RemoveCash(source, true, false, Spectrum.shipments[shipment].cost)
                    local chances = {
                        items = {},
                        weapons = {}
                    }
                    local temp = 0.0
                    for k, v in pairs(Spectrum.shipments[shipment].items) do
                        chances.items[temp] = {
                            item = k,
                            chance = v
                        }
                        temp = temp + v
                    end
                    temp = 0.0
                    for k, v in pairs(Spectrum.shipments[shipment].weapons) do
                        chances.weapons[temp] = {
                            item = k,
                            chance = v
                        }
                        temp = temp + v
                    end
                    local result = {
                        items = {},
                        weapons = {}
                    }
                    for _ = 1, Spectrum.shipments[shipment].count.items do
                        local n = math.random()
                        for k, v in pairs(chances.items) do
                            if n >= k and n < (k + v.chance) then
                                table.insert(result.items, v.item)
                                break
                            end
                        end
                    end
                    for _ = 1, Spectrum.shipments[shipment].count.weapons do
                        local n = math.random()
                        for k, v in pairs(chances.weapons) do
                            if n >= k and n < (k + v.chance) then
                                table.insert(result.weapons, v.item)
                                break
                            end
                        end
                    end
                    local method = Spectrum.shipments[shipment].method
                    local locations = method.locations
                    local location = locations[math.random(#locations)]
                    if method.vehicle then
                        local vehicle = CreateVehicleServerSetter(method.model, method.vehicleType, location[1],
                            location[2], true)
                        Citizen.CreateThread(function()
                            while not DoesEntityExist(vehicle) do Wait(0) end
                            while GetVehicleNumberPlateText(vehicle) == "" do Wait(0) end
                            local items = {}
                            local weapons = {}
                            for _, item in ipairs(result.items) do
                                if items[item] then
                                    items[item] = items[item] + 1
                                else
                                    items[item] = 1
                                end
                            end
                            for _, weaponModel in ipairs(result.weapons) do
                                local weapon = CreateWeapon(weaponModel)
                                weapons[weapon] = {
                                    model = weaponModel,
                                    rounds = Config.MaxAmmo[weaponModel] and Config.MaxAmmo[weaponModel] or 90
                                }
                            end
                            Spectrum.storages[GetVehicleNumberPlateText(vehicle)] = {
                                items = items,
                                weapons = weapons,
                                space = #result.items + (#result.weapons * 5),
                                temporary = true,
                                vehicle = true,
                                occupied = false,
                                occupier = "-1"
                            }
                            TriggerClientEvent("Spectrum:Job:Shipment", source, location[1])
                        end)
                    else
                        local object = CreateObject(method.model, location[1], true, false)
                        -- Citizen.CreateThread(function ()
                        --     while not DoesEntityExist(object)
                        -- end)
                    end
                end
            else
                Notification(source, "You're unable to pay for this ~o~order")
            end
        end
    end
end

Spectrum.libs.callbackFunctions.addExternalProperty = function(source, target, location, space)
    target = tostring(target)
    if Spectrum.players[source].staff >= 3 then
        if Spectrum.players[target] then
            local queryP = exports["pgcfx"]:insert("properties", { "owner", "x", "y", "z" },
                { Spectrum.players[target].id, location.x, location.y, location.z }, "id")
            if queryP and #queryP > 0 then
                local id = queryP[1].id
                local queryS = exports["pgcfx"]:insert("storages", { "id", "space" }, { id, 100 })
                if queryS > 0 then
                    Spectrum.properties[id] = {
                        owner = Spectrum.players[target].id,
                        x = location.x,
                        y = location.y,
                        z = location.z,
                        position = location,
                        locked = true
                    }
                    Spectrum.storages[id] = {
                        items = {},
                        weapons = {},
                        space = space,
                        occupied = false,
                        occupier = "-1"
                    }
                    TriggerClientEvent("Spectrum:Property:Add", -1, id, Spectrum.properties[id])
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    end
end

Spectrum.libs.callbackFunctions.getJobFund = function(source, job)
    if Spectrum.players[source] and Spectrum.jobs[job] and Spectrum.jobs[job][source] and Spectrum.players[source].jobs[job] and Config.Jobs[job].ranks[Spectrum.players[source].jobs[job]].fund and Spectrum.funds.jobs[job] then
        return Spectrum.funds.jobs[job].total, Spectrum.funds.jobs[job].clean
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.depositFund = function(source, job, count)
    if Spectrum.players[source] and Spectrum.jobs[job] and Spectrum.jobs[job][source] and Spectrum.players[source].jobs[job] and Config.Jobs[job].ranks[Spectrum.players[source].jobs[job]].fund and Spectrum.funds.jobs[job] then
        if HasCash(source, true, Spectrum.funds.jobs[job].clean, count) then
            RemoveCash(source, true, Spectrum.funds.jobs[job].clean, count)
            Spectrum.funds.jobs[job].total = Spectrum.funds.jobs[job].total + count
            return true
        else
            return nil
        end
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.withdrawFund = function(source, job, count)
    if Spectrum.players[source] and Spectrum.jobs[job] and Spectrum.jobs[job][source] and Spectrum.players[source].jobs[job] and Config.Jobs[job].ranks[Spectrum.players[source].jobs[job]].fund and Spectrum.funds.jobs[job] then
        if Spectrum.funds.jobs[job].total >= count then
            Spectrum.funds.jobs[job].total = Spectrum.funds.jobs[job].total - count
            AddCash(source, true, Spectrum.funds.jobs[job].clean, count)
            return true
        else
            return nil
        end
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.dealershipPurchase = function(source, dealership, class, vehicle)
    if Config.Dealership[dealership] and Config.Dealership[dealership].vehicles[class] and Config.Dealership[dealership].vehicles[class][vehicle] then
        if TableContains(Spectrum.players[source].licenses, Config.Dealership[dealership].license) then
            local cost = Config.Dealership[dealership].vehicles[class][vehicle]
            if HasCash(source, true, true, cost) or HasCash(source, false, true, cost) then
                if HasCash(source, true, true, cost) then
                    RemoveCash(source, true, true, cost)
                else
                    RemoveCash(source, false, true, cost)
                end
                local plate = RandomPlate()
                local query = exports["pgcfx"]:insert("vehicles", { "id", "owner", "vehicle", "active" },
                    { plate, Spectrum.players[source].id, vehicle, true })
                if query > 0 then
                    Spectrum.storages[plate] = {
                        items = {},
                        weapons = {},
                        space = Config.Vehicles.Storages[Config.Vehicles.Classes[class]],
                        temporary = false,
                        vehicle = true,
                        occupied = false,
                        occupier = "-1"
                    }
                    TriggerClientEvent("Spectrum:Vehicles:Add", source, vehicle, plate)
                    return plate
                else
                    return nil
                end
            else
                Notification(source, "You do not have enough ~g~money ~s~to purchase this vehicle")
                return nil
            end
        else
            Notification(source, "You do not have the correct ~g~license ~s~to purchase this vehicle")
            return nil
        end
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.getLocation = function(source, target)
    target = tostring(target)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if not Spectrum.players[target] or not Spectrum.players[target].active or Spectrum.players[target].spectating or not DoesEntityExist(GetPlayerPed(target)) then
            return nil
        else
            return GetEntityCoords(GetPlayerPed(target))
        end
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.legalFetchLicenses = function(source, target)
    target = tostring(target)
    if Spectrum.jobs.Legal[source] and Spectrum.players[target] and Spectrum.players[target].active then
        return Spectrum.players[target].licenses
    else
        return nil
    end
end

Spectrum.libs.callbackFunctions.legalGrantLicense = function(source, target, license)
    target = tostring(target)
    if Spectrum.jobs.Legal[source] and Spectrum.players[target] and Spectrum.players[target].active and Spectrum.players[target].licenses and not TableContains(Spectrum.players[target].licenses, license) and Config.Licenses[license] then
        table.insert(Spectrum.players[target].licenses, license)
        TriggerClientEvent("Spectrum:Licenses:Grant", target, license)
        return true
    else
        return nil
    end
end
