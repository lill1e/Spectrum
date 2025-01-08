exports["pgcfx"]:ready(function()
    Wait(500)
    for _, playerId in ipairs(GetPlayers()) do
        print(playerId)
        local identifier = GetSteamHex(playerId)
        local user = exports["pgcfx"]:selectOne("Users", {}, "id = ?", { identifier })

        Spectrum.players[tostring(playerId)] = {
            id = user.id,
            money = {
                clean = user.clean_money,
                dirty = user.dirty_money
            },
            position = user.position,
            ped = user.ped,
            attributes = user.attributes,
            staff = user.staff
        }

        print(json.encode(Spectrum.players))
        TriggerClientEvent("Spectrum:PlayerData", playerId, Spectrum.players[tostring(playerId)])
        TriggerClientEvent("Spectrum:Items", playerId, Spectrum.items)
        TriggerClientEvent("Spectrum:JobData", playerId, Spectrum.jobs)
    end
    TriggerEvent("Spectrum:PlayerJoined")
end)

RegisterCommand("req", function(source)
    TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[tostring(source)])
    TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
    TriggerClientEvent("Spectrum:JobData", source, Spectrum.jobs)
end, false)

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
        local user = exports["pgcfx"]:selectOne("Users", {}, "id = ?", { steamHex })
        if user then
            print(json.encode(user))
            -- should i create this on join or just connect attempt? - shiii idk
            Spectrum.players[source] = {
                id = user.id,
                money = {
                    clean = user.clean_money,
                    dirty = user.dirty_money
                },
                position = user.position,
                ped = user.ped,
                attributes = user.attributes,
                staff = user.staff
            }

            -- maybe make items and other critical implementations
            TriggerClientEvent("Spectrum:PlayerData", source, Spectrum.players[source])
            TriggerClientEvent("Spectrum:Items", source, Spectrum.items)
            TriggerClientEvent("Spectrum:JobData", source, Spectrum.jobs)
            -- figure out how to handle jobs/attributes
            -- attributes: maybe keep a db of attributes and corresponding users - easy add/deletion
            -- ^^ now this is just fucking stupid
            -- jobs: maybe some sort of map in the database (especially seeing how the json type works)
        else
            DropPlayer(source, "There was an error fetching your data, please reconnect and try again")
        end
    else
        DropPlayer(source, "There was an error fetching your data, please reconnect and try again")
    end
end)
