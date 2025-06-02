for _, garage in pairs(Config.Garage.Garages) do
    if garage.blip == nil or not garage.public then
        goto continue
    end
    local blip = AddBlipForCoord(garage.position)
    if garage.blip.sprite then
        SetBlipSprite(blip, garage.blip.sprite)
    end
    if garage.blip.colour then
        SetBlipColour(blip, garage.blip.colour)
    end
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Garage (Public)")
    EndTextCommandSetBlipName(blip)
    ::continue::
end

local garageMenu = RageUI.CreateMenu("Garage", "vroom")

function RageUI.PoolMenus:Garage()
    garageMenu:IsVisible(function(Items)
        for plate, vehicle in pairs(Spectrum.vehicles) do
            Items:AddButton(
                Config.Vehicles.Names[GetHashKey(vehicle.vehicle)] ..
                ((not vehicle.active and vehicle.garage and vehicle.garage ~= Spectrum.Garage.current) and (" ~b~(" .. Config.Garage.Garages[vehicle.garage].displayName .. ")") or ""),
                "License Plate: ~y~" .. plate,
                { IsDisabled = (vehicle.garage and vehicle.garage ~= Spectrum.Garage.current) or vehicle.active },
                function(onSelected)
                    if onSelected then
                        Spectrum.libs.Callbacks.callback("verifyVehicle", function(verified)
                            if verified then
                                RageUI.Visible(garageMenu, false)
                                Spectrum.vehicles[plate].active = true
                                RequestModel(vehicle.vehicle)
                                while not HasModelLoaded(vehicle.vehicle) do
                                    Wait(0)
                                end
                                local handle = CreateVehicle(vehicle.vehicle, GetEntityCoords(PlayerPedId()),
                                    GetEntityHeading(PlayerPedId()), true, false)
                                while not DoesEntityExist(handle) do
                                    Wait(0)
                                end
                                SetVehicleNumberPlateText(handle, plate)
                                SetVehicleCustomPrimaryColour(handle, 255, 146, 230)
                                TaskWarpPedIntoVehicle(PlayerPedId(), handle, -1)
                            end
                        end, vehicle.vehicle, plate)
                    end
                end)
        end
    end, function(Panels)

    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if Spectrum.Garage.current ~= nil and not RageUI.Visible(garageMenu) then
            Spectrum.Garage.current = nil
        end
        for k, garage in pairs(Config.Garage.Garages) do
            if #(GetEntityCoords(PlayerPedId()) - garage.position) <= garage.range then
                if IsPedInAnyVehicle(PlayerPedId(), false) and Spectrum.vehicles then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local plate = GetVehicleNumberPlateText(vehicle)
                    if Spectrum.vehicles[plate] then
                        HelpText("Press ~INPUT_CONTEXT~ to store your ~b~" ..
                            Config.Vehicles.Names[GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false))])
                        if IsControlJustPressed(0, 51) then
                            Spectrum.libs.Callbacks.callback("verifyVehiclePlate", function(verified)
                                if verified then
                                    TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
                                    DeleteVehicle(vehicle)
                                    Spectrum.vehicles[plate].active = false
                                    Spectrum.vehicles[plate].garage = k
                                end
                            end, plate, k)
                        end
                    else
                        HelpText("~r~You can only store owned vehicles in the garage")
                    end
                elseif not IsPedInAnyVehicle(PlayerPedId(), false) then
                    if Spectrum.Garage.current == nil then
                        HelpText("Press ~INPUT_CONTEXT~ to view ~b~" .. garage.displayName .. " ~s~(Garage)")
                        if IsControlJustPressed(0, 51) then
                            Spectrum.Garage.current = k
                            garageMenu:SetTitle(garage.displayName)
                            garageMenu:SetSubtitle("Vehicles: " .. Spectrum.vehicleCount)
                            RageUI.Visible(garageMenu, true)
                        end
                    elseif IsControlJustPressed(0, 51) then
                        Spectrum.Garage.current = nil
                        RageUI.Visible(garageMenu, false)
                    end
                end
            elseif RageUI.Visible(garageMenu) and Spectrum.Garage.current == k then
                RageUI.Visible(garageMenu, false)
            end
        end
    end
end)
