local staffMenu = RageUI.CreateMenu("kitty", "OwO")
local selfStaffMenu = RageUI.CreateSubMenu(staffMenu, "kitty", "Self")
local selfDevStaffMenu = RageUI.CreateSubMenu(staffMenu, "kitty", "Self (Dev)")
local inventoryStaffMenu = RageUI.CreateSubMenu(staffMenu, "kitty", "Inventory")
local vehiclesStaffMenu = RageUI.CreateSubMenu(staffMenu, "kitty", "Vehicles")
local playersStaffMenu = RageUI.CreateSubMenu(staffMenu, "kitty", "Players")
local playerStaffMenu = RageUI.CreateSubMenu(playersStaffMenu, "kitty", "Players")
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
        Items:AddButton("Players", "who?", { RightLabel = "→→→" }, function(onSelected)

        end, playersStaffMenu)
        Items:AddButton("Self", "me <3", { RightLabel = "→→→" }, function(onSelected)

        end, selfStaffMenu)
        Items:AddButton("Self (Dev)", "f8", { RightLabel = "→→→" }, function(onSelected)

        end, selfDevStaffMenu)
        Items:AddButton("Inventory", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, inventoryStaffMenu)
        Items:AddButton("Vehicles", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, vehiclesStaffMenu)
        Items:AddButton("reskin", "fresh slate", { RightBadge = RageUI.BadgeStyle.Clothes }, function(onSelected)
            if onSelected then
                Spectrum.skin.IsEditing = true
            end
        end)
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
        for id, playerData in pairs(Spectrum.players) do
            Items:AddButton("[" .. id .. "] " .. playerData.name, playerData.id, {}, function(onSelected)
                if onSelected then
                    playerStaffMenu:SetTitle(playerData.name)
                    playerStaffMenu:SetSubtitle("ID: " .. id)
                end
            end, playerStaffMenu)
        end
    end, function()

    end)

    playerStaffMenu:IsVisible(function(Items)

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
        Items:AddSeparator("")
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
