while not Spectrum.Loaded do
    Wait(0)
end

local itemsMenu = RageUI.CreateMenu("Job", "Items")
local vehiclesMenu = RageUI.CreateMenu("Job", "Vehicles")
local weaponsLocked = false

for j, job in pairs(Config.Jobs) do
    if job.public or Spectrum.PlayerData.jobs[j] or Spectrum.debug then
        if job.blip then
            for _, loc in pairs(job.locations) do
                local blip = AddBlipForCoord(loc)
                if job.blip.sprite then
                    SetBlipSprite(blip, job.blip.sprite)
                end
                if job.blip.sprite then
                    SetBlipColour(blip, job.blip.colour)
                end
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(job.displayName)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end

function RageUI.PoolMenus:Jobs()
    if not Spectrum.Job.current and RageUI.AnyVisible({ itemsMenu, vehiclesMenu }) then
        RageUI.CloseAll()
    end
    if Spectrum.Job.current then
        if (Spectrum.Job.location == nil or (#(GetEntityCoords(PlayerPedId()) - Config.Jobs[Spectrum.Job.current].locations[Spectrum.Job.location]) > 0.75)) and RageUI.AnyVisible({ itemsMenu, vehiclesMenu }) then
            RageUI.CloseAll()
        end
    end
    itemsMenu:IsVisible(function(Items)
        local weapons = false
        for model, weapon in pairs(Config.Jobs[Spectrum.Job.current].weapons) do
            if weapon.rank == nil or Spectrum.PlayerData.jobs[Spectrum.Job.current] >= weapon.rank then
                if not weapons then weapons = true end
                Items:AddButton(Config.Weapons[model].displayName,
                    (weapon.ammo and ("Rounds: ~b~" .. weapon.ammo) or nil),
                    { RightBadge = RageUI.BadgeStyle.Gun, IsDisabled = HasPedGotWeapon(PlayerPedId(), model, false) },
                    function(onSelected)
                        if onSelected and not weaponsLocked then
                            weaponsLocked = true
                            TriggerServerEvent("Spectrum:Job:Weapon", Spectrum.Job.current, model)
                        end
                    end)
            end
        end
        if weapons then
            Items:AddSeparator("")
        end
        for item, data in pairs(Config.Jobs[Spectrum.Job.current].items) do
            if data.rank == nil or Spectrum.PlayerData.jobs[Spectrum.Job.current] >= data.rank then
                Items:AddButton(Spectrum.items[item].displayName, nil, {}, function(onSelected)
                    if onSelected then
                        TriggerServerEvent("Spectrum:Job:Item", Spectrum.Job.current, item)
                    end
                end)
            end
        end
    end, function()

    end)
    vehiclesMenu:IsVisible(function(Items)
        for vehicle, data in pairs(Config.Jobs[Spectrum.Job.current].vehicles) do
            if Spectrum.Job.vehicle ~= nil then
                Items:AddButton("~o~Park Vehicle", (DoesEntityExist(Spectrum.Job.vehicle) and
                        (#(GetEntityCoords(Spectrum.Job.vehicle) - GetEntityCoords(PlayerPedId())) <= 50)) and nil or
                    "Your ~b~vehicle ~s~must be in range to return it to parking",
                    {
                        IsDisabled = not DoesEntityExist(Spectrum.Job.vehicle) or
                            (#(GetEntityCoords(Spectrum.Job.vehicle) - GetEntityCoords(PlayerPedId())) > 50)
                    }, function(onSelected)
                        if onSelected then
                            SetEntityAsMissionEntity(Spectrum.Job.vehicle, true, true)
                            DeleteVehicle(Spectrum.Job.vehicle)
                            Spectrum.Job.vehicle = nil
                            if DoesBlipExist(Spectrum.Job.vehicleBlip) then
                                RemoveBlip(Spectrum.Job.vehicleBlip)
                            end
                        end
                    end)
            end
            if data.rank == nil or Spectrum.PlayerData.jobs[Spectrum.Job.current] >= data.rank then
                Items:AddButton(Config.Vehicles.Names[GetHashKey(vehicle)], nil,
                    { RightBadge = RageUI.BadgeStyle.Car, IsDisabled = Spectrum.Job.vehicle ~= nil },
                    function(onSelected)
                        if onSelected then
                            Spectrum.libs.Callbacks.callback("parking", function(index)
                                if index ~= -1 then
                                    -- create with spot index
                                    local spot = Config.Jobs[Spectrum.Job.current].parking[Spectrum.Job.location]
                                        [index]
                                    RequestModel(vehicle)
                                    while not HasModelLoaded(vehicle) do
                                        Wait(0)
                                    end
                                    local handle = CreateVehicle(vehicle, spot[1], spot[2], true, true)
                                    while not DoesEntityExist(handle) do
                                        Wait(0)
                                    end
                                    Spectrum.Job.vehicle = handle
                                    local blip = AddBlipForEntity(handle)
                                    SetBlipSprite(blip, 225)
                                    Spectrum.Job.vehicleBlip = blip
                                    DoScreenFadeOut(250)
                                    while not IsScreenFadedOut() do Wait(0) end
                                    TaskWarpPedIntoVehicle(PlayerPedId(), handle, -1)
                                    DoScreenFadeIn(250)
                                    while not IsScreenFadedIn() do Wait(0) end
                                else
                                    Notification("There are no ~o~parking ~s~spots available, please try again")
                                end
                            end, Config.Jobs[Spectrum.Job.current].parking[Spectrum.Job.location])
                        end
                    end)
            end
        end
    end, function()

    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not Spectrum.Job.current and RageUI.Visible(FundMenu) then
            RageUI.CloseAll()
        end
        if Spectrum.Job.current then
            if (Spectrum.Job.location == nil or (#(GetEntityCoords(PlayerPedId()) - Config.Jobs[Spectrum.Job.current].locations[Spectrum.Job.location]) > 0.75)) and RageUI.Visible(FundMenu) then
                RageUI.CloseAll()
            end
        end
        for j, job in pairs(Config.Jobs) do
            for i, loc in pairs(job.locations) do
                if (Spectrum.Job.current == nil or Spectrum.Job.current == j) and not Spectrum.PlayerData.dead and not Spectrum.StaffMenu.spectating then
                    if job.public or Spectrum.PlayerData.jobs[j] or Spectrum.debug then
                        if #(GetEntityCoords(PlayerPedId()) - loc) <= 20 then
                            DrawMarker(1, loc.x, loc.y, loc.z - 1, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 0.5, 255, 255, 255, 100, 0,
                                0,
                                0, 0, 0, 0, 0)
                            if #(GetEntityCoords(PlayerPedId()) - loc) <= 0.75 then
                                HelpText("Press ~INPUT_CONTEXT~ to " ..
                                    (Spectrum.Job.current == j and "stop" or "start") ..
                                    " " ..
                                    ((job.overrideText and job.overrideText.work) and job.overrideText.work or "working as") ..
                                    " " ..
                                    (job.colour and job.colour or "~b~") ..
                                    job.displayName .. "~s~" ..
                                    (Spectrum.Job.current == j and ((TableEmpty(Config.Jobs[j].items) and TableEmpty(Config.Jobs[j].weapons)) and "" or "\nPress ~INPUT_THROW_GRENADE~ to view items/weapons") or "") ..
                                    (Spectrum.Job.current == j and (TableEmpty(Config.Jobs[j].vehicles) and "" or "\nPress ~INPUT_SPECIAL_ABILITY_SECONDARY~ to view vehicles") or "") ..
                                    (Spectrum.Job.current == j and Config.Jobs[j].ranks[Spectrum.PlayerData.jobs[j]].fund and "\nPress ~INPUT_SELECT_CHARACTER_FRANKLIN~ to view the fund" or "") ..
                                    (job.public and "" or ("\nRank: " .. Config.Jobs[j].ranks[Spectrum.PlayerData.jobs[j]].displayName .. " (" .. Spectrum.PlayerData.jobs[j] .. ")")))
                                if Spectrum.Job.current ~= nil then
                                    Spectrum.Job.location = i
                                end
                                if IsControlJustPressed(0, 51) then
                                    if Spectrum.Job.current then
                                        TriggerServerEvent("Spectrum:Job:Toggle", Spectrum.Job.current, false)
                                        TriggerEvent("Spectrum:Job:Terminate", Spectrum.Job.current)
                                        Spectrum.Job.current = nil
                                        Spectrum.Job.state = {}
                                        if Spectrum.Job.vehicle and DoesEntityExist(Spectrum.Job.vehicle) and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(Spectrum.Job.vehicle)) <= 50 then
                                            SetEntityAsMissionEntity(Spectrum.Job.vehicle, true, true)
                                            DeleteVehicle(Spectrum.Job.vehicle)
                                        end
                                        Spectrum.Job.vehicle = nil
                                        if DoesBlipExist(Spectrum.Job.vehicleBlip) then
                                            RemoveBlip(Spectrum.Job.vehicleBlip)
                                        end
                                    else
                                        Spectrum.Job.current = j
                                        Spectrum.Job.state = Config.Jobs[j].defaultState
                                        TriggerServerEvent("Spectrum:Job:Toggle", Spectrum.Job.current, true)
                                        itemsMenu:SetTitle(job.displayName)
                                        vehiclesMenu:SetTitle(job.displayName)
                                    end
                                elseif IsControlJustPressed(0, 58) and Spectrum.Job.current == j and not (TableEmpty(Config.Jobs[j].items) and TableEmpty(Config.Jobs[j].weapons)) then
                                    RageUI.Visible(itemsMenu, not RageUI.Visible(itemsMenu))
                                elseif IsControlJustPressed(0, 29) and Spectrum.Job.current == j and not TableEmpty(Config.Jobs[j].vehicles) then
                                    RageUI.Visible(vehiclesMenu, not RageUI.Visible(vehiclesMenu))
                                end
                            end
                        end
                    end
                end
            end
        end

        if Spectrum.Job.vehicle and Spectrum.Job.vehicleBlip and DoesBlipExist(Spectrum.Job.vehicleBlip) then
            if GetVehiclePedIsIn(PlayerPedId(), false) == Spectrum.Job.vehicle then
                if GetBlipAlpha(Spectrum.Job.vehicleBlip) == 255 then
                    SetBlipAlpha(Spectrum.Job.vehicleBlip, 0)
                end
            else
                if GetBlipAlpha(Spectrum.Job.vehicleBlip) == 0 then
                    SetBlipAlpha(Spectrum.Job.vehicleBlip, 255)
                end
            end
        end
    end
end)

RegisterNetEvent("Spectrum:Job:ReleaseWeapons", function()
    weaponsLocked = false
end)

local menus = {
    Mechanic = MechanicJobMenu,
    BeachDealer = DealerJobMenu,
    MilitaryDealer = DealerJobMenu,
    AsiaDealer = DealerJobMenu,
    MafiaDealer = DealerJobMenu,
    ExclusiveDealer = DealerJobMenu,
}

RegisterKeyMapping("+jobMenu", "Job Menu", "keyboard", "f4")
RegisterCommand("+jobMenu", function()
    if Spectrum.Job.current and menus[Spectrum.Job.current] and not Spectrum.PlayerData.dead and not Spectrum.StaffMenu.spectating then
        RageUI.Visible(menus[Spectrum.Job.current], not RageUI.Visible(menus[Spectrum.Job.current]))
    end
end, false)
RegisterCommand("-jobMenu", function() end, false)
