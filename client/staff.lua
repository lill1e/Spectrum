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
local entityManageMenu = RageUI.CreateMenu("Entity", "Literally Minecraft")
local reportsMenu = RageUI.CreateSubMenu(staffMenu, "agony", "~o~Staff Reports")
local archivedReportsMenu = RageUI.CreateSubMenu(reportsMenu, "agony", "~o~Staff Reports")
local reportMenu = RageUI.CreateSubMenu(reportsMenu, "agony", "~o~Staff Reports")
local detail = nil
local detailData = {}
local depthReg = nil
local currentReport = nil
local toggles = {
    constantMarker = false,
    entityGun = false,
    reportsOpt = false
}
local map = {
    markerDist = 5.0
}
local lists = {
    moneyAudit = { "Bank", "Cash (Clean)", "Cash (Dirty)" }
}
local listIndex = {
    moneyAuditAdd = 1,
    moneyAuditRemove = 1
}
local locks = {
    spectate = false
}
local entityData = {
    model = nil,
    entity = nil,
    origin = nil
}
local moneyTypes = { "bank", "clean_cash", "dirty_cash" }
local moneyTypesAlt = { "bank", "clean", "dirty" }

local currentGarage = 1
local garageTbl = {}
for garage, _ in pairs(Config.Garage.Garages) do
    table.insert(garageTbl, garage)
end

RegisterKeyMapping("+staff", "Staff Menu", "keyboard", "f5")
RegisterCommand("+staff", function()
    if Spectrum.Loaded and (Spectrum.PlayerData.staff >= Config.Permissions.Trial or Spectrum.debug) then
        RageUI.Visible(staffMenu, not RageUI.Visible(staffMenu))
    end
end, false)
RegisterCommand("-staff", function() end, false)

function ToggleSpectate(status)
    if status then
        FreezeEntityPosition(PlayerPedId(), true)
        NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
        SetEntityVisible(PlayerPedId(), false, false)
        SetEntityCollision(PlayerPedId(), false, false)
    else
        NetworkSetInSpectatorMode(false, Spectrum.StaffMenu.spectateData.ped)
        FreezeEntityPosition(PlayerPedId(), false)
        Wait(250)
        NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
        SetEntityVisible(PlayerPedId(), true, false)
        SetEntityCollision(PlayerPedId(), true, true)
        SetEntityCoordsNoOffset(PlayerPedId(), Spectrum.StaffMenu.spectateData.entrance,
            false, false, true)
    end
end

