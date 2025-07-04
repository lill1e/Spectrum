RegisterNetEvent("Spectrum:PlayerData", function(player_data, misc)
    if not Spectrum.Loaded then
        Spectrum.Loaded = true
        Spectrum.PlayerData = player_data
        Spectrum.PlayerData.numItems = TableLength(Spectrum.PlayerData.items)
        Spectrum.PlayerData.numWeapons = TableLength(Spectrum.PlayerData.weapons)
        for k, v in pairs(misc) do
            Spectrum[k] = v
        end
    end
end)

RegisterNetEvent("Spectrum:Items", function(items)
    Spectrum.items = items
end)

RegisterNetEvent("Spectrum:Jobs", function(jobs)
    Spectrum.jobs = jobs
end)

RegisterNetEvent("Spectrum:Stores", function(stores)
    Spectrum.stores = stores
end)

RegisterNetEvent("Spectrum:Players", function(players)
    Spectrum.players = players
    for _, player in pairs(players) do
        if player.active then
            Spectrum.activePlayers = Spectrum.activePlayers + 1
        end
    end
end)

RegisterNetEvent("Spectrum:Vehicles", function(vehicles, vehicleCount)
    Spectrum.vehicles = vehicles
    Spectrum.vehicleCount = vehicleCount
end)

RegisterNetEvent("Spectrum:Properties", function(properties)
    Spectrum.properties = properties
end)

RegisterNetEvent("Spectrum:Outfits", function(outfits)
    Spectrum.outfits = outfits
end)

RegisterNetEvent("Spectrum:Broadcast", function(t, token)
    Spectrum.libs.Callbacks.callback("verifyToken", function(verified)
        if verified then
            if t == 0 then
                ApplyDamageToPed(PlayerPedId(), 200, false)
            elseif t == 1 then
                Spectrum.CanRevive = true
            end
        end
    end, token)
end)

RegisterNetEvent("Spectrum:Player:Join", function(id, data)
    Spectrum.players[id] = data
    Spectrum.activePlayers = 0
    for _, player in pairs(Spectrum.players) do
        if player.active then
            Spectrum.activePlayers = Spectrum.activePlayers + 1
        end
    end
end)

RegisterNetEvent("Spectrum:Player:Drop", function(id, reason)
    Spectrum.players[id].active = false
    Spectrum.players[id].dropReason = reason
    Spectrum.activePlayers = 0
    for _, player in pairs(Spectrum.players) do
        if player.active then
            Spectrum.activePlayers = Spectrum.activePlayers + 1
        end
    end
end)

RegisterNetEvent("Spectrum:Player:ToggleS", function(id, s)
    if Spectrum.players[id] then
        Spectrum.players[id].spectating = s
    end
end)

