local maxPlayers = 0
RegisterNetEvent("Spectrum:Players:Max", function(count)
    maxPlayers = count
end)

while not Spectrum.Loaded do
    Wait(0)
end
DrawingPlayerlist = false
local doingOverhead = false
local startedAt = 0
local page = 1
local pages = 1
local playersPerPage = 16
local playerlist = {}

local scaleform = Scaleform.Load("MP_MM_CARD_FREEMODE")
scaleform:Call("SET_TITLE", "Players: " .. NetworkGetNumConnectedPlayers() .. "/" .. maxPlayers,
    "(" .. page .. "/" .. pages .. ")", 5)
for i = 0, 31 do
    scaleform:Call("SET_DATA_SLOT_EMPTY", i)
end

function rightSide(id)
    if Spectrum.players[id].spectating then
        return 66, ""
    elseif tonumber(id) and GetPlayerFromServerId(tonumber(id)) then
        local player = GetPlayerFromServerId(tonumber(id))
        if NetworkIsPlayerActive(player) then
            local ped = GetPlayerPed(player)
            if IsEntityDead(ped) then
                return 116, ""
            end
        end
    end
    return 65, id
end

function pagesCalculate()
    pages = math.ceil(Spectrum.activePlayers / playersPerPage)
    for i = 0, 1024 do
        UnregisterPedheadshot(i)
    end
    for id, player in pairs(Spectrum.players) do
        if player.active then
            local headshot = ""
            local playerId = GetPlayerFromServerId(tonumber(id))
            local ped = GetPlayerPed(playerId)
            if DoesEntityExist(ped) then
                local handle = RegisterPedheadshot(ped)

                while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
                    handle = RegisterPedheadshot(ped)
                    Wait(0)
                end

                headshot = GetPedheadshotTxdString(handle)
            end
            local rightIcon, rightText = rightSide(id)
            playerlist[id] = {
                name = player.name,
                staff = player.staff > 0,
                headshot = headshot,
                rightIcon = rightIcon,
                rightText = rightText
            }
        end
    end
end

function drawRow(index, id)
    if playerlist[id] then
        local player = playerlist[id]
        scaleform:Call("SET_DATA_SLOT", index, player.rightText, player.name .. " (ID: " .. id .. ")", 111,
            player.rightIcon, "", "", (player.staff and "..+mod" or ""), 0,
            player.headshot,
            player.headshot, " ")
    end
end

function pageCalculate()
    local c = 0
    for id, player in pairs(playerlist) do
        if c >= ((page - 1) * playersPerPage) and c < page * playersPerPage then
            drawRow(c % playersPerPage, id)
        end
        c = c + 1
    end
    scaleform:Call("DISPLAY_VIEW")
end

function pageRecalculate()
    local c = 0
    local change = false
    for id, player in pairs(playerlist) do
        if c >= ((page - 1) * playersPerPage) and c < page * playersPerPage then
            local rightSideIcon, rightSideText = rightSide(id)
            if rightSideIcon ~= player.rightIcon or rightSideText ~= player.rightText then
                change = true
                playerlist[id].rightIcon = rightSideIcon
                playerlist[id].rightText = rightSideText
                scaleform:Call("SET_ICON", c % playersPerPage, playerlist[id].rightIcon, playerlist[id].rightText)
            end
        end
        c = c + 1
    end
    if change then
        scaleform:Call("DISPLAY_VIEW")
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if scaleform and DrawingPlayerlist then
            pageRecalculate()
            scaleform:Draw(0.135, 0.315, 0.28, 0.6)
        end
        if GetGameTimer() - startedAt >= 8000 and DrawingPlayerlist then
            DrawingPlayerlist = false
            if doingOverhead then
                doingOverhead = false
                DrawingOverhead = false
            end
            page = 1
        elseif GetGameTimer() - startedAt >= 8000 and doingOverhead then
            doingOverhead = false
            DrawingOverhead = false
        end
    end
end)

RegisterKeyMapping("+playerlist", "Player List", "keyboard", "z")
RegisterCommand("+playerlist", function()
    if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
        if DrawingPlayerlist then
            if page == pages then
                DrawingPlayerlist = false
                if doingOverhead then
                    doingOverhead = false
                    DrawingOverhead = false
                end
            else
                page = page + 1
                pagesCalculate()
                pageCalculate()
            end
        else
            pagesCalculate()
            pageCalculate()
            DrawingPlayerlist = true
            if not DrawingOverhead then
                doingOverhead = true
                DrawingOverhead = true
            end
            startedAt = GetGameTimer()
        end
    elseif not DrawingOverhead then
        doingOverhead = true
        DrawingOverhead = true
        startedAt = GetGameTimer()
    elseif DrawingOverhead then
        doingOverhead = false
        DrawingOverhead = false
    end
end, false)
RegisterCommand("-playerlist", function() end, false)

RegisterNetEvent("Spectrum:Player:Join", function(_, _)
    pagesCalculate()
    pageCalculate()
end)

RegisterNetEvent("Spectrum:Player:Drop", function(id, _)
    playerlist[id] = nil
    pageCalculate()
end)
