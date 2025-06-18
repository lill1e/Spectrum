LegalJobMenu = RageUI.CreateMenu("Legal Services", "~b~The Right Way")
local job = "Legal"
local menus = {
    Property = RageUI.CreateSubMenu(LegalJobMenu, "Legal Services", "~y~Property Services"),
    Licenses = RageUI.CreateSubMenu(LegalJobMenu, "Legal Services", "~y~License Services")
}
local menuData = {
    Property = {
        owner = -1,
        interior = false,
        visible = true
    },
    Licenses = {
        waiting = true,
        licenses = {},
        target = -1,
        locked = false
    }
}
local licenses = { "driving", "weapons" }
local menusVal = {}
for _, menu in pairs(menus) do
    table.insert(menusVal, menu)
end

function RageUI.PoolMenus:LegalJob()
    if Spectrum.Job.current == job then
    else
        if RageUI.Visible(LegalJobMenu) or RageUI.AnyVisible(menusVal) then
            RageUI.CloseAll()
        end
    end
    LegalJobMenu:IsVisible(function(Items)
        Items:AddButton("Change License Plate",
            IsPedInAnyVehicle(PlayerPedId(), false) and "Nothing Inappropriate" or
            "You must be inside a ~b~vehicle ~s~to do this",
            { RightLabel = "→→→", IsDisabled = not IsPedInAnyVehicle(PlayerPedId(), false) }, function(onSelected)
                if onSelected then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    local oldPlate = StripPlate(GetVehicleNumberPlateText(vehicle):upper())
                    if vehicle ~= 0 then
                        local newPlate = Input("Enter New Plate (leave empty for random):")
                        if newPlate then
                            newPlate = newPlate:upper()
                        end
                        local input = Input("Enter \"yes\" to confirm:")
                        if input and input:lower() == "yes" then
                            Spectrum.libs.Callbacks.callback("legalPlateChange", function(plate)
                                if plate ~= nil then
                                    Notification("Vehicle Reassignment:\n~b~" .. oldPlate .. " ~s~-> ~b~" .. plate)
                                end
                            end, oldPlate:upper(), newPlate)
                        end
                    else
                        Notification("You must be in a ~b~vehicle ~s~to perform this action")
                    end
                end
            end)
        Items:AddButton("Grant License", nil, { RightLabel = "→→→" }, function(onSelected)
            if onSelected then
                local target = GetClosestPlayer()
                if target then
                    menuData.Licenses.waiting = true
                    RageUI.Visible(menus.Licenses, true)
                    menuData.Licenses.target = target
                    Spectrum.libs.Callbacks.callback("legalFetchLicenses", function(userLicenses)
                        menuData.Licenses.licenses = {}
                        for _, license in ipairs(userLicenses) do
                            menuData.Licenses.licenses[license] = true
                        end
                        menuData.Licenses.waiting = false
                    end, tostring(target))
                else
                    Notification("You must be in range of another ~b~player ~s~in order to grant ~b~licenses")
                end
            end
        end)
    end, function()

    end)
    menus.Licenses:IsVisible(function(Items)
        if menuData.Licenses.waiting then
            Items:AddButton("Fetching available ~y~licenses", nil, {}, function() end)
        else
            local s = false
            for _, license in ipairs(licenses) do
                if not menuData.Licenses.licenses[license] then
                    if not s then
                        s = true
                    end
                    Items:AddButton(Config.Licenses[license].displayName, "Don't abuse this",
                        { IsDisabled = menuData.Licenses.locked },
                        function(onSelected)
                            if onSelected then
                                local input = Input("Enter \"yes\" to confirm:")
                                if input and input:lower() == "yes" then
                                    menuData.Licenses.locked = true
                                    Spectrum.libs.Callbacks.callback("legalGrantLicense", function(status)
                                        if status then
                                            menuData.Licenses.licenses[license] = true
                                            Notification("This ~b~player ~s~has been granted a ~y~" ..
                                                Config.Licenses[license].displayName)
                                        else
                                            Notification("There was a problem granting a ~b~license")
                                        end
                                        menuData.Licenses.locked = false
                                    end, tostring(menuData.Licenses.target), license)
                                end
                            end
                        end)
                end
            end
            if not s then
                Items:AddButton("There are no avaiable ~y~licenses", nil, {}, function() end)
            end
        end
    end, function() end)
end