function RageUI.PoolMenus:Staff()
    staffMenu:IsVisible(function(Items)
        Items:AddButton("Players (Connected)", "who?", { RightLabel = "→→→" }, function(onSelected)
            Spectrum.StaffMenu.playerType = 1
        end, playersStaffMenu)
        Items:AddButton("Players (Disconnected)", "f8?", { RightLabel = "→→→" }, function(onSelected)
            Spectrum.StaffMenu.playerType = 2
        end, playersStaffMenu)
        Items:AddButton("Staff Reports", "help some people ffs", { RightLabel = "→→→" }, function() end, reportsMenu)
        Items:AddButton("Self", "me <3", { RightLabel = "→→→" }, function(onSelected)

        end, selfStaffMenu)
        if Spectrum.PlayerData.staff >= Config.Permissions.Developer then
            Items:AddButton("Self (Dev)", "f8", { RightLabel = "→→→" }, function(onSelected)

            end, selfDevStaffMenu)
            Items:AddButton("Inventory", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

            end, inventoryStaffMenu)
        end
        Items:AddButton("Tools", "don't do something stupid", { RightLabel = "→→→" }, function(onSelected)

        end, toolsStaffMenu)
    end, function()

    end)

    selfStaffMenu:IsVisible(function(Items)
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
            Items:AddList("Teleport (Garage)", garageTbl, currentGarage, "ez", {},
                function(Index, onSelected, onListChange)
                    if onSelected then
                        SetEntityCoordsNoOffset(PlayerPedId(), Config.Garage.Garages[garageTbl[currentGarage]].position,
                            false,
                            false, true)
                    end
                    if onListChange then
                        currentGarage = Index
                    end
                end)
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Developer then
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
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
            Items:AddButton("Teleport (Waypoint)", "ez", {}, function(onSelected)
                if onSelected then
                    local waypoint = GetFirstBlipInfoId(8)
                    if DoesBlipExist(waypoint) then
                        local coords = GetBlipInfoIdCoord(waypoint)
                        TriggerServerEvent("Spectrum:Staff:TeleportCoords", coords, true)
                    end
                end
            end)
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
            Items:AddButton("Snowballs (Staff)", "okay snowflake", {}, function(onSelected)
                if onSelected then
                    TriggerServerEvent("Spectrum:Staff:Snowflake")
                end
            end)
            Items:AddButton("Snowball Launcher (Staff)", "okay snowflake", {}, function(onSelected)
                if onSelected then
                    TriggerServerEvent("Spectrum:Staff:SnowflakeAlt")
                end
            end)
            Items:CheckBox("Entity Gun", "yikers", toggles.entityGun, {}, function(onSelected, Checked)
                if onSelected then
                    toggles.entityGun = Checked
                    if toggles.entityGun then
                        entityData = {
                            model = nil,
                            entity = nil,
                            origin = nil
                        }
                        if HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", true)
                        elseif HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                            SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWBALL", true)
                        end
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
        end
        if Spectrum.debug then
            Items:AddButton("Spawn Vehicle", "vroom vroom", { RightLabel = "🏁" }, function(onSelected)
                if onSelected then
                    local model = Input("Vehicle Model:")
                    if model and IsModelAVehicle(model) then
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Citizen.Wait(0)
                        end
                        local tempHandle = CreateVehicle(GetHashKey(model), GetEntityCoords(PlayerPedId()),
                            GetEntityHeading(PlayerPedId()), true, false)
                        SetVehicleNumberPlateText(tempHandle, "PEEKABOO")
                        TaskWarpPedIntoVehicle(PlayerPedId(), tempHandle, -1)
                    end
                end
            end)
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
            Items:AddButton("Spawn Car", "vroom vroom", { RightLabel = "🏁" }, function(onSelected)
                if onSelected then
                    RequestModel("cheburek")
                    while not HasModelLoaded("cheburek") do
                        Citizen.Wait(0)
                    end
                    local tempHandle = CreateVehicle(GetHashKey("cheburek"), GetEntityCoords(PlayerPedId()),
                        GetEntityHeading(PlayerPedId()), true, false)
                    SetVehicleNumberPlateText(tempHandle, "PEEKABOO")
                    TaskWarpPedIntoVehicle(PlayerPedId(), tempHandle, -1)
                end
            end)
        end
        Items:AddButton("Spawn BMX", "pedal pedal", { RightLabel = "🏁" }, function(onSelected)
            if onSelected then
                RequestModel("bmx")
                while not HasModelLoaded("bmx") do
                    Citizen.Wait(0)
                end
                local tempHandle = CreateVehicle(GetHashKey("bmx"), GetEntityCoords(PlayerPedId()),
                    GetEntityHeading(PlayerPedId()), true, false)
                SetVehicleNumberPlateText(tempHandle, "PEEKABOO")
                TaskWarpPedIntoVehicle(PlayerPedId(), tempHandle, -1)
            end
        end)
        Items:AddButton("reskin", "fresh slate", { RightBadge = RageUI.BadgeStyle.Clothes }, function(onSelected)
            if onSelected then
                Spectrum.skin.Outfit = false
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
        Items:AddButton("Marker Distance", nil, { RightLabel = map.markerDist }, function(onSelected)
            if onSelected then
                local input = Input("Distance (Debug Marker):")
                if input and tonumber(input) then
                    if tonumber(input) > 0 then
                        map.markerDist = tonumber(input) * 10 / 10
                    end
                end
            end
        end)
        Items:CheckBox("Debug Marker", nil, toggles.constantMarker, {}, function(onSelected, Checked)
            if onSelected then
                toggles.constantMarker = Checked
            end
        end)
        Items:AddButton("Add External Property", nil, { RightBadge = RageUI.BadgeStyle.Key },
            function(onSelected)
                if onSelected then
                    local space = Input("Storage Space:")
                    if space and tonumber(space) then
                        Spectrum.libs.Callbacks.callback("addExternalProperty", function(result)
                            if result then
                                Notification("The property was added!!")
                            else
                                Notification("There was a problem adding the ~y~property")
                            end
                        end, GetPlayerServerId(PlayerId()), GetEntityCoords(PlayerPedId()), space)
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
                        if (Spectrum.StaffMenu.playerType == 1 and playerData.active) or (Spectrum.StaffMenu.playerType == 2 and not playerData.active) then
                            Spectrum.StaffMenu.target = input
                            playerStaffMenu:SetSubtitle("ID: " .. input .. " | " .. playerData.name)
                            RageUI.Visible(playerStaffMenu, true)
                        else
                            Notification("Please enter a valid ~b~ID ~s~(Wrong Category)")
                        end
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
                Items:AddButton(playerData.name .. " (ID: " .. id .. ")", playerData.dropReason,
                    {
                        RightBadge = playerData.staff > 0 and
                            (playerData.spectating and RageUI.BadgeStyle.Mask or RageUI.BadgeStyle.Heart) or nil
                    },
                    function(onSelected)
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
        Items:AddButton("User History", "Have they been acting bad???", { RightLabel = "→→→" }, function(onSelected)
            if onSelected then
                if onSelected then
                    detailData = {}
                    detail = "userStaffRecord"
                    Spectrum.libs.Callbacks.callback("auditDetails", function(verified)
                        if verified ~= nil then
                            detailData = verified
                        else
                            Notification("There was an issue requesting this ~b~player")
                        end
                    end, Spectrum.StaffMenu.target, 5)
                end
            end
        end, detailsMenu)
        if Spectrum.StaffMenu.playerType == 1 and (Spectrum.StaffMenu.target ~= tostring(GetPlayerServerId(PlayerId())) or Spectrum.debug) then
            Items:AddSeparator("")
            if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
                Items:AddButton("Kick Player", "Give them the boot", { RightBadge = RageUI.BadgeStyle.Star },
                    function(onSelected)
                        if onSelected then
                            local input = Input("Kick Reason:")
                            if input then
                                TriggerServerEvent("Spectrum:Staff:Kick", Spectrum.StaffMenu.target,
                                    input ~= "" and input or nil)
                            end
                        end
                    end)
                Items:AddButton("Ban Player", "Keep them out", { RightBadge = RageUI.BadgeStyle.Star },
                    function(onSelected)
                        if onSelected then
                            local input = Input("Ban Reason:")
                            if input then
                                local days = Input("Ban Length (Days)")
                                local hours = Input("Ban Length (Hours)")
                                local minutes = Input("Ban Length (Minutes)")
                                local daysNum = 0
                                local hoursNum = 0
                                local minutesNum = 0
                                if days and tonumber(days) then
                                    daysNum = tonumber(days) or 0
                                end
                                if hours and tonumber(hours) then
                                    hoursNum = tonumber(hours) or 0
                                end
                                if minutes and tonumber(minutes) then
                                    minutesNum = tonumber(minutes) or 0
                                end
                                if days and hours and minutes then
                                    TriggerServerEvent("Spectrum:Staff:Ban", Spectrum.StaffMenu.target,
                                        input ~= "" and input or nil, daysNum, hoursNum, minutesNum)
                                end
                            end
                        end
                    end)
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
            end
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
            Items:AddButton("Spectate Player", "okay you creep",
                { RightBadge = RageUI.BadgeStyle.Mask, IsDisabled = locks.spectate or Spectrum.StaffMenu.spectating },
                function(onSelected)
                    if onSelected then
                        locks.spectate = true
                        Spectrum.libs.Callbacks.callback("getLocation", function(position)
                            if position ~= nil then
                                DoScreenFadeOut(500)
                                while not IsScreenFadedOut() do Wait(0) end
                                Spectrum.StaffMenu.spectating = true
                                Spectrum.StaffMenu.spectateData.entrance = GetEntityCoords(PlayerPedId())
                                ToggleSpectate(true)
                                Wait(250)
                                RequestCollisionAtCoord(position)
                                SetEntityCoordsNoOffset(PlayerPedId(), position - vector3(0, 0, 10.0), false, false, true)
                                local target = GetPlayerFromServerId(tonumber(Spectrum.StaffMenu.target))
                                local time = 0
                                while target <= 0 or not DoesEntityExist(GetPlayerPed(target)) do
                                    Wait(0)
                                    time = time + 1
                                    target = GetPlayerFromServerId(tonumber(Spectrum.StaffMenu.target))
                                    if time > 5000 then
                                        goto skip
                                    end
                                end
                                RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(target)))
                                NetworkSetInSpectatorMode(true, GetPlayerPed(target))
                                ::skip::
                                if time > 5000 then
                                    Spectrum.StaffMenu.spectating = false
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
                                    SetEntityVisible(PlayerPedId(), true, false)
                                    SetEntityCollision(PlayerPedId(), true, true)
                                    SetEntityCoordsNoOffset(PlayerPedId(), Spectrum.StaffMenu.spectateData.entrance,
                                        false, false, true)
                                    DoScreenFadeIn(500)
                                    while not IsScreenFadedIn() do Wait(0) end
                                    Notification("There was an issue fetching this ~b~player")
                                else
                                    TriggerServerEvent("Spectrum:Staff:ToggleSpectate", Spectrum.StaffMenu.target, true)
                                    Spectrum.StaffMenu.spectateData.id = Spectrum.StaffMenu.target
                                    Spectrum.StaffMenu.spectateData.player = target
                                    Spectrum.StaffMenu.spectateData.ped = GetPlayerPed(target)
                                    DoScreenFadeIn(500)
                                end
                            else
                                Notification("There was an issue fetching this ~b~player")
                            end
                            locks.spectate = false
                        end, Spectrum.StaffMenu.target)
                    end
                end)
        end
    end, function(Panels)

    end)

    playerManageStaffMenu:IsVisible(function(Items)
        Items:AddSeparator("ID: ~b~" .. Spectrum.StaffMenu.target)
        Items:AddSeparator("Name: ~b~" .. Spectrum.players[Spectrum.StaffMenu.target].name)
        if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
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
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
            if Spectrum.StaffMenu.playerType == 1 then
                Items:AddButton("Audit Inventory", nil, { RightLabel = "→→→" }, function(onSelected)
                    if onSelected then
                        detailData = {}
                        detail = "userInventory"
                        Spectrum.libs.Callbacks.callback("auditDetails", function(verified)
                            if verified ~= nil then
                                detailData = verified
                            else
                                Notification("There was an issue requesting this ~b~player")
                            end
                        end, Spectrum.StaffMenu.target, 2)
                    end
                end, detailsMenu)
                Items:AddButton("Audit Money", nil, { RightLabel = "→→→" }, function(onSelected)
                    if onSelected then
                        detailData = {}
                        detail = "userMoney"
                        Spectrum.libs.Callbacks.callback("auditDetails", function(verified)
                            if verified ~= nil then
                                detailData = verified
                            else
                                Notification("There was an issue requesting this ~b~player")
                            end
                        end, Spectrum.StaffMenu.target, 3)
                    end
                end, detailsMenu)
            end
        end
    end, function()

    end)

    inventoryStaffMenu:IsVisible(function(Items)
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

        if detail == "userVehicles" then
            for _, data in ipairs(detailData) do
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
            if #detailData > 0 and Spectrum.PlayerData.staff >= Config.Permissions.Admin then
                Items:AddSeparator("")
            end
            if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
                Items:AddButton("Grant Vehicle", "Shiny", {}, function(onSelected)
                    if onSelected then
                        local vehicle = Input("Vehicle:")
                        if vehicle and Config.Vehicles.Names[GetHashKey(vehicle)] then
                            TriggerServerEvent("Spectrum:Garage:Grant", Spectrum.StaffMenu.target, vehicle,
                                GetVehicleClassFromName(vehicle))
                        else
                            Notification("Please enter a valid ~b~Vehicle Model")
                        end
                    end
                end)
            end
        elseif detail == "userInventory" then
            local c = 0
            for item, count in pairs(detailData) do
                c = c + 1
                if Spectrum.items[item] ~= nil then
                    Items:AddButton(Spectrum.items[item].displayName, nil, { RightLabel = "x" .. count },
                        function(onSelected)

                        end)
                end
            end
            if c == 0 then
                Items:AddButton("Empty Inventory", nil, {}, function(onSelected)

                end)
            end
            Items:AddSeparator("")
            Items:AddButton("~b~Add Item", nil, { RightLabel = "→→→" }, function(onSelected)
                if onSelected then
                    local input = Input("Item:")
                    if input then
                        local item = input
                        input = Input("Quantity:")
                        if input and tonumber(input) then
                            Spectrum.libs.Callbacks.callback("staffAdd", function(status)
                                if status then
                                    if detailData[item] then
                                        detailData[item] = detailData[item] + tonumber(input)
                                    else
                                        detailData[item] = tonumber(input)
                                    end
                                else
                                    Notification("The player is unable to hold an additional ~y~x" ..
                                        input .. "~s~ " .. Spectrum.items[item].displayName)
                                end
                            end, "item", item, tonumber(input), Spectrum.StaffMenu.target)
                        end
                    end
                end
            end)
            Items:AddButton("~b~Remove Item", nil, { RightLabel = "→→→" }, function(onSelected)
                if onSelected then
                    local input = Input("Item:")
                    if input then
                        local item = input
                        input = Input("Quantity:")
                        if input and tonumber(input) then
                            if detailData[item] and detailData[item] >= tonumber(input) then
                                Spectrum.libs.Callbacks.callback("staffRemove", function(status)
                                    if status and detailData[item] then
                                        if detailData[item] == tonumber(input) then
                                            detailData[item] = nil
                                        else
                                            detailData[item] = detailData[item] - tonumber(input)
                                        end
                                    else
                                        Notification("The ~b~player ~s~does not have enough " ..
                                            Spectrum.items[item].displayName)
                                    end
                                end, "item", item, tonumber(input), Spectrum.StaffMenu.target)
                            else
                                Notification("The ~b~player ~s~does not have enough " ..
                                    Spectrum.items[item].displayName)
                            end
                        end
                    end
                end
            end)
        elseif detail == "userMoney" then
            if TableEmpty(detailData) then
                goto skip
            end
            Items:AddButton("Bank", nil, { RightLabel = "~g~$" .. FormatMoney(detailData.bank) }, function() end)
            Items:AddButton("Cash (Clean)", nil, { RightLabel = "~g~$" .. FormatMoney(detailData.clean) },
                function() end)
            Items:AddButton("Cash (Dirty)", nil, { RightLabel = "~r~$" .. FormatMoney(detailData.dirty) },
                function() end)
            Items:AddSeparator("")
            Items:AddList("~g~Add Money", lists.moneyAudit, listIndex.moneyAuditAdd, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        listIndex.moneyAuditAdd = Index
                    end
                    if onSelected then
                        local input = Input("Amount of Money:")
                        if input and tonumber(input) then
                            Spectrum.libs.Callbacks.callback("staffAdd", function(status)
                                if status then
                                    detailData[moneyTypesAlt[listIndex.moneyAuditAdd]] = detailData
                                        [moneyTypesAlt[listIndex.moneyAuditAdd]] + tonumber(input)
                                else
                                    Notification("There was an issue adding money to the ~b~player")
                                end
                            end, moneyTypes[listIndex.moneyAuditAdd], nil, tonumber(input), Spectrum.StaffMenu.target)
                        end
                    end
                end)
            Items:AddList("~g~Remove Money", lists.moneyAudit, listIndex.moneyAuditRemove, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        listIndex.moneyAuditRemove = Index
                    end
                    if onSelected then
                        local input = Input("Amount of Money:")
                        if input and tonumber(input) then
                            Spectrum.libs.Callbacks.callback("staffRemove", function(status)
                                if status then
                                    detailData[moneyTypesAlt[listIndex.moneyAuditRemove]] = detailData
                                        [moneyTypesAlt[listIndex.moneyAuditRemove]] - tonumber(input)
                                else
                                    Notification("There was an issue removing money from the ~b~player")
                                end
                            end, moneyTypes[listIndex.moneyAuditRemove], nil, tonumber(input), Spectrum.StaffMenu.target)
                        end
                    end
                end)
            ::skip::
        elseif detail == "userStaffRecord" then
            if TableEmpty(detailData) then
                Items:AddButton("~y~Squeaky Clean ~s~Record", nil, {}, function() end)
                goto skip
            end
            for _, ban in ipairs(detailData) do
                Items:CheckBox(ban.reason .. " (ID: " .. ban.id .. ")", "Expired At: ~o~" .. ban.expiry, ban.active, {},
                    function(onSelected)
                        if onSelected then
                            Notification("Banned By: ~b~" .. ban.staff)
                        end
                    end)
            end
            ::skip::
        end
    end, function()

    end)

    vehicleManageMenu:IsVisible(function(Items)
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
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
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
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
                    if input and input:lower() == "yes" then
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
        end
        if Spectrum.PlayerData.staff >= Config.Permissions.Admin then
            Items:AddList("~o~Assign Location", garageTbl, currentGarage, "Be Careful", {},
                function(Index, onSelected, onListChange)
                    if onSelected then
                        local input = Input("Enter \"yes\" to confirm:")
                        if input and input:lower() == "yes" then
                            Spectrum.libs.Callbacks.callback("locationChange", function(verified)
                                if verified then
                                    Notification("~b~" .. depthReg .. " ~s~was moved to the specified Garage")
                                    for i, data in ipairs(detailData) do
                                        if data.plate == depthReg then
                                            detailData[i].garage = garageTbl[currentGarage]
                                        end
                                    end
                                else
                                    Notification("Please provide a valid ~b~License Plate")
                                end
                            end, depthReg:upper(), garageTbl[currentGarage])
                        end
                    end
                    if onListChange then
                        currentGarage = Index
                    end
                end)
        end
    end, function()

    end)
    entityManageMenu:IsVisible(function(Items)
        if not entityData.entity or entityData.entity < 0 or not entityData.model or entityData.model == 0 then
            RageUI.CloseAll()
            goto skip
        end
        Items:AddButton("Entity", nil, { RightLabel = entityData.entity }, function() end)
        Items:AddButton("Model", nil, { RightLabel = entityData.model }, function() end)
        Items:AddButton("Owner", nil, { RightLabel = entityData.origin or "N/A" }, function(onSelected)
            if onSelected then
                if Spectrum.PlayerData.staff >= Config.Permissions.Trial then
                    local id = tostring(entityData.origin)
                    if Spectrum.players[id] then
                        local player = Spectrum.players[id]
                        Spectrum.StaffMenu.playerType = player.active and 1 or 2
                        Spectrum.StaffMenu.target = id
                        playerStaffMenu:SetSubtitle("ID: " .. id .. " | " .. player.name)
                        RageUI.Visible(playerStaffMenu, true)
                    end
                end
            end
        end)
        Items:AddSeparator("")
        Items:CheckBox("Entity Gun", "yikers", toggles.entityGun, {}, function(onSelected, Checked)
            if onSelected then
                toggles.entityGun = Checked
                if toggles.entityGun then
                    entityData = {
                        model = nil,
                        entity = nil,
                        origin = nil
                    }
                    if HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                        SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", true)
                    elseif HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                        SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWBALL", true)
                    end
                end
            end
        end)
        Items:AddButton("~r~Delete Entity", nil, { RightLabel = "→→→" }, function(onSelected)
            if onSelected then
                TriggerServerEvent("Spectrum:Staff:DeleteEntity", NetworkGetNetworkIdFromEntity(entityData.entity))
            end
        end)
        ::skip::
    end, function() end)
    reportsMenu:IsVisible(function(Items)
        Items:CheckBox("Reports Opt-In", "Enable this if you would like to be notified about ~b~player reports",
            toggles.reportsOpt, {}, function(onSelected, Checked)
                if onSelected then
                    toggles.reportsOpt = Checked
                end
            end)
        Items:AddSeparator("")
        if TableEmpty(Spectrum.reports) then
            Items:AddButton("There are no ~b~reports ~s~to resolve", nil, {}, function() end)
        end
        for id, report in pairs(Spectrum.reports) do
            if not report.status then
                Items:AddButton("ID: " .. id, "Reporter: " .. report.reporter,
                    { RightLabel = report.status and "Completed" or "" }, function(onSelected)
                        if onSelected then
                            currentReport = id
                        end
                    end, reportMenu)
            end
        end
        Items:AddButton("Archived Reports", "All reports that are no longer active", {}, function() end,
            archivedReportsMenu)
    end, function() end)
    archivedReportsMenu:IsVisible(function(Items)
        if TableEmpty(Spectrum.reports) then
            Items:AddButton("There are no ~b~reports ~s~that have been archived", nil, {}, function() end)
        end
        for id, report in pairs(Spectrum.reports) do
            if report.status then
                Items:AddButton("ID: " .. id, "Reporter: " .. report.reporter,
                    { RightLabel = report.status and "Completed" or "" }, function(onSelected)
                        if onSelected then
                            currentReport = id
                        end
                    end, reportMenu)
            end
        end
    end, function() end)
    reportMenu:IsVisible(function(Items)
        if Spectrum.reports[currentReport] then
            Items:AddButton("Reason", Spectrum.reports[currentReport].reason, {}, function() end)
            Items:AddButton("Reporter: " .. Spectrum.players[Spectrum.reports[currentReport].reporter].name,
                "ID: " .. Spectrum.reports[currentReport].reporter, {}, function(onSelected)
                    if onSelected then
                        Spectrum.StaffMenu.playerType = Spectrum.players[Spectrum.reports[currentReport].reporter]
                            .active and
                            1 or 2
                        Spectrum.StaffMenu.target = Spectrum.reports[currentReport].reporter
                        playerStaffMenu:SetSubtitle("ID: " ..
                            Spectrum.reports[currentReport].reporter ..
                            " | " .. Spectrum.players[Spectrum.reports[currentReport].reporter].name)
                        RageUI.Visible(playerStaffMenu, true)
                    end
                end)
            if Spectrum.reports[currentReport].target then
                Items:AddButton("Reported: " .. Spectrum.players[Spectrum.reports[currentReport].target].name,
                    "ID: " .. Spectrum.reports[currentReport].target, {}, function(onSelected)
                        if onSelected then
                            Spectrum.StaffMenu.playerType = Spectrum.players[Spectrum.reports[currentReport].target]
                                .active and
                                1 or 2
                            Spectrum.StaffMenu.target = Spectrum.reports[currentReport].target
                            playerStaffMenu:SetSubtitle("ID: " ..
                                Spectrum.reports[currentReport].target ..
                                " | " .. Spectrum.players[Spectrum.reports[currentReport].target].name)
                            RageUI.Visible(playerStaffMenu, true)
                        end
                    end)
            end
            Items:StopLight("Status", "Is this an ongoing concern?", Spectrum.reports[currentReport].status, {},
                function(onSelected, Checked)
                    if onSelected and not Spectrum.reports[currentReport].status then
                        TriggerServerEvent("Spectrum:Staff:EndReport", currentReport)
                    end
                end)
        else
            Items:AddButton("Return", "This report does not seem to exist", {}, function() end, reportsMenu)
        end
    end, function() end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if toggles.constantMarker then
            local loc = GetEntityCoords(PlayerPedId())
            DrawMarker(1, loc.x, loc.y, loc.z - 1, 0, 0, 0, 0, 0, 0, map.markerDist * 2, map.markerDist * 2, 0.5, 255,
                255,
                255,
                100, 0, 0, 0, 0, 0, 0, 0)
        end
        if Spectrum.StaffMenu.spectating then
            if DoesEntityExist(Spectrum.StaffMenu.spectateData.ped) then
                HelpText("~b~" .. Spectrum.players[Spectrum.StaffMenu.spectateData.id].name ..
                    " ~s~(ID: " .. Spectrum.StaffMenu.spectateData.id .. ")" ..
                    "\n~g~Health: ~s~" .. GetEntityHealth(Spectrum.StaffMenu.spectateData.ped) ..
                    "\n~b~Armor: ~s~" .. GetPedArmour(Spectrum.StaffMenu.spectateData.ped) ..
                    "\nPress ~INPUT_CONTEXT~ to ~o~stop ~s~spectating")
                if IsControlJustPressed(0, 51) then
                    DoScreenFadeOut(500)
                    while not IsScreenFadedOut() do Wait(0) end
                    Spectrum.StaffMenu.spectating = false
                    ToggleSpectate(false)
                    TriggerServerEvent("Spectrum:Staff:ToggleSpectate", Spectrum.StaffMenu.spectateData.id, false)
                    DoScreenFadeIn(500)
                end
            elseif IsScreenFadedIn() then
                DoScreenFadeOut(500)
                while not IsScreenFadedOut() do Wait(0) end
                Spectrum.StaffMenu.spectating = false
                ToggleSpectate(false)
                TriggerServerEvent("Spectrum:Staff:ToggleSpectate", Spectrum.StaffMenu.spectateData.id, false)
                DoScreenFadeIn(500)
                while not IsScreenFadedIn() do Wait(0) end
                Notification("The ~b~player ~s~is no longer accessible")
            end
        end
        if toggles.entityGun then
            DisableControlAction(0, 24, true)
            DisablePlayerFiring(PlayerId(), true)
            local isAimingAtEntity, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if isAimingAtEntity and entity ~= 0 and DoesEntityExist(entity) then
                entityData.entity = entity
                entityData.model = GetEntityModel(entity)
                if IsDisabledControlJustPressed(0, 24) then
                    Spectrum.libs.Callbacks.callback("getEntityOrigin", function(origin)
                        if origin ~= nil then
                            entityData.origin = origin
                            RageUI.Visible(entityManageMenu, true)
                        end
                    end, NetworkGetNetworkIdFromEntity(entityData.entity))
                end
            end
            if entityData.entity and entityData.entity ~= 0 and entityData.model and entityData.model ~= 0 then
                HelpText("~b~Entity: ~s~" .. entityData.entity .. "\n~b~Model: ~s~" .. entityData.model)
            end
        end
    end
end)

RegisterCommand("goto", function(source, args)
    if Spectrum.PlayerData.staff >= Config.Permissions.Trial then
        if #args > 0 then
            local target = args[1]
            if Spectrum.players[target] then
                -- TODO: add logging
                local player = Spectrum.players[target]
                Spectrum.StaffMenu.playerType = player.active and 1 or 2
                Spectrum.StaffMenu.target = target
                playerStaffMenu:SetSubtitle("ID: " .. target .. " | " .. player.name)
                RageUI.Visible(playerStaffMenu, true)
            end
        else
            Notification("Please provide an ~b~ID ~s~of a player")
        end
    end
end, false)

RegisterCommand("egun", function(source, args)
    if Spectrum.PlayerData.staff >= Config.Permissions.Staff then
        toggles.entityGun = not toggles.entityGun
        if toggles.entityGun then
            entityData = {
                model = nil,
                entity = nil,
                origin = nil
            }
            if HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", true)
            elseif HasPedGotWeapon(PlayerPedId(), "WEAPON_SNOWLAUNCHER", false) then
                SetCurrentPedWeapon(PlayerPedId(), "WEAPON_SNOWBALL", true)
            end
        end
    end
end, false)
RegisterCommand("report", function()
    local reason = Input("Reason:")
    if reason and reason ~= "" then
        local target = Input("Player ID (if applicable):")
        if target and target ~= "" then
            if tonumber(target) and Spectrum.players[target] then
                TriggerServerEvent("Spectrum:Staff:Report", reason, target)
            else
                Notification("Please provide a valid ~b~Player ID ~s~to report")
            end
        else
            TriggerServerEvent("Spectrum:Staff:Report", reason)
        end
    end
    if reason == "" then
        Notification("Please provide a ~b~reason ~s~so staff can help you")
    end
end, false)

RegisterCommand("calladmin", function()
    ExecuteCommand("report")
end, false)

RegisterNetEvent("Spectrum:Staff:NewReport", function(id, reporter, reason, target)
    Spectrum.reports[id] = {
        reporter = reporter,
        reason = reason,
        target = target,
        status = false
    }
    print("New Report (ID: " .. id .. "): " .. reason)
    if toggles.reportsOpt then
        Notification("A new ~b~player report ~s~(ID: " .. id .. ") has come in, check your staff menu")
    end
end)

RegisterNetEvent("Spectrum:Staff:ReportEnded", function(report)
    if Spectrum.reports[report] and not Spectrum.reports[report].status then
        Spectrum.reports[report].status = true
    end
end)

RegisterNetEvent("Spectrum:Staff:Reports", function(reports)
    Spectrum.reports = reports
end)
