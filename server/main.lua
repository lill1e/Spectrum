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
        space = -1,
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
local allFunds = exports["pgcfx"]:select("funds", {}, nil, nil)
for _, fund in ipairs(allFunds) do
    Spectrum.funds[fund.job and "jobs" or "regular"][fund.job and fund.job or fund.id] = {
        id = fund.id,
        total = fund.total,
        clean = fund.clean
    }
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
        health = user.health,
        armor = user.armor,
        dead = user.dead,
        money = {
            clean = user.clean_money,
            dirty = user.dirty_money,
            bank = user.bank
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
        active = true,
        jobs = user.jobs,
        licenses = user.licenses,
        spectating = false
    }

    TriggerClientEvent("Spectrum:PlayerData", playerId, Spectrum.players[tostring(playerId)],
        { debug = Spectrum.debug })
    TriggerClientEvent("Spectrum:Items", playerId, Spectrum.items)
    TriggerClientEvent("Spectrum:Jobs", playerId, Spectrum.jobs)
    TriggerClientEvent("Spectrum:Stores", playerId, Spectrum.stores)
    TriggerClientEvent("Spectrum:Vehicles", playerId, vehiclesTbl, #vehicles)
    TriggerClientEvent("Spectrum:Properties", playerId, globalProperties)
    TriggerClientEvent("Spectrum:Outfits", playerId,
        exports["pgcfx"]:select("outfits", { "id", "components", "props" }, "owner = ?",
            { identifier }, { ["ORDER BY"] = "created" }, nil))
end
local players = {}
for k, v in pairs(Spectrum.players) do
    players[k] = {
        id = v.id,
        position = v.position,
        attributes = v.attributes,
        name = v.name,
        active = v.active,
        staff = v.staff,
        spectating = v.spectating
    }
end
TriggerClientEvent("Spectrum:Players", -1, players)
TriggerClientEvent("Spectrum:Players:Max", -1, GetConvarInt("sv_maxClients", 32))
TriggerClientEvent("Spectrum:Environment", -1, Spectrum.Environment.weather, Spectrum.Environment.time.base)
Spectrum.loaded = true
Spectrum.start = os.time()
Spectrum.closed = false

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        for source, _ in pairs(Spectrum.players) do
            if DoesEntityExist(GetPlayerPed(source)) then
                Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
            end
        end
    end
end)

function savePlayer(source)
    if DoesEntityExist(GetPlayerPed(source)) then
        Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
        if Spectrum.players[source].health == nil then
            Spectrum.players[source].health = GetEntityHealth(GetPlayerPed(source))
        end
        Spectrum.players[source].armor = GetPedArmour(GetPlayerPed(source))
    end
    exports["pgcfx"]:update("users",
        { "clean_money", "dirty_money", "position", "inventory", "ammo", "skin", "health", "armor", "dead", "licenses" },
        { Spectrum.players[source].money.clean, Spectrum.players[source].money.dirty, {
            x = Spectrum.players[source].position.x,
            y = Spectrum.players[source].position.y,
            z = Spectrum.players[source].position.z
        }, Spectrum.players[source].items, Spectrum.players[source].ammo, Spectrum.players[source].skin, Spectrum
            .players[source].health, Spectrum.players[source].armor, Spectrum.players[source].dead, Spectrum.players
            [source].licenses }, "id = ?",
        { Spectrum.players[source].id })
end

Citizen.CreateThread(function()
    while true do
        Wait(60000 * 3)
        for source, playerData in pairs(Spectrum.players) do
            if playerData.active then
                savePlayer(source)
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
        for _, v in pairs(Spectrum.funds.regular) do
            exports["pgcfx"]:update("funds", { "total" }, { v.total }, "id = ?", { v.id })
        end
        for j, v in pairs(Spectrum.funds.jobs) do
            exports["pgcfx"]:update("funds", { "total" }, { v.total }, "id = ?", { v.id })
        end
    end
end)

