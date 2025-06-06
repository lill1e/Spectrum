exports["pgcfx"]:ready(function()
    Wait(500)
    local rawWeapons = exports["pgcfx"]:select("Weapons", { "id", "(to_jsonb(weapons) - 'id') AS data" }, nil, nil,
        { ["GROUP BY"] = "id" })
    for _, v in ipairs(rawWeapons) do
        Spectrum.weapons[v.id] = v.data
    end
    local properties = exports["pgcfx"]:select("properties", { "id", "(to_jsonb(properties) - 'id') AS data" }, nil, nil,
        { ["GROUP BY"] = "id" })
    for _, data in ipairs(properties) do
        Spectrum.properties[data.id] = data.data
        Spectrum.properties[data.id].position = vector3(data.data.x, data.data.y, data.data.z)
    end
    local storages = exports["pgcfx"]:select("storages", { "id", "(to_jsonb(storages) - 'id') AS data" }, nil, nil,
        {})
    for _, data in ipairs(storages) do
        Spectrum.storages[data.id] = {
            items = data.data.items,
            weapons = {},
            space = data.data.space,
            occupied = false,
            occupier = "-1"
        }
        for weapon, ammo in pairs(data.data.weapons) do
            local id = tonumber(weapon)
            if id then
                Spectrum.storages[data.id].weapons[id] = {
                    model = Spectrum.weapons[id].model,
                    rounds = ammo
                }
            end
        end
    end
    local allVehicles = exports["pgcfx"]:select("vehicles", { "id", "(to_jsonb(vehicles) - 'id') AS data" }, nil, nil,
        {})
    for _, data in ipairs(allVehicles) do
        Spectrum.storages[data.id] = {
            items = data.data.items,
            weapons = {},
            space = 30,
            occupied = false,
            occupier = "-1",
            vehicle = true
        }
        for weapon, ammo in pairs(data.data.weapons) do
            local id = tonumber(weapon)
            if id then
                Spectrum.storages[data.id].weapons[id] = {
                    model = Spectrum.weapons[id].model,
                    rounds = ammo
                }
            end
        end
    end
    for _, playerId in ipairs(GetPlayers()) do
        local identifier = GetSteamHex(playerId)
        local user = exports["pgcfx"]:selectOne("Users",
            { "users.*",
                "COALESCE(json_object_agg(weapons.id, weapons.model) FILTER (WHERE weapons.id IS NOT NULL), '{}'::json) AS weapons" },
            "users.id = ?",
            { identifier }, { ["GROUP BY"] = "users.id", JOIN = "LEFT" },
            "weapons ON weapons.owner = users.id")

        local vehicles = exports["pgcfx"]:select("vehicles", {}, "owner = ?", { identifier })
        local vehiclesTbl = {}
        for _, vehicle in ipairs(vehicles) do
            vehiclesTbl[vehicle.id] = {
                vehicle = vehicle.vehicle,
                data = vehicle.data,
                garage = vehicle.garage,
                active = vehicle.active
            }
        end

        local weapons = {}
        for strIndex, weapon in pairs(user.weapons) do
            weapons[tonumber(strIndex)] = weapon
        end

        local tempAttr = {}
        for _, a in ipairs(user.attributes) do
            tempAttr[a] = true
        end

        local globalProperties = {}
        for id, data in ipairs(Spectrum.properties) do
            globalProperties[id] = data
            if data.owner == identifier then
                globalProperties[id].owned = true
            end
        end
        Spectrum.players[tostring(playerId)] = {
            id = user.id,
            money = {
                clean = user.clean_money,
                dirty = user.dirty_money
            },
            position = user.position,
            ped = user.ped,
            attributes = tempAttr,
            staff = user.staff,
            items = user.inventory,
            ammo = user.ammo,
            weapons = weapons,
            identifiers = GetAllIdentifiers(tostring(playerId)),
            skin = user.skin,
            name = GetPlayerName(playerId),
            active = true
        }

        TriggerClientEvent("Spectrum:PlayerData", playerId, Spectrum.players[tostring(playerId)],
            { debug = Spectrum.debug })
        TriggerClientEvent("Spectrum:Items", playerId, Spectrum.items)
        TriggerClientEvent("Spectrum:Jobs", playerId, Spectrum.jobs)
        TriggerClientEvent("Spectrum:Stores", playerId, Spectrum.stores)
        TriggerClientEvent("Spectrum:Vehicles", playerId, vehiclesTbl, #vehicles)
        TriggerClientEvent("Spectrum:Properties", playerId, globalProperties)
    end
    local players = {}
    for k, v in pairs(Spectrum.players) do
        players[k] = {
            id = v.id,
            position = v.position,
            attributes = v.attributes,
            name = v.name,
            active = v.active
        }
    end
    TriggerClientEvent("Spectrum:Players", -1, players)
    Spectrum.loaded = true

    Citizen.CreateThread(function()
        while true do
            Wait(15000)
            for source, _ in pairs(Spectrum.players) do
                if DoesEntityExist(GetPlayerPed(source)) then
                    Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
                end
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Wait(60000 * 3)
            for source, playerData in pairs(Spectrum.players) do
                if playerData.active then
                    if DoesEntityExist(GetPlayerPed(source)) then
                        Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
                    end
                    exports["pgcfx"]:update("users",
                        { "clean_money", "dirty_money", "position", "inventory", "ammo", "skin" },
                        { playerData.money.clean, playerData.money.dirty,
                            {
                                x = playerData.position.x,
                                y = playerData.position.y,
                                z = playerData.position.z
                            },
                            playerData.items, playerData.ammo, playerData.skin }, "id = ?", { playerData.id })
                end
            end
            for weaponId, weaponData in pairs(Spectrum.weapons) do
                exports["pgcfx"]:update("weapons", { "attachments", "owner" },
                    { weaponData.attachments, weaponData.owner and weaponData.owner or "NULL" }, "id = ?", { weaponId })
            end
            for propertyId, property in pairs(Spectrum.properties) do
                exports["pgcfx"]:update("properties", { "locked", "owner" },
                    { property.locked, property.owner and property.owner or "NULL" }, "id = ?", { propertyId })
            end
            for storageId, storage in pairs(Spectrum.storages) do
                if storage.temporary then
                    goto continue
                end
                local weapons = {}
                for id, weapon in pairs(storage.weapons) do
                    weapons[id] = weapon.rounds
                end
                if storage.vehicle then
                    exports["pgcfx"]:update("vehicles", { "items", "weapons" }, { storage.items, weapons }, "id = ?",
                        { storageId })
                else
                    exports["pgcfx"]:update("storages", { "items", "weapons" }, { storage.items, weapons }, "id = ?",
                        { storageId })
                end
                ::continue::
            end
        end
    end)
end)

AddEventHandler("playerConnecting", function(_, _, deferrals)
    local source = source
    local steamHex = GetSteamHex(source)

    if steamHex then
        local user = exports["pgcfx"]:selectOne("Users", {}, "id = ?", { steamHex })
        if user == nil then
            local insertion = exports["pgcfx"]:insert("Users", { "id" }, { steamHex })
            if insertion then
                user = exports["pgcfx"]:selectOne("Users", {}, "id = ?", { steamHex })
            else
                deferrals.done("There was an error fetching your data, please reconnect and try again")
            end
        end
        if user then
            deferrals.done()
        else
            deferrals.done("There was an error fetching your data, please reconnect and try again")
        end
    else
        deferrals.done("Steam is required")
    end
end)

AddEventHandler("playerJoining", function()
    local source = tostring(source)
    local steamHex = GetSteamHex(source)

    if steamHex then
        local user = exports["pgcfx"]:selectOne("Users",
            { "users.*",
                "COALESCE(json_object_agg(weapons.id, weapons.model) FILTER (WHERE weapons.id IS NOT NULL), '{}'::json) AS weapons" },
            "users.id = ?",
            { steamHex }, { ["GROUP BY"] = "users.id", JOIN = "LEFT" },
            "weapons ON weapons.owner = users.id")

        local vehicles = exports["pgcfx"]:select("vehicles", {}, "owner = ?", { steamHex })
        local vehiclesTbl = {}
        for _, vehicle in ipairs(vehicles) do
            vehiclesTbl[vehicle.id] = {
                vehicle = vehicle.vehicle,
                data = vehicle.data,
                garage = vehicle.garage,
                active = vehicle.active
            }
        end

        local weapons = {}
        for strIndex, weapon in pairs(user.weapons) do
            weapons[tonumber(strIndex)] = weapon
        end

        local tempAttr = {}
        for _, a in ipairs(user.attributes) do
            tempAttr[a] = true
        end

        local globalProperties = {}
        for id, data in ipairs(Spectrum.properties) do
            globalProperties[id] = data
            if data.owner == steamHex then
                globalProperties[id].owned = true
            end
        end

        if user then
            Spectrum.players[source] = {
                id = user.id,
                money = {
                    clean = user.clean_money,
                    dirty = user.dirty_money
                },
                position = user.position,
                ped = user.ped,
                attributes = tempAttr,
                staff = user.staff,
                items = user.inventory,
                ammo = user.ammo,
                weapons = weapons,
                identifiers = GetAllIdentifiers(source),
                skin = user.skin,
                name = GetPlayerName(source),
                active = true
            }

            TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[source], { debug = Spectrum.debug })
            TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
            TriggerClientEvent("Spectrum:Jobs", source, Spectrum.jobs)
            TriggerClientEvent("Spectrum:Stores", source, Spectrum.stores)
            TriggerClientEvent("Spectrum:Vehicles", source, vehiclesTbl, #vehicles)
            TriggerClientEvent("Spectrum:Properties", source, globalProperties)
            local players = {}
            for k, v in pairs(Spectrum.players) do
                players[k] = {
                    id = v.id,
                    position = v.position,
                    attributes = v.attributes,
                    name = v.name,
                    active = v.active
                }
            end
            for _, v in ipairs(GetPlayers()) do
                if v ~= source then
                    TriggerClientEvent("Spectrum:Player:Join", v, source, {
                        id = Spectrum.players[source].id,
                        position = Spectrum.players[source].position,
                        attributes = Spectrum.players[source].attributes,
                        name = Spectrum.players[source].name,
                        active = Spectrum.players[source].active
                    })
                end
            end
            TriggerClientEvent("Spectrum:Players", source, players)
        else
            DropPlayer(source, "There was an error fetching your data, please reconnect and try again")
        end
    else
        DropPlayer(source, "There was an error fetching your data, please reconnect and try again")
    end
end)

AddEventHandler("playerDropped", function(reason)
    local source = tostring(source)

    if Spectrum.players[source] ~= nil then
        if DoesEntityExist(GetPlayerPed(source)) then
            Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
        end
        Spectrum.players[source].active = false
        TriggerClientEvent("Spectrum:Player:Drop", -1, source)
        exports["pgcfx"]:update("users", { "clean_money", "dirty_money", "position", "inventory", "ammo", "skin" },
            { Spectrum.players[source].money.clean, Spectrum.players[source].money.dirty, {
                x = Spectrum.players[source].position.x,
                y = Spectrum.players[source].position.y,
                z = Spectrum.players[source].position.z
            }, Spectrum.players[source].items, Spectrum.players[source].ammo, Spectrum.players[source].skin }, "id = ?",
            { Spectrum.players[source].id })
    end
end)

RegisterNetEvent("Spectrum:Skin", function(skin)
    local source = tostring(source)

    if Spectrum.players[source] then
        Spectrum.players[source].skin = skin
    end
end)
