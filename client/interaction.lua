local interactionMenu = RageUI.CreateMenu("Interaction", "~y~Handy Dandy")

RegisterKeyMapping("+interaction", "Interaction Menu", "keyboard", "m")
RegisterCommand("+interaction", function()
    if Spectrum.Loaded then
        RageUI.Visible(interactionMenu, not RageUI.Visible(interactionMenu))
    end
end, false)
RegisterCommand("-interaction", function() end, false)

function RageUI.PoolMenus.Interaction()
    interactionMenu:IsVisible(function(Items)
        Items:AddButton("Inspect Vehicle", nil,
            {
                RightLabel = "→→→",
                IsDisabled = not IsPedInAnyVehicle(PlayerPedId(), false) and
                    (GetClosest("CVehicle") == nil)
            },
            function(onSelected)
                if onSelected then
                    local handle = nil
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        handle = GetVehiclePedIsIn(PlayerPedId(), false)
                    else
                        handle = GetClosest("CVehicle")
                    end
                    if handle and DoesEntityExist(handle) then
                        local plate = StripPlate(GetVehicleNumberPlateText(handle))
                        Spectrum.libs.Callbacks.callback("storageSync", function(data)
                            if data ~= nil then
                                Spectrum.Storage = data
                                Spectrum.Storage.active = true
                                Spectrum.Storage.id = plate
                                Spectrum.Storage.handle = handle
                                RageUI.Visible(StorageMenu, true)
                            else
                                Notification("This ~b~storage ~s~is occupied")
                            end
                        end, plate, true)
                    else
                        Notification("Please be near a ~b~vehicle ~s~to perform this")
                    end
                end
            end)
    end, function()

    end)
end
