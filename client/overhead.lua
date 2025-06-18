DrawingOverhead = false
local gamertags = {}

function createOverhead(player)
    local p = {
        tag = CreateFakeMpGamerTag(GetPlayerPed(player),
            (Spectrum.PlayerData.staff >= Config.Permissions.Staff and (GetPlayerName(player) .. " " ..
                "(ID: " .. GetPlayerServerId(player) .. ")") or tostring(GetPlayerServerId(player))), false, false, "", 0),
        ped = GetPlayerPed(player),
        serverId = tostring(GetPlayerServerId(player))
    }
    if Spectrum.PlayerData.staff >= Config.Permissions.Trial then
        if Spectrum.players[p.serverId].staff > 0 then
            SetMpGamerTagVisibility(p.tag, 5, true)
        end
    end
    SetMpGamerTagAlpha(p.tag, 4, 255)
    return p
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if Spectrum.PlayerData.staff >= Config.Permissions.Staff and Spectrum.StaffMenu.spectating and DrawingOverhead then
            goto bypass
        end
        for player, tag in pairs(gamertags) do
            if not DrawingOverhead or not IsMpGamerTagActive(tag.tag) or not DoesEntityExist(tag.ped) or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(tag.ped)) > 5 or not HasEntityClearLosToEntity(PlayerPedId(), tag.ped, 17) or Spectrum.players[tag.serverId].spectating then
                if IsMpGamerTagActive(tag.tag) then
                    RemoveMpGamerTag(tag.tag)
                end
                gamertags[player] = nil
            end
        end
        ::bypass::
        if DrawingOverhead then
            for _, player in ipairs(GetActivePlayers()) do
                if not gamertags[player] then
                    if (Spectrum.PlayerData.staff >= Config.Permissions.Staff and Spectrum.StaffMenu.spectating) or (#(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(player))) <= 5 and HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(player), 17) and not Spectrum.players[tostring(GetPlayerServerId(player))].spectating) then
                        gamertags[player] = createOverhead(player)
                    end
                end
                if gamertags[player] then
                    SetMpGamerTagVisibility(gamertags[player].tag, 4, NetworkIsPlayerTalking(player))
                end
            end
        end
    end
end)