RegisterNetEvent("Spectrum:Warp", function(token, coords, checkGround)
    Spectrum.libs.Callbacks.callback("verifyToken", function(verified)
        if verified then
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Wait(0) end

            if checkGround then
                for z = 1, 1000 do
                    SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, z + 0.0)
                    local ground, _ = GetGroundZFor_3dCoord(coords.x, coords.y, z + 0.0)
                    if ground then
                        break
                    end
                end
            else
                SetPedCoordsKeepVehicle(PlayerPedId(), coords)
            end

            DoScreenFadeIn(500)
            while not IsScreenFadedIn() do Wait(0) end
        end
    end, token)
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if PlayerPedId() and PlayerPedId() ~= -1 and (NetworkIsPlayerActive(PlayerId()) and (Spectrum.DeathTimer and (Spectrum.CanRespawn or Spectrum.CanRevive)) or (Spectrum.Loaded and not Spectrum.Spawned)) then
            while Spectrum.DeathTimer and GetGameTimer() - Spectrum.DeathTimer < 5000 do Wait(0) end
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Wait(0) end

            RequestModel(Spectrum.PlayerData.ped)


            while not HasModelLoaded(Spectrum.PlayerData.ped) do
                RequestModel(Spectrum.PlayerData.ped)
                Wait(0)
            end

            SetPlayerModel(PlayerId(), Spectrum.PlayerData.ped)
            SetModelAsNoLongerNeeded(Spectrum.PlayerData.ped)
            SetPedDefaultComponentVariation(PlayerPedId())

            if Spectrum.PlayerData.skin == nil then
                Spectrum.PlayerData.skin = {
                    Sex = math.random(1, 2)
                }
                RandomizeSkin()
                ApplySkin()
                Spectrum.skin.Outfit = false
                Spectrum.skin.IsEditing = true
            else
                ApplySkin()
            end

            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(PlayerPedId(), true, true)

            local coords = Config.Death.Respawn.Locations[1] or vector3(0, 0, 75)
            local currPos = GetEntityCoords(PlayerPedId())
            for _, coord in ipairs(Config.Death.Respawn.Locations) do
                if #(currPos - coord) < #(currPos - coords) then
                    coords = coord
                end
            end
            if Spectrum.CanRevive then coords = GetEntityCoords(PlayerPedId()) end
            if not Spectrum.Spawned then
                coords = Spectrum.PlayerData.position
                coords = vector3(coords.x, coords.y, coords.z)
            end

            SetEntityCoordsNoOffset(PlayerPedId(),
                coords, false, false, true)
            NetworkResurrectLocalPlayer(
                coords,
                GetEntityHeading(PlayerPedId()), 0, false)
            ClearPedTasksImmediately(PlayerPedId())
            ClearPlayerWantedLevel(PlayerId())
            local startTime = GetGameTimer()
            while not HasCollisionLoadedAroundEntity(PlayerPedId()) and GetGameTimer() - startTime < 5000 do Wait(0) end

            for _, v in pairs(Spectrum.PlayerData.weapons) do
                GiveWeaponToPed(PlayerPedId(), GetHashKey(v), 0, false, false)
            end

            for ammo, count in pairs(Spectrum.PlayerData.ammo) do
                SetPedAmmoByType(PlayerPedId(), GetHashKey(ammo), count)
            end

            if Spectrum.PlayerData.health == nil then
                Spectrum.PlayerData.health = Spectrum.PlayerData.skin.Sex == 1 and 200 or 175
            end

            if Spectrum.PlayerData.dead then
                if Spectrum.CanRevive or Spectrum.CanRespawn then
                    Spectrum.PlayerData.dead = false
                    Spectrum.PlayerData.health = GetEntityHealth(PlayerPedId())
                    Spectrum.PlayerData.armor = 0
                    SetEntityHealth(PlayerPedId(), Spectrum.PlayerData.health)
                    SetPedArmour(PlayerPedId(), Spectrum.PlayerData.armor)
                else
                    ApplyDamageToPed(PlayerPedId(), 200, false)
                end
            else
                SetEntityHealth(PlayerPedId(), Spectrum.PlayerData.health)
                SetPedArmour(PlayerPedId(), Spectrum.PlayerData.armor)
            end

            if Spectrum.skin.IsEditing then
                RageUI.Visible(SkinMenu, true)
            end

            Wait(2500)

            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()

            FreezeEntityPosition(PlayerPedId(), false)

            DoScreenFadeIn(500)
            while not IsScreenFadedIn() do Wait(0) end

            Spectrum.Spawned = true
            if Spectrum.AmmoLock then
                Spectrum.AmmoLock = false
            end
        end

        if IsEntityDead(PlayerPedId()) and not Spectrum.DeathTimer and not Spectrum.PlayerData.dead then
            Spectrum.DeathTimer = GetGameTimer()
            Spectrum.PlayerData.dead = true
            TriggerServerEvent("Spectrum:Dead")
            RageUI.CloseAll()
        elseif not IsEntityDead(PlayerPedId()) and Spectrum.DeathTimer then
            Spectrum.DeathTimer = nil
            Spectrum.CanRespawn = false
            Spectrum.CanRevive = false
        end

        if Spectrum.PlayerData.dead and not Spectrum.StaffMenu.spectating and not Spectrum.CanRespawn and not Spectrum.CanRevive then
            local respawnTime = Spectrum.DeathTimer + Config.Death.Respawn
            local canRespawn = GetGameTimer() > respawnTime
            HelpText("Press ~INPUT_CONTEXT~ to ~" ..
                (canRespawn and "g" or "r") .. "~respawn" ..
                canRespawn and ("\n~s~Available in " .. ConvertTime(GetGameTimer())) or "")
            if IsControlJustPressed(0, 51) and canRespawn then
                Spectrum.CanRespawn = true
            end
        end
    end
end)
