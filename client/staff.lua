local staffMenu = RageUI.CreateMenu("agony", "~o~*spiderman quote goes here*")
local selfStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Self")
local selfDevStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Self (Dev)")
local inventoryStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Inventory")
local vehiclesStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Vehicles")
local playersStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Players")
local playerStaffMenu = RageUI.CreateSubMenu(playersStaffMenu, "agony", "Players")
local detailsMenu = RageUI.CreateSubMenu(staffMenu)
local detail = nil

RegisterKeyMapping("+staff", "Staff Menu", "keyboard", "f5")
RegisterCommand("+staff", function()
    if Spectrum.Loaded and (Spectrum.PlayerData.staff > 0 or Spectrum.debug) then
        RageUI.Visible(staffMenu, not RageUI.Visible(staffMenu))
    end
end, false)
RegisterCommand("-staff", function() end, false)

function RageUI.PoolMenus:Staff()
    staffMenu:IsVisible(function(Items)
        Items:AddButton("Players (Connected)", "who?", { RightLabel = "→→→" }, function(onSelected)
            Spectrum.StaffMenu.playerType = 1
        end, playersStaffMenu)
        Items:AddButton("Players (Disconnected)", "f8?", { RightLabel = "→→→" }, function(onSelected)
            Spectrum.StaffMenu.playerType = 2
        end, playersStaffMenu)
        Items:AddButton("Self", "me <3", { RightLabel = "→→→" }, function(onSelected)

        end, selfStaffMenu)
        Items:AddButton("Self (Dev)", "f8", { RightLabel = "→→→" }, function(onSelected)

        end, selfDevStaffMenu)
        Items:AddButton("Inventory", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, inventoryStaffMenu)
        Items:AddButton("Vehicles", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, vehiclesStaffMenu)
    end, function()

    end)

    selfStaffMenu:IsVisible(function(Items)
        Items:AddButton("Respawn", "loser", { RightLabel = "💔" }, function(onSelected)
            if onSelected then
                Spectrum.CanRespawn = true
            end
        end)
        Items:AddButton("Revive", "Heroes never die!", { RightLabel = "⛑️" }, function(onSelected)
            if onSelected then
                Spectrum.CanRevive = true
            end
        end)
        Items:AddButton("kys", "kurt cobain?", { RightLabel = "💀" }, function(onSelected)
            if onSelected then
                SetEntityHealth(PlayerPedId(), 150)
            end
        end)
        Items:AddButton("Spawn Vehicle", "vroom vroom", { RightLabel = "🏁" }, function(onSelected)
            if onSelected then
                RequestModel("bmx")
                while not HasModelLoaded("bmx") do
                    Citizen.Wait(0)
                end
                TaskWarpPedIntoVehicle(PlayerPedId(),
                    CreateVehicle(GetHashKey("bmx"), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()),
                        true, false), -1)
            end
        end)
        Items:AddButton("reskin", "fresh slate", { RightBadge = RageUI.BadgeStyle.Clothes }, function(onSelected)
            if onSelected then
                Spectrum.skin.IsEditing = true
            end
        end)
    end, function()

    end)

    selfDevStaffMenu:IsVisible(function(Items)
        Items:AddButton("Coordinates", "F8 to view", { RightLabel = "🗺️" }, function(onSelected)
            if onSelected then
                print(GetEntityCoords(PlayerPedId()))
            end
        end)
        Items:AddButton("Audit Indetifiers", "ooh what's that we got there", { RightLabel = "📋" }, function(onSelected)
            if onSelected then
                for _, identifier in ipairs(Spectrum.PlayerData.identifiers) do
                    print(identifier)
                end
            end
        end)
    end, function()

    end)

    playersStaffMenu:IsVisible(function(Items)
        Items:AddButton("Search", "Inspector Gadget", {}, function(onSelected)
            if onSelected then
                local input = Input("ID:")
                if input and tonumber(input) then
                    local playerData = Spectrum.players[input]
                    if playerData then
                        Spectrum.StaffMenu.target = input
                        playerStaffMenu:SetTitle(playerData.name)
                        playerStaffMenu:SetSubtitle("ID: " .. input)
                        RageUI.Visible(playerStaffMenu, true)
                    else
                        Notification("Please enter a valid ~b~ID")
                    end
                end
            end
        end)
        Items:AddSeparator("")
        for id, playerData in pairs(Spectrum.players) do
            if (Spectrum.StaffMenu.playerType == 1 and playerData.active) or (Spectrum.StaffMenu.playerType == 2 and not playerData.active) then
                Items:AddButton("[" .. id .. "] " .. playerData.name, playerData.id, {}, function(onSelected)
                    if onSelected then
                        Spectrum.StaffMenu.target = id
                        playerStaffMenu:SetTitle(playerData.name)
                        playerStaffMenu:SetSubtitle("ID: " .. id)
                    end
                end, playerStaffMenu)
            end
        end
    end, function()

    end)

    playerStaffMenu:IsVisible(function(Items)
        Items:AddButton("Smite", "Zap!!", {}, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:Smite", Spectrum.StaffMenu.target)
            end
        end)
        Items:AddButton("Revive", "Heroes never die!", {}, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:Revive", Spectrum.StaffMenu.target)
            end
        end)
        Items:AddButton("Teleport (To)", "Me -> Them", {}, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:Teleport", 1, Spectrum.StaffMenu.target)
            end
        end)
        Items:AddButton("Teleport (From)", "Them -> Me", {}, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:Teleport", 2, Spectrum.StaffMenu.target)
            end
        end)
        Items:AddButton("Grant Vehicle", "Shiny", {}, function(onSelected)
            if onSelected then
                local vehicle = Input("Vehicle:")
                if vehicle and Config.Vehicles.Names[GetHashKey(vehicle)] then
                    TriggerServerEvent("Spectrum:Garage:Grant", Spectrum.StaffMenu.target, vehicle)
                else
                    Notification("Please enter a valid ~b~Vehicle Model")
                end
            end
        end)
        Items:AddButton("Revoke Vehicle", "there goes poof", {}, function(onSelected)
            if onSelected then
                local vehicle = Input("Vehicle (Plate):")
                if vehicle then
                    TriggerServerEvent("Spectrum:Garage:Revoke", Spectrum.StaffMenu.target, PadPlate(vehicle:upper()))
                end
            end
        end)
    end, function(Panels)

    end)

    inventoryStaffMenu:IsVisible(function(Items)
        Items:AddButton("~g~Add Cash", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amount of Cash (clean):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Add", "clean_cash", nil, tonumber(input))
                end
            end
        end)
        Items:AddButton("~r~Add Cash", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amount of Cash (dirty):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Add", "dirty_cash", nil, tonumber(input))
                end
            end
        end)
        Items:AddButton("~b~Add Item", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Item:")
                if input then
                    local item = input
                    input = Input("Quantity:")
                    if input and tonumber(input) then
                        TriggerServerEvent("Spectrum:Staff:Add", "item", item, tonumber(input))
                    end
                end
            end
        end)
        Items:AddButton("~o~Add Weapon", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Weapon:")
                if input then
                    TriggerServerEvent("Spectrum:Staff:Add", "weapon", input, 0)
                end
            end
        end)
        Items:AddButton("~y~Add Ammo", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Ammo Type:")
                if input then
                    local item = input
                    input = Input("Quantity:")
                    if input and tonumber(input) then
                        TriggerServerEvent("Spectrum:Staff:Add", "ammo", item, tonumber(input))
                    end
                end
            end
        end)
        Items:AddSeparator("")
        Items:AddButton("~g~Remove Cash", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amount of Cash (clean):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Remove", "clean_cash", nil, tonumber(input))
                end
            end
        end)
        Items:AddButton("~r~Remove Cash", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amount of Cash (dirty):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Remove", "dirty_cash", nil, tonumber(input))
                end
            end
        end)
        Items:AddButton("~b~Remove Item", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Item:")
                if input then
                    local item = input
                    input = Input("Quantity:")
                    if input and tonumber(input) then
                        TriggerServerEvent("Spectrum:Staff:Remove", "item", item, tonumber(input))
                    end
                end
            end
        end)
        Items:AddButton("~o~Remove Weapon", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Weapon (Serial):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Remove", "weapon", tonumber(input), 0)
                end
            end
        end)
        Items:AddButton("~y~Remove Ammo", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Ammo Type:")
                if input then
                    local item = input
                    input = Input("Quantity:")
                    if input and tonumber(input) then
                        TriggerServerEvent("Spectrum:Staff:Remove", "ammo", item, tonumber(input))
                    end
                end
            end
        end)
    end, function()

    end)

    vehiclesStaffMenu:IsVisible(function(Items)
        Items:AddButton("Restore Vehicle", "this vehicle should not be present", { RightBadge = RageUI.BadgeStyle.Car },
            function(onSelected)
                if onSelected then
                    local plate = Input("Vehicle License Plate:"):upper()
                    if plate then
                        Spectrum.libs.Callbacks.callback("restoreVehicle", function(verified)
                            if verified then
                                Notification("~b~" .. plate .. " ~s~was sent back to the most recent garage")
                            else
                                Notification("Please provide a valid ~b~License Plate")
                            end
                        end, plate)
                    end
                end
            end)
        Items:AddButton("Delete Vehicle", "Command: ~b~/dv", { RightBadge = RageUI.BadgeStyle.Car }, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:DeleteVehicle")
            end
        end)
    end, function()

    end)

    detailsMenu:IsVisible(function(Items)
        if not detail then
            RageUI.CloseAll()
            return
        end

        for _, identifier in ipairs(Spectrum.PlayerData.identifiers) do
            Items:AddButton(identifier, nil, {}, function(onSelected)

            end)
        end
    end, function()

    end)
end
