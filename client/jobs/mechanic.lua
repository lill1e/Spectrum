MechanicJobMenu = RageUI.CreateMenu("Mechanics", "~o~Rusty")
local job = "Mechanic"
local menus = {
    Color = RageUI.CreateSubMenu(MechanicJobMenu, "Mechanics", "Color Wheel"),
    Tint = RageUI.CreateSubMenu(MechanicJobMenu, "Mechanics", "Window Tints"),
    Plate = RageUI.CreateSubMenu(MechanicJobMenu, "Mechanics", "License Plates"),
    ModCategories = RageUI.CreateSubMenu(MechanicJobMenu, "Mechanics", "Vehicle Mods"),
}
menus.Category = RageUI.CreateSubMenu(menus.ModCategories, "Mechanics", "Mod Category")
menus.Mod = RageUI.CreateSubMenu(menus.Category, "Mechanics", "Vehicle Mod")
local menuData = {
    category = nil,
    mod = nil
}
local menusVal = {}
for _, menu in pairs(menus) do
    table.insert(menusVal, menu)
end
local state = {
    active = false,
    handle = -1,
    Color = {
        Primary = { -1, -1, -1 },
        Secondary = { -1, -1, -1 }
    },
    Tint = -1,
    Plate = -1,
    Mods = {}
}
for mod, _ in pairs(Config.Vehicles.Mods.Mods) do
    state.Mods[mod] = -1
end
local rgbColour = {}
for i = 0, 255 do
    table.insert(rgbColour, i)
end

