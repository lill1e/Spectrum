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

            -- TODO: fix this when skin implemented
            -- while not Spectrum.Spawned and not Spectrum.PlayerData.skin do Wait(0) end

            local coords = vector3(0, 0, 75)
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

            Wait(2500)

            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()

            FreezeEntityPosition(PlayerPedId(), false)

            DoScreenFadeIn(500)
            while not IsScreenFadedIn() do Wait(0) end

            Spectrum.Spawned = true
        end

        if IsEntityDead(PlayerPedId()) and not Spectrum.DeathTimer then
            Spectrum.DeathTimer = GetGameTimer()
        elseif not IsEntityDead(PlayerPedId()) and Spectrum.DeathTimer then
            Spectrum.DeathTimer = nil
            Spectrum.CanRespawn = false
            Spectrum.CanRevive = false
        end
    end
end)
