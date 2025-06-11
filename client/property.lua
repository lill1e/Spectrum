while not Spectrum.Loaded do
    Wait(0)
end

local actionLock = false

for id, property in pairs(Spectrum.properties) do
    if property.owned then
        local blip = AddBlipForCoord(property.position)
        SetBlipSprite(blip, 40)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Property (Owned)")
        EndTextCommandSetBlipName(blip)
    end
end

RegisterNetEvent("Spectrum:Property:Dispatch", function(property, field, state)
    Spectrum.properties[property][field] = state
end)

RegisterNetEvent("Spectrum:Property:Release", function()
    actionLock = false
end)

RegisterNetEvent("Spectrum:Property:Add", function(id, property)
    Spectrum.properties[id] = property
    Spectrum.properties[id].owned = (property.owner == Spectrum.PlayerData.id)
    if Spectrum.properties[id].owned then
        local blip = AddBlipForCoord(property.position)
        SetBlipSprite(blip, 40)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Property (Owned)")
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for id, property in pairs(Spectrum.properties) do
            if #(GetEntityCoords(PlayerPedId()) - property.position) <= 20 then
                if property.owned then
                    DrawMarker(1, property.x, property.y, property.z - 1, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 0.5, 255, 255, 255,
                        100,
                        0,
                        0,
                        0, 0, 0, 0, 0)
                end
                if #(GetEntityCoords(PlayerPedId()) - property.position) <= 0.75 then
                    HelpText(((property.locked and not property.owned) and "This property is ~r~locked~s~" or ("Press ~INPUT_CONTEXT~ to " ..
                            (property.internal and "enter the property" or "view the contents"))) ..
                        (property.owned and ("\nPress ~INPUT_THROW_GRENADE~ to " .. (property.locked and "unlock" or "~o~lock") .. " ~s~the property") or ""))
                    if IsControlJustPressed(0, 51) and (property.owner or not property.locked) then
                        if property.internal then
                            -- TODO: property interiors (concealer)
                        else
                            if Spectrum.Storage.active then
                                RageUI.Visible(StorageMenu, false)
                            else
                                Spectrum.libs.Callbacks.callback("storageSync", function(data)
                                    if data ~= nil then
                                        Spectrum.Storage = data
                                        Spectrum.Storage.active = true
                                        Spectrum.Storage.id = id
                                        Spectrum.Storage.property = property.position
                                        StorageMenu:SetSubtitle("Space: " .. data.space)
                                        RageUI.Visible(StorageMenu, true)
                                    else
                                        Notification("This ~b~storage ~s~is occupied")
                                    end
                                end, id, false)
                            end
                        end
                    elseif IsControlJustPressed(0, 58) and property.owner and not actionLock then
                        actionLock = true
                        TriggerServerEvent("Spectrum:Property:Toggle", id)
                    end
                end
            end
        end
    end
end)
