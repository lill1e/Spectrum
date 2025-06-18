local interactionMenu = RageUI.CreateMenu("Interaction", "~y~Handy Dandy")
local selfMenu = RageUI.CreateSubMenu(interactionMenu, "Interaction", "~b~Self")
local jobsMenu = RageUI.CreateSubMenu(selfMenu, "Interaction", "~o~Jobs")

RegisterKeyMapping("+interaction", "Interaction Menu", "keyboard", "m")
RegisterCommand("+interaction", function()
    if Spectrum.Loaded and not Spectrum.PlayerData.dead and not Spectrum.StaffMenu.spectating then
        RageUI.Visible(interactionMenu, not RageUI.Visible(interactionMenu))
    end
end, false)
RegisterCommand("-interaction", function() end, false)

function RageUI.PoolMenus:Interaction()
    interactionMenu:IsVisible(function(Items)
        Items:AddButton("~b~Self", nil, { RightLabel = "→→→" }, function()

        end, selfMenu)
        Items:CheckBox("Show IDs", "Useful for reporting players", DrawingOverhead, {}, function(onSelected, Checked)
            if onSelected then
                DrawingOverhead = Checked
            end
        end)
        Items:AddSeparator("")
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
                                StorageMenu:SetSubtitle("Space: " .. data.space)
                                RageUI.Visible(StorageMenu, true)
                            else
                                Notification("This ~b~storage ~s~is occupied")
                            end
                        end, plate, true, GetVehicleClass(handle))
                    else
                        Notification("Please be near a ~b~vehicle ~s~to perform this")
                    end
                end
            end)
    end, function()

    end)
    selfMenu:IsVisible(function(Items)
        Items:AddButton("Server ID", nil, { RightLabel = "ID: " .. GetPlayerServerId(PlayerId()) }, function()

        end)
        Items:AddButton("Current Employment", nil,
            { RightLabel = ((Spectrum.Job.current == nil or Config.Jobs[Spectrum.Job.current] == nil or Config.Jobs[Spectrum.Job.current].shadow) and "Unemployed" or Config.Jobs[Spectrum.Job.current].displayName) },
            function()

            end)
        Items:AddButton("~o~Jobs", nil, { RightLabel = "→→→" }, function()

        end, jobsMenu)
    end, function()

    end)
    jobsMenu:IsVisible(function(Items)
        for job, rank in pairs(Spectrum.PlayerData.jobs) do
            if Config.Jobs[job] and not Config.Jobs[job].shadow then
                Items:AddButton(Config.Jobs[job].displayName, "Rank: " .. Config.Jobs[job].ranks[rank].displayName, {},
                    function()

                    end)
            end
        end
    end, function()

    end)
end
