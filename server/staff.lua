RegisterNetEvent("Spectrum:Staff:Add", function(type, item, count, target)
    local source = tostring(source)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Developer then
        if type == "clean_cash" then
            AddCash(player, true, true, count)
        elseif type == "dirty_cash" then
            AddCash(player, true, false, count)
        elseif type == "bank" then
            AddCash(player, false, true, count)
        elseif type == "item" then
            if HasItemSpace(player, item, count) then
                AddItem(player, item, count)
            end
        elseif type == "weapon" then
            if not HasWeapon(player, item) then
                AddWeapon(player, CreateWeapon(item), 0)
            end
        elseif type == "ammo" then
            AddAmmo(player, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Remove", function(type, item, count, target)
    local source = tostring(source)
    local player = source
    if target then player = tostring(target) end
    if Spectrum.players[source].staff >= Config.Permissions.Developer then
        if type == "clean_cash" then
            RemoveCash(player, true, true, count)
        elseif type == "dirty_cash" then
            RemoveCash(player, true, false, count)
        elseif type == "bank" then
            RemoveCash(player, false, true, count)
        elseif type == "item" then
            RemoveItem(player, item, count)
        elseif type == "weapon" then
            RemoveWeapon(player, item)
        elseif type == "ammo" then
            RemoveAmmo(player, item, count)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Kick", function(target, reason)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] and Spectrum.players[target].active then
            DropPlayer(target,
                "You have been kicked by " ..
                Spectrum.players[source].name .. (reason ~= nil and " (Reason: " .. reason .. ")" or nil))
        end
    end
end)

RegisterNetEvent("Spectrum:Staff:Ban", function(target, reason, days, hours, minutes)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            local expiry = os.time() + (minutes * 60) + (hours * 60 * 60) + (days * 60 * 60 * 24)
            local insertion = exports["pgcfx"]:insert("bans", { "expiry", "reason", "staff", "\"user\"" },
                { expiry, reason, Spectrum.players[source].id, Spectrum.players[target].id })
            print(insertion)
            DropPlayer(target, "\nYou have been banned from this server\nReason: " ..
                (reason ~= nil and reason or "None") ..
                "\nBanned By: " ..
                Spectrum.players[source].name .. "\nExpires At: " .. os.date("%Y-%m-%d %H:%M:%S", expiry) .. "\n")
            if insertion == 0 then
                -- TODO: add logging (failed to fully ban)
            end
            -- TODO: add logging
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Smite", function(target)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 0, Spectrum.libs.Tokens.CreateToken(target))
        else
            Notification(source, "Please smite a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Revive", function(target, maxHealth)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if Spectrum.players[target] then
            TriggerClientEvent("Spectrum:Broadcast", target, 1, Spectrum.libs.Tokens.CreateToken(target))
            Spectrum.players[target].dead = false
            Spectrum.players[target].health = Spectrum.players[target].skin.Sex == 1 and 200 or 175
            Spectrum.players[target].armor = 0
        else
            Notification(source, "Please revive a valid ~b~player")
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:DeleteVehicle", function()
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        local v = GetClosestVehicle(source)
        if v then
            DeleteEntity(v)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:DeleteEntity", function(entity)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        local handle = NetworkGetEntityFromNetworkId(entity)
        if DoesEntityExist(handle) then
            DeleteEntity(handle)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Snowflake", function()
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        if HasWeapon(source, "WEAPON_SNOWBALL") then
            AddAmmo(source, "AMMO_SNOWBALL", 10)
        else
            AddWeapon(source, CreateWeapon("WEAPON_SNOWBALL"), 10)
        end
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:SnowflakeAlt", function()
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        AddWeapon(source, CreateWeapon("WEAPON_SNOWLAUNCHER"), 60)
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:Teleport", function(t, target)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        if t == 1 then
            TriggerClientEvent("Spectrum:Warp", source, Spectrum.libs.Tokens.CreateToken(source),
                GetEntityCoords(GetPlayerPed(target)))
        elseif t == 2 then
            TriggerClientEvent("Spectrum:Warp", target, Spectrum.libs.Tokens.CreateToken(target),
                GetEntityCoords(GetPlayerPed(source)))
        end
    end
end)

RegisterNetEvent("Spectrum:Staff:TeleportCoords", function(coords, waypoint)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        TriggerClientEvent("Spectrum:Warp", source, Spectrum.libs.Tokens.CreateToken(source), coords, waypoint)
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Staff:ToggleSpectate", function(target, status)
    local source = tostring(source)
    target = tostring(target)
    if Spectrum.players[source].staff >= Config.Permissions.Staff then
        Spectrum.players[source].spectating = status
        if Spectrum.players[source].spectating then
            -- TODO: add logging
        end
        TriggerClientEvent("Spectrum:Player:ToggleS", -1, source, Spectrum.players[source].spectating)
    end
end)

RegisterNetEvent("Spectrum:Staff:Report", function(reason, target)
    local source = tostring(source)
    if target then
        target = tostring(target)
        if not Spectrum.players[target] then
            goto bypass
        end
    end
    local id = math.random(999999)
    while Spectrum.reports[id] do
        id = math.random(999999)
    end
    Spectrum.reports[id] = {
        reporter = source,
        reason = reason,
        target = target,
        status = false
    }
    PerformHttpRequest(
        Spectrum.Logs.Reports,
        function() end, "POST",
        json.encode({
            content = "**ID:** " ..
                id ..
                "\n**Reporter:** " ..
                Spectrum.players[source].name .. " (ID: " .. source .. ")" ..
                (target and ("\n**Reported:** " .. Spectrum.players[target].name .. " (ID: " .. target .. ")") or "") ..
                "\n**Reason:** " .. reason
        }), { ["Content-Type"] = "application/json" })
    for _, playerId in ipairs(GetPlayers()) do
        if Spectrum.players[tostring(playerId)].staff then
            TriggerClientEvent("Spectrum:Staff:NewReport", playerId, id, source, reason, target)
        end
    end
    ::bypass::
end)

RegisterNetEvent("Spectrum:Staff:EndReport", function(report)
    local source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        if Spectrum.reports[report] and not Spectrum.reports[report].status then
            Spectrum.reports[report].status = true
            TriggerClientEvent("Spectrum:Staff:ReportEnded", -1, report)
            PerformHttpRequest(
                Spectrum.Logs.Staff,
                function() end, "POST",
                json.encode({
                    content = "**" .. Spectrum.players[source].name .. "** marked report " .. report .. " as resolved"
                }), { ["Content-Type"] = "application/json" })
        end
    end
end)

RegisterCommand("dv", function(source)
    source = tostring(source)
    if Spectrum.players[source].staff >= Config.Permissions.Trial then
        local v = GetClosestVehicle(source)
        if v then
            DeleteEntity(v)
        end
    else
        -- TODO: add logging
    end
end, false)
