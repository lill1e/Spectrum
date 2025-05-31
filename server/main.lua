exports["pgcfx"]:ready(function()
    Wait(500)
    local rawWeapons = exports["pgcfx"]:select("Weapons", { "id", "(to_jsonb(weapons) - 'id') AS data" }, nil, nil,
        { ["GROUP BY"] = "id" })
    for _, v in ipairs(rawWeapons) do
        Spectrum.weapons[v.id] = v.data
    end
    for _, playerId in ipairs(GetPlayers()) do
        local identifier = GetSteamHex(playerId)
        local user = exports["pgcfx"]:selectOne("Users",
            { "users.*",
                "COALESCE(json_object_agg(weapons.id, weapons.model) FILTER (WHERE weapons.id IS NOT NULL), '{}'::json) AS weapons" },
            "users.id = ?",
            { identifier }, { ["GROUP BY"] = "users.id", JOIN = "LEFT" },
            "weapons ON weapons.owner = users.id")

        local weapons = {}
        for strIndex, weapon in pairs(user.weapons) do
            weapons[tonumber(strIndex)] = weapon
        end

        Spectrum.players[tostring(playerId)] = {
            id = user.id,
            money = {
                clean = user.clean_money,
                dirty = user.dirty_money
            },
            position = user.position,
            ped = user.ped,
            attributes = user.attributes,
            staff = user.staff,
            items = user.inventory,
            ammo = user.ammo,
            weapons = weapons,
            skin = user.skin
        }

        TriggerClientEvent("Spectrum:PlayerData", playerId, Spectrum.players[tostring(playerId)],
            { debug = Spectrum.debug })
        TriggerClientEvent("Spectrum:Items", playerId, Spectrum.items)
        TriggerClientEvent("Spectrum:Jobs", playerId, Spectrum.jobs)
        TriggerClientEvent("Spectrum:Stores", playerId, Spectrum.stores)
    end
    Spectrum.loaded = true

    Citizen.CreateThread(function()
        while true do
            Wait(15000)
            for source, playerData in pairs(Spectrum.players) do
                Spectrum.players[source].position = GetEntityCoords(GetPlayerPed(source))
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Wait(60000 * 3)
            for source, playerData in pairs(Spectrum.players) do
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
            for weaponId, weaponData in pairs(Spectrum.weapons) do
                exports["pgcfx"]:update("weapons", { "attachments" }, { weaponData.attachments }, "id = ?", { weaponId })
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

        local weapons = {}
        for strIndex, weapon in pairs(user.weapons) do
            weapons[tonumber(strIndex)] = weapon
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
                attributes = user.attributes,
                staff = user.staff,
                items = user.inventory,
                ammo = user.ammo,
                weapons = weapons,
                skin = user.skin
            }

            TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[source], { debug = Spectrum.debug })
            TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
            TriggerClientEvent("Spectrum:Jobs", source, Spectrum.jobs)
            TriggerClientEvent("Spectrum:Stores", source, Spectrum.stores)
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
