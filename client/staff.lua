local staffMenu = RageUI.CreateMenu("agony", "~o~*spiderman quote goes here*")
local selfStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Self")
local selfDevStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Self (Dev)")
local inventoryStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Inventory")
local toolsStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Tools")
local playersStaffMenu = RageUI.CreateSubMenu(staffMenu, "agony", "Players")
local playerStaffMenu = RageUI.CreateSubMenu(playersStaffMenu, "agony", "Players")
local playerManageStaffMenu = RageUI.CreateSubMenu(playerStaffMenu, "agony", "Player Management")
local detailsMenu = RageUI.CreateSubMenu(playerManageStaffMenu)
local vehicleManageMenu = RageUI.CreateSubMenu(detailsMenu)
local detail = nil
local detailData = {}
local depthReg = nil

local currentGarage = 1
local garageTbl = {}
for garage, _ in pairs(Config.Garage.Garages) do
    table.insert(garageTbl, garage)
end

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
        Items:AddButton("Tools", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, toolsStaffMenu)
    end, function()

    end)

    selfStaffMenu:IsVisible(function(Items)
        Items:AddList("Teleport (Garage)", garageTbl, currentGarage, "ez", {}, function(Index, onSelected, onListChange)
            if onSelected then
                SetEntityCoordsNoOffset(PlayerPedId(), Config.Garage.Garages[garageTbl[currentGarage]].position, false,
                    false, true)
            end
            if onListChange then
                currentGarage = Index
            end
        end)
        Items:AddButton("Teleport (Property)", "gg", {},
            function(onSelected)
                if onSelected then
                    local input = Input("Property (ID):")
                    if input and tonumber(input) and Spectrum.properties[tonumber(input)] then
                        SetEntityCoordsNoOffset(PlayerPedId(), Spectrum.properties[tonumber(input)].position,
                            false,
                            false, true)
                    end
                end
            end)
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
        Items:AddButton("Spawn Car", "vroom vroom", { RightLabel = "🏁" }, function(onSelected)
            if onSelected then
                RequestModel("cheburek")
                while not HasModelLoaded("cheburek") do
                    Citizen.Wait(0)
                end
                TaskWarpPedIntoVehicle(PlayerPedId(),
                    CreateVehicle(GetHashKey("cheburek"), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()),
                        true, false), -1)
            end
        end)
        Items:AddButton("Spawn BMX", "pedal pedal", { RightLabel = "🏁" }, function(onSelected)
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
        Items:AddButton("Interior", "F8 to view", { RightLabel = ":3" }, function(onSelected)
            if onSelected then
                print(GetInteriorFromEntity(PlayerPedId()))
            end
        end)
        Items:AddButton("Coordinates", "F8 to view", { RightLabel = "🗺️" }, function(onSelected)
            if onSelected then
                print(GetEntityCoords(PlayerPedId()))
                print(GetEntityHeading(PlayerPedId()))
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
                        playerStaffMenu:SetSubtitle("ID: " .. input .. " | " .. playerData.name)
                        RageUI.Visible(playerStaffMenu, true)
                    else
                        Notification("Please enter a valid ~b~ID")
                    end
                end
            end
        end)
        local flag = false
        for id, playerData in pairs(Spectrum.players) do
            if (Spectrum.StaffMenu.playerType == 1 and playerData.active) or (Spectrum.StaffMenu.playerType == 2 and not playerData.active) then
                if not flag then
                    Items:AddSeparator("")
                    flag = true
                end
                Items:AddButton("[" .. id .. "] " .. playerData.name, playerData.id, {}, function(onSelected)
                    if onSelected then
                        Spectrum.StaffMenu.target = id
                        playerStaffMenu:SetSubtitle("ID: " .. id .. " | " .. playerData.name)
                    end
                end, playerStaffMenu)
            end
        end
        if not flag then
            Items:AddButton(
                "There are no ~o~" ..
                (Spectrum.StaffMenu.playerType == 1 and "connected" or "disconnected") .. " ~s~players", nil,
                {},
                function()

                end)
        end
    end, function()

    end)

    playerStaffMenu:IsVisible(function(Items)
        Items:AddButton("Management", "watch it :eyes:", { RightLabel = "→→→" }, function(onSelected)

        end, playerManageStaffMenu)
        if Spectrum.StaffMenu.playerType == 1 then
            Items:AddSeparator("")
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
        end
    end, function(Panels)

    end)

    playerManageStaffMenu:IsVisible(function(Items)
        Items:AddSeparator("ID: ~b~" .. Spectrum.StaffMenu.target)
        Items:AddSeparator("Name: ~b~" .. Spectrum.players[Spectrum.StaffMenu.target].name)
        Items:AddButton("Audit Vehicles", nil, { RightLabel = "→→→" }, function(onSelected)
            if onSelected then
                detailData = {}
                detail = "userVehicles"
                Spectrum.libs.Callbacks.callback("auditDetails", function(verified)
                    if verified ~= nil then
                        detailData = verified
                    else
                        Notification("There was an issue requesting this ~b~player")
                    end
                end, Spectrum.StaffMenu.target, 1)
            end
        end, detailsMenu)
    end, function()

    end)

    inventoryStaffMenu:IsVisible(function(Items)
        Items:AddButton("~g~Add Bank", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amout of Money (bank):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Add", "bank", nil, tonumber(input))
                end
            end
        end)
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
        Items:AddButton("~g~Remove Bank", nil, {}, function(onSelected)
            if onSelected then
                local input = Input("Amout of Money (bank):")
                if input and tonumber(input) then
                    TriggerServerEvent("Spectrum:Staff:Remove", "bank", nil, tonumber(input))
                end
            end
        end)
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

    toolsStaffMenu:IsVisible(function(Items)
        Items:AddButton("Delete Vehicle", "Command: ~b~/dv", { RightBadge = RageUI.BadgeStyle.Car }, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:DeleteVehicle")
            end
        end)
    end, function()

    end)

    detailsMenu:IsVisible(function(Items)
        if not detail then
            RageUI.GoBack()
            return
        end

        for _, data in ipairs(detailData) do
            if detail == "userVehicles" then
                Items:AddButton(Config.Vehicles.Names[GetHashKey(data.vehicle)],
                    (data.active and "~y~Active" or "~g~Stored") .. " ~s~| ~b~" ..
                    (data.garage and Config.Garage.Garages[data.garage].displayName or "Global"),
                    { RightLabel = "Plate: ~b~" .. data.plate },
                    function(onSelected)
                        if onSelected then
                            depthReg = data.plate
                        end
                    end, vehicleManageMenu)
            end
        end

        if detail == "userVehicles" then
            Items:AddSeparator("")
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
        end
    end, function()

    end)

    vehicleManageMenu:IsVisible(function(Items)
        Items:AddButton("~o~Revoke Vehicle", "Be Careful", {}, function(onSelected)
            if onSelected then
                local input = Input("Enter \"yes\" to confirm:")
                if input:lower() == "yes" then
                    TriggerServerEvent("Spectrum:Garage:Revoke", Spectrum.StaffMenu.target, depthReg:upper())
                    RageUI.GoBack()
                    detailData = {}
                    Spectrum.libs.Callbacks.callback("auditDetails", function(verified)
                        if verified ~= nil then
                            detailData = verified
                        else
                            Notification("There was an issue refreshing this ~b~player")
                        end
                    end, Spectrum.StaffMenu.target, 1)
                end
            end
        end)
        Items:AddButton("~o~Restore Vehicle", "Be Careful", {}, function(onSelected)
            if onSelected then
                local input = Input("Enter \"yes\" to confirm:")
                if input:lower() == "yes" then
                    Spectrum.libs.Callbacks.callback("restoreVehicle", function(verified)
                        if verified then
                            Notification("~b~" .. depthReg .. " ~s~was restored to the most recent Garage")
                            for i, data in ipairs(detailData) do
                                if data.plate == depthReg then
                                    detailData[i].active = false
                                end
                            end
                        else
                            Notification("Please provide a valid ~b~License Plate")
                        end
                    end, depthReg:upper())
                end
            end
        end)
        Items:AddButton("~o~Reassign Vehicle", "Be Careful", {}, function(onSelected)
            if onSelected then
                local newPlate = Input("Enter New Plate (leave empty for random):")
                if newPlate then
                    newPlate = newPlate:upper()
                end
                local input = Input("Enter \"yes\" to confirm:")
                if input:lower() == "yes" then
                    Spectrum.libs.Callbacks.callback("restoreVehicle", function(verified)
                        if verified then
                            Spectrum.libs.Callbacks.callback("alterPlate", function(plate)
                                if plate ~= nil then
                                    for i, vehicle in ipairs(detailData) do
                                        if vehicle.plate == depthReg then
                                            detailData[i].plate = plate
                                        end
                                    end
                                    Notification("Vehicle Reassignment:\n~b~" .. depthReg .. " ~s~-> ~b~" .. plate)
                                    depthReg = plate
                                else
                                    Notification("Please provide a valid ~b~License Plate")
                                end
                            end, Spectrum.StaffMenu.target, depthReg:upper(), newPlate)
                        else
                            Notification("Please provide a valid ~b~License Plate")
                        end
                    end, depthReg:upper())
                end
            end
        end)
    end, function()

    end)
end
