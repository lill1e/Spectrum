exports["pgcfx"]:ready(function()
    Wait(500)
    local rawWeapons = exports["pgcfx"]:select("Weapons", { "id", "(to_jsonb(weapons) - 'id') AS data" }, nil, nil,
        { ["GROUP BY"] = "id" })
    for _, v in ipairs(rawWeapons) do
        Spectrum.weapons[v.id] = v.data
    end
    for _, playerId in ipairs(GetPlayers()) do
        local identifier = GetSteamHex(playerId)
        local user = exports["pgcfx"]:selectOne("Users", { "users.*", "json_agg(weapons) AS weapons" }, "users.id = ?",
            { identifier }, { ["GROUP BY"] = "users.id" },
            "weapons ON weapons.owner = users.id")

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
            weapons = user.weapons
        }

        TriggerClientEvent("Spectrum:PlayerData", playerId, Spectrum.players[tostring(playerId)])
        TriggerClientEvent("Spectrum:Items", playerId, Spectrum.items)
        TriggerClientEvent("Spectrum:JobData", playerId, Spectrum.jobs)
    end
    TriggerEvent("Spectrum:PlayerJoined")

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
            print("tmp")
            print(json.encode(Spectrum.players))
            for _, playerData in pairs(Spectrum.players) do
                print(json.encode(playerData))
                print(json.encode(playerData.position))
                print(json.encode(playerData.ammo))
                exports["pgcfx"]:update("users", { "clean_money", "dirty_money", "position", "inventory", "ammo" },
                    { playerData.money.clean, playerData.money.dirty,
                        {
                            x = playerData.position.x,
                            y = playerData.position.y,
                            z = playerData.position.z
                        },
                        playerData.items, playerData.ammo }, "id = ?", { playerData.id })
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
        local user = exports["pgcfx"]:selectOne("Users", { "users.*", "json_agg(weapons) AS weapons" }, "users.id = ?",
            { steamHex }, { ["GROUP BY"] = "users.id" },
            "weapons ON weapons.owner = users.id")
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
                weapons = user.weapons
            }

            TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[source])
            TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
            TriggerClientEvent("Spectrum:JobData", source, Spectrum.jobs)
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
        exports["pgcfx"]:update("users", { "clean_money", "dirty_money", "position", "inventory", "ammo" },
            { Spectrum.players[source].money.clean, Spectrum.players[source].money.dirty, {
                x = Spectrum.players[source].position.x,
                y = Spectrum.players[source].position.y,
                z = Spectrum.players[source].position.z
            }, Spectrum.players[source].items, Spectrum.players[source].ammo })
    end
end)