AddEventHandler("playerConnecting", function(_, _, deferrals)
    local source = source
    local steamHex = GetSteamHex(source)

    deferrals.update("Connecting with the system...")
    if Spectrum.closed then
        deferrals.done("The server is currently closed")
    else
        if steamHex then
            local bans = exports["pgcfx"]:select("bans", {}, "\"user\" = ? AND expiry > ? AND active",
                { steamHex, os.time() })
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
                if #bans > 0 then
                    deferrals.done("\nYou are currently banned from this server (ID: " .. bans[1].id .. ")\nReason: " ..
                        bans[1].reason ..
                        "\nBanned By: " ..
                        bans[1].staff .. "\nExpires At: " .. os.date("%Y-%m-%d %H:%M:%S", bans[1].expiry) .. "\n")
                else
                    if Spectrum.locked then
                        if user.staff > 0 then
                            deferrals.done()
                        else
                            deferrals.done("The server is currently closed for general access")
                        end
                    else
                        deferrals.done()
                    end
                end
            else
                deferrals.done("There was an error fetching your data, please reconnect and try again")
            end
        else
            deferrals.done("Steam is required")
        end
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
                health = user.health,
                armor = user.armor,
                dead = user.dead,
                money = {
                    clean = user.clean_money,
                    dirty = user.dirty_money,
                    bank = user.bank
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
                active = true,
                jobs = user.jobs,
                licenses = user.licenses,
                spectating = false
            }

            TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[source], { debug = Spectrum.debug })
            TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
            TriggerClientEvent("Spectrum:Jobs", source, Spectrum.jobs)
            TriggerClientEvent("Spectrum:Stores", source, Spectrum.stores)
            TriggerClientEvent("Spectrum:Vehicles", source, vehiclesTbl, #vehicles)
            TriggerClientEvent("Spectrum:Properties", source, globalProperties)
            TriggerClientEvent("Spectrum:Outfits", source,
                exports["pgcfx"]:select("outfits", { "id", "components", "props" }, "owner = ?",
                    { steamHex }, { ["ORDER BY"] = "created" }, nil))
            TriggerClientEvent("Spectrum:Players:Max", source, GetConvarInt("sv_maxClients", 32))
            local players = {}
            for k, v in pairs(Spectrum.players) do
                players[k] = {
                    id = v.id,
                    position = v.position,
                    attributes = v.attributes,
                    name = v.name,
                    active = v.active,
                    staff = v.staff,
                    v.spectating
                }
            end
            for _, v in ipairs(GetPlayers()) do
                if v ~= source then
                    TriggerClientEvent("Spectrum:Player:Join", v, source, {
                        id = Spectrum.players[source].id,
                        position = Spectrum.players[source].position,
                        attributes = Spectrum.players[source].attributes,
                        name = Spectrum.players[source].name,
                        active = Spectrum.players[source].active,
                        staff = Spectrum.players[source].staff,
                        spectating = Spectrum.players[source].spectating
                    })
                end
            end
            TriggerClientEvent("Spectrum:Players", source, players)
            TriggerClientEvent("Spectrum:Environment", source, Spectrum.Environment.weather,
                Spectrum.Environment.time.base)
            if user.staff >= Config.Permissions.Trial then
                TriggerClientEvent("Spectrum:Staff:Reports", source, Spectrum.reports)
            end
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
        Spectrum.players[source].active = false
        Spectrum.players[source].dropReason = reason
        TriggerClientEvent("Spectrum:Player:Drop", -1, source, reason, Spectrum.players[source].position)
        savePlayer(source)
    end
end)

RegisterNetEvent("Spectrum:Skin", function(skin)
    local source = tostring(source)

    if Spectrum.players[source] then
        Spectrum.players[source].skin = skin
    end
end)

RegisterNetEvent("Spectrum:Dead", function()
    local source = tostring(source)

    Spectrum.players[source].dead = true
    if DoesEntityExist(GetPlayerPed(source)) then
        Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
        Spectrum.players[source].health = GetEntityHealth(GetPlayerPed(source))
        Spectrum.players[source].armor = GetPedArmour(GetPlayerPed(source))
    end
end)
