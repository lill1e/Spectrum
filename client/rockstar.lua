for i = 1, 15 do
    EnableDispatchService(i, false)
end

DisplayCash(false)

-- SetWeaponsNoAutoreload(true)
SetWeaponsNoAutoswap(true)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        ClearPlayerWantedLevel(PlayerId())
        SetMaxWantedLevel(0)

        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        DisablePlayerVehicleRewards(PlayerId())
    end
end)