function RageUI.PoolMenus:MechanicJob()
    if Spectrum.Job.current == job then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            if not state.active and Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] ~= nil then
                state.active = true
                state.handle = GetVehiclePedIsIn(PlayerPedId(), false)
                state.Color.Primary = table.pack(GetVehicleCustomPrimaryColour(state.handle))
                state.Color.Secondary = table.pack(GetVehicleCustomSecondaryColour(state.handle))
                SetVehicleModKit(state.handle, 0)
                if GetVehicleWindowTint(state.handle) == -1 then
                    SetVehicleWindowTint(state.handle, 0)
                end
                state.Tint = GetVehicleWindowTint(state.handle)
                state.Plate = GetVehicleNumberPlateTextIndex(state.handle)
                for mod, _ in pairs(Config.Vehicles.Mods.Mods) do
                    state.Mods[mod] = GetVehicleMod(state.handle, mod)
                end
            end
            if state.active and Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil then
                state.active = false
                if RageUI.AnyVisible(menusVal) then
                    RageUI.GoBack()
                end
            end
        else
            if state.active then
                state.active = false
            end
            if RageUI.AnyVisible(menusVal) then
                RageUI.GoBack()
            end
        end
    else
        if RageUI.Visible(MechanicJobMenu) or RageUI.AnyVisible(menusVal) then
            RageUI.CloseAll()
        end
    end
    MechanicJobMenu:IsVisible(function(Items)
        Items:AddButton("Repair Vehicle",
            (Spectrum.Job.state.active and "There is already an ~b~action ~s~in progress" or (IsPedInAnyVehicle(PlayerPedId(), false) and "You must be outside of the ~b~vehicle ~s~to perform this" or "~b~Brand new")),
            { IsDisabled = Spectrum.Job.state.active or IsPedInAnyVehicle(PlayerPedId(), false) }, function(onSelected)
                if onSelected then
                    if not Spectrum.Job.state.active then
                        Spectrum.Job.state.active = true
                        local vehicle = GetClosest("CVehicle")
                        if vehicle ~= nil then
                            if Spectrum.PlayerData.items["repair_kit"] then
                                Citizen.CreateThread(function()
                                    SetVehicleDoorOpen(vehicle, 4, false, false)
                                    Wait(5000)
                                    SetVehicleDoorShut(vehicle, 4, false)
                                    SetVehicleEngineHealth(vehicle, 1000.0)
                                end)
                            else
                                Notification("A ~o~" ..
                                    Spectrum.items["repair_kit"].displayName .. " ~s~is required for this")
                            end
                            Spectrum.Job.state.active = false
                        else
                            Spectrum.Job.state.active = false
                            Notification("Please do this next to a ~b~vehicle")
                        end
                    else
                        Notification("Please wait for the previous ~b~action ~s~to finish")
                    end
                end
            end)
        Items:AddSeparator("")
        Items:AddButton("Clean Vehicle",
            Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil and
            "This action can only be used in an ~o~Auto Shop" or
            (IsPedInAnyVehicle(PlayerPedId(), false) and "~y~Fresh Slate" or "This action must be performed whilst in a ~y~vehicle"),
            {
                IsDisabled = Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil or
                    not IsPedInAnyVehicle(PlayerPedId(), false)
            }, function(onSelected)
                if onSelected then
                    SetVehicleDirtLevel(state.handle, 0.0)
                end
            end
        )
        Items:AddButton("Vehicle Color",
            Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil and
            "This action can only be used in an ~o~Auto Shop" or
            (IsPedInAnyVehicle(PlayerPedId(), false) and "~y~The Rainbow" or "This action must be performed whilst in a ~y~vehicle"),
            {
                RightLabel = "→→→",
                IsDisabled = Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil or
                    not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            function(onSelected)

            end, menus.Color)
        Items:AddButton("Window Tint",
            Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil and
            "This action can only be used in an ~o~Auto Shop" or
            (IsPedInAnyVehicle(PlayerPedId(), false) and "~l~Blacked Out" or "This action must be performed whilst in a ~y~vehicle"),
            {
                RightLabel = "→→→",
                IsDisabled = Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil or
                    not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            function(onSelected)

            end, menus.Tint)
        Items:AddButton("License Plate",
            Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil and
            "This action can only be used in an ~o~Auto Shop" or
            (IsPedInAnyVehicle(PlayerPedId(), false) and "~y~With Style..." or "This action must be performed whilst in a ~y~vehicle"),
            {
                RightLabel = "→→→",
                IsDisabled = Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil or
                    not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            function(onSelected)

            end, menus.Plate)
        Items:AddButton("Modifications",
            Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil and
            "This action can only be used in an ~o~Auto Shop" or
            (IsPedInAnyVehicle(PlayerPedId(), false) and "~y~Make it yours" or "This action must be performed whilst in a ~y~vehicle"),
            {
                RightLabel = "→→→",
                IsDisabled = Config.Jobs[job].interiors[GetInteriorFromEntity(PlayerPedId())] == nil or
                    not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            function(onSelected)

            end, menus.ModCategories)
    end, function()

    end)
    menus.Color:IsVisible(function(Items)
        if state.active then
            Items:AddList("Primary Color (R)", rgbColour, state.Color.Primary[1] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Primary[1] = Index - 1
                        SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Primary[1] = inputNum
                                SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                            end
                        end
                    end
                end)
            Items:AddList("Primary Color (G)", rgbColour, state.Color.Primary[2] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Primary[2] = Index - 1
                        SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Primary[2] = inputNum
                                SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                            end
                        end
                    end
                end)
            Items:AddList("Primary Color (B)", rgbColour, state.Color.Primary[3] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Primary[3] = Index - 1
                        SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Primary[3] = inputNum
                                SetVehicleCustomPrimaryColour(state.handle, table.unpack(state.Color.Primary))
                            end
                        end
                    end
                end)
            Items:AddList("Secondary Color (R)", rgbColour, state.Color.Secondary[1] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Secondary[1] = Index - 1
                        SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Secondary[1] = inputNum
                                SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                            end
                        end
                    end
                end)
            Items:AddList("Secondary Color (G)", rgbColour, state.Color.Secondary[2] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Secondary[2] = Index - 1
                        SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Secondary[2] = inputNum
                                SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                            end
                        end
                    end
                end)
            Items:AddList("Secondary Color (B)", rgbColour, state.Color.Secondary[3] + 1, nil, {},
                function(Index, onSelected, onListChange)
                    if onListChange then
                        state.Color.Secondary[3] = Index - 1
                        SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                    end
                    if onSelected then
                        local input = Input("RGB Color:")
                        if input and tonumber(input) then
                            local inputNum = tonumber(input)
                            if inputNum >= 0 and inputNum <= 255 then
                                state.Color.Secondary[3] = inputNum
                                SetVehicleCustomSecondaryColour(state.handle, table.unpack(state.Color.Secondary))
                            end
                        end
                    end
                end)
        end
    end, function()

    end)
    menus.Tint:IsVisible(function(Items)
        for i = 0, 6 do
            Items:CheckBox(Config.Vehicles.Mods.Tint[i], nil, state.Tint == i, {}, function(onSelected, Checked)
                if onSelected then
                    if Checked then
                        state.Tint = i
                    else
                        state.Tint = 0
                    end
                    SetVehicleWindowTint(state.handle, state.Tint)
                end
            end)
        end
    end, function()

    end)
    menus.Plate:IsVisible(function(Items)
        for i = 0, 12 do
            Items:CheckBox(Config.Vehicles.Mods.Plate[i], nil, state.Plate == i, {}, function(onSelected, Checked)
                if onSelected then
                    if Checked then
                        state.Plate = i
                    else
                        state.Plate = 0
                    end
                    SetVehicleNumberPlateTextIndex(state.handle, state.Plate)
                end
            end)
        end
    end, function()

    end)
    menus.ModCategories:IsVisible(function(Items)
        for category, mods in pairs(Config.Vehicles.Mods.ModCategories) do
            Items:AddButton(category, "Mods: " .. #mods, { RightLabel = "→→→" }, function(onSelected)
                if onSelected then
                    menuData.category = category
                    menus.Category:SetSubtitle(category)
                end
            end, menus.Category)
        end
    end, function()

    end)
    menus.Category:IsVisible(function(Items)
        for _, mod in ipairs(Config.Vehicles.Mods.ModCategories[menuData.category]) do
            if GetNumVehicleMods(state.handle, mod) > 0 then
                Items:AddButton(Config.Vehicles.Mods.Mods[mod], "Variants: " .. GetNumVehicleMods(state.handle, mod),
                    { RightLabel = "→→→" }, function(onSelected)
                        if onSelected then
                            menuData.mod = mod
                            menus.Mod:SetSubtitle(Config.Vehicles.Mods.Mods[mod])
                        end
                    end, menus.Mod)
            end
        end
    end, function()

    end)
    menus.Mod:IsVisible(function(Items)
        Items:CheckBox("Disabled", nil, state.Mods[menuData.mod] == -1, {}, function(onSelected, Checked)
            if onSelected then
                if Checked then
                    state.Mods[menuData.mod] = -1
                    SetVehicleMod(state.handle, menuData.mod, state.Mods[menuData.mod], false)
                end
            end
        end)
        for i = 0, GetNumVehicleMods(state.handle, menuData.mod) - 1 do
            Items:CheckBox((GetLabelText(GetModTextLabel(state.handle, menuData.mod, i)) or "Mod") .. " (#" .. i .. ")",
                nil,
                state.Mods[menuData.mod] == i, {}, function(onSelected, Checked)
                    if onSelected then
                        if Checked then
                            state.Mods[menuData.mod] = i
                            SetVehicleMod(state.handle, menuData.mod, state.Mods[menuData.mod], false)
                        else
                            state.Mods[menuData.mod] = -1
                            SetVehicleMod(state.handle, menuData.mod, state.Mods[menuData.mod], false)
                        end
                    end
                end)
        end
    end, function()

    end)
end
