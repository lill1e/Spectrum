for _, dealership in pairs(Config.Dealership) do
    if dealership.blip then
        local blip = AddBlipForCoord(dealership.location)
        if dealership.blip.sprite then
            SetBlipSprite(blip, dealership.blip.sprite)
        end
        if dealership.blip.colour then
            SetBlipColour(blip, dealership.blip.colour)
        end
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(dealership.displayName)
        EndTextCommandSetBlipName(blip)
    end
end

local currentDealership = nil
local currentVehicleClass = nil
local showcaseHandle = 0
local showcaseModel = nil
local preLoc = nil
local dealershipMenu = RageUI.CreateMenu("Dealership", "~y~Get some new keys")
local vehicleClassMenu = RageUI.CreateSubMenu(dealershipMenu, "Dealership", "~b~Vehicle Class")

function RageUI.PoolMenus:Dealership()
    if currentDealership == nil and RageUI.AnyVisible({ dealershipMenu, vehicleClassMenu }) then
        RageUI.CloseAll()
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityVisible(PlayerPedId(), true, false)
        if preLoc then
            SetEntityCoordsNoOffset(PlayerPedId(), preLoc, false, false, true)
        end
        if showcaseModel then
            showcaseModel = nil
            DeleteEntity(showcaseHandle)
            showcaseHandle = 0
        end
    end
    dealershipMenu:IsVisible(function(Items)
        if not TableContains(Spectrum.PlayerData.licenses, Config.Dealership[currentDealership].license) then
            Items:AddButton("~g~Required License", "You'll need this to purchase a ~b~vehicle",
                { RightLabel = Config.Licenses[Config.Dealership[currentDealership].license].displayName }, function()

                end)
            Items:AddSeparator("")
        end
        if showcaseModel then
            showcaseModel = nil
            DeleteEntity(showcaseHandle)
            showcaseHandle = 0
        end
        for i = 0, 22 do
            local class = Config.Vehicles.Classes[i]
            if Config.Dealership[currentDealership].vehicles[class] and not TableEmpty(Config.Dealership[currentDealership].vehicles[class]) then
                Items:AddButton(class, nil, { RightBadge = RageUI.BadgeStyle.Car }, function(onSelected)
                    if onSelected then
                        currentVehicleClass = class
                    end
                end, vehicleClassMenu)
            end
        end
    end, function()

    end)
    vehicleClassMenu:IsVisible(function(Items)
        if currentDealership and currentVehicleClass and Config.Dealership[currentDealership] and Config.Dealership[currentDealership].vehicles[currentVehicleClass] then
            for vehicle, price in pairs(Config.Dealership[currentDealership].vehicles[currentVehicleClass]) do
                Items:AddButton(Config.Vehicles.Names[GetHashKey(vehicle)], nil,
                    { RightLabel = "~g~$" .. FormatMoney(price) }, function(onSelected, onActive)
                        if onActive and showcaseModel ~= vehicle then
                            showcaseModel = nil
                            DeleteEntity(showcaseHandle)
                            showcaseHandle = 0
                        end
                        if onSelected then
                            if DoesEntityExist(showcaseHandle) then
                                Spectrum.libs.Callbacks.callback("parking", function(index)
                                    if index ~= -1 then
                                        local spot = Config.Dealership[currentDealership].parking[index]
                                        Spectrum.libs.Callbacks.callback("dealershipPurchase", function(plate)
                                            if plate ~= nil then
                                                preLoc = nil
                                                currentDealership = nil
                                                if showcaseModel then
                                                    showcaseModel = nil
                                                    DeleteEntity(showcaseHandle)
                                                    showcaseHandle = 0
                                                end
                                                RequestModel(vehicle)
                                                while not HasModelLoaded(vehicle) do
                                                    Wait(0)
                                                    RequestModel(vehicle)
                                                end
                                                local v = CreateVehicle(vehicle,
                                                    spot[1],
                                                    spot[2], true, false)
                                                SetVehicleNumberPlateText(v, plate)
                                                TaskWarpPedIntoVehicle(PlayerPedId(), v, -1)
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                SetEntityVisible(PlayerPedId(), true, false)
                                            end
                                        end, currentDealership, currentVehicleClass, vehicle)
                                    else
                                        Notification("There are no ~o~parking ~s~spots available, please try again")
                                    end
                                end, Config.Dealership[currentDealership].parking)
                            else
                                RequestModel(vehicle)
                                while not HasModelLoaded(vehicle) do
                                    Wait(0)
                                    RequestModel(vehicle)
                                end
                                local v = CreateVehicle(vehicle, Config.Dealership[currentDealership].showcase[1],
                                    Config.Dealership[currentDealership].showcase[2], false, false)
                                FreezeEntityPosition(v, true)
                                TaskWarpPedIntoVehicle(PlayerPedId(), v, -1)
                                showcaseModel = vehicle
                                showcaseHandle = v
                                Notification("Press again to ~g~purchase ~s~this vehicle")
                            end
                        end
                    end)
            end
        else
            RageUI.GoBack()
        end
    end, function()

    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if showcaseHandle ~= 0 and GetVehiclePedIsIn(PlayerPedId(), false) == showcaseHandle then
            DisableControlAction(0, 75, true)
        end
        for d, dealership in pairs(Config.Dealership) do
            if GetInteriorFromEntity(PlayerPedId()) == dealership.interior and (showcaseHandle or not IsPedInAnyVehicle(PlayerPedId(), false)) then
                if not RageUI.AnyVisible({ dealershipMenu, vehicleClassMenu }) then
                    if currentDealership ~= nil then
                        currentDealership = nil
                        FreezeEntityPosition(PlayerPedId(), false)
                        SetEntityVisible(PlayerPedId(), true, false)
                        if preLoc then
                            SetEntityCoordsNoOffset(PlayerPedId(), preLoc, false, false, true)
                        end
                        if showcaseModel then
                            showcaseModel = nil
                            DeleteEntity(showcaseHandle)
                            showcaseHandle = 0
                        end
                    end
                    HelpText("Press ~INPUT_CONTEXT~ to browse ~b~Vehicles")
                end
                if IsControlJustPressed(0, 51) and IsPlayerActive() then
                    if currentDealership == nil then
                        currentDealership = d
                        RageUI.Visible(dealershipMenu, true)
                        preLoc = GetEntityCoords(PlayerPedId())
                        FreezeEntityPosition(PlayerPedId(), true)
                        SetEntityVisible(PlayerPedId(), false, false)
                        SetEntityCoordsNoOffset(PlayerPedId(), dealership.showcase[1], false, false, true)
                        SetEntityHeading(PlayerPedId(), dealership.showcase[2])
                    else
                        currentDealership = nil
                    end
                end
            elseif currentDealership == d then
                currentDealership = nil
            end
        end
    end
end)
