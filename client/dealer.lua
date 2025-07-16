local sellLock = false

RegisterNetEvent("Spectrum:Dealer:SellConclusion", function(item, count, payout)
    Notification("You sold x" ..
        count .. " ~o~" .. Spectrum.items[item].displayName .. " ~s~ for ~g~$" .. FormatMoney(payout))
    sellLock = false
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local closest = GetClosestNPC()
        if closest and not sellLock and Spectrum.Job.current == nil then
            local dealItem = nil
            for item, _ in pairs(Config.Drugs.Dealer.Items) do
                if Spectrum.PlayerData.items[item] and Spectrum.PlayerData.items[item] >= 1 then
                    dealItem = item
                end
            end
            if NetworkGetEntityIsNetworked(closest) and dealItem then
                local dealData = Entity(closest).state.deal
                if not dealData then
                    if not IsPedInAnyVehicle(PlayerPedId(), false) and not IsPedInAnyVehicle(closest, false) and not IsPedFleeing(closest) and not IsPedBeingJacked(closest) and not IsPedInCombat(closest, PlayerPedId()) then
                        HelpText("Press ~INPUT_CONTEXT~ to sell ~b~" .. Spectrum.items[dealItem].displayName)
                        if IsControlJustPressed(0, 51) then
                            sellLock = true
                            NetworkRequestControlOfEntity(closest)
                            local t = 0
                            while not NetworkHasControlOfEntity(closest) do
                                Wait(0)
                                t = t + 1
                                if t >= 1500 then
                                    break
                                end
                            end
                            if t >= 1500 then
                                sellLock = false
                                goto skip
                            end
                            Entity(closest).state:set("deal", true, true)
                            local session = GetGameTimer()
                            Entity(closest).state:set("deal_session", session, true)
                            TaskTurnPedToFaceEntity(PlayerPedId(), closest, 500)
                            Wait(500)
                            -- TODO: add emote - synced scene
                            local rollChance = math.random(6)
                            if rollChance > 2 then
                                Notification("The customer is interested in your ~o~product")
                                RequestAnimDict("mp_common")
                                while not HasAnimDictLoaded("mp_common") do Wait(0) end
                                local scene = NetworkCreateSynchronisedScene(
                                    GetOffsetFromEntityInWorldCoords(closest, 0.0, 0.0, -1.0), 0.0, 0.0,
                                    GetEntityHeading(PlayerPedId()), 2, false, false, 8.0, 1000.0, 1.0)
                                NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "mp_common", "givetake1_a", 8.0,
                                    8.0, 0, 0, 1000.0, 0)
                                NetworkAddPedToSynchronisedScene(closest, scene, "mp_common", "givetake1_b", 8.0,
                                    8.0, 0, 0, 1000.0, 0)
                                NetworkStartSynchronisedScene(scene)
                                Spectrum.libs.Callbacks.callback("startT", function(et)
                                    TriggerServerEvent("Spectrum:Dealer:T", dealItem,
                                        NetworkGetNetworkIdFromEntity(closest), et, session)
                                    sellLock = false
                                end, NetworkGetNetworkIdFromEntity(closest), session)
                            else
                                Notification("They were not ~o~satisfied ~s~with what you had to offer")
                                sellLock = false
                            end
                            ::skip::
                        end
                    end
                end
            end
        end
    end
end)
