DealerJobMenu = RageUI.CreateMenu("Shipments", "~o~What's the order?")
local jobs = {
    BeachDealer = true,
    MilitaryDealer = true,
    AsiaDealer = true,
    MafiaDealer = true,
    ExclusiveDealer = true
}
local menus = {}
local menuData = {
    Loaded = nil,
    Shipment = nil,
    Shipments = nil,
    Next = nil
}
local menusVal = {}
for _, menu in pairs(menus) do
    table.insert(menusVal, menu)
end

AddEventHandler("Spectrum:Job:Terminate", function(j)
    if jobs[j] then
        menuData = {
            Loaded = nil,
            Shipment = nil,
            Shipments = nil,
            Next = nil
        }
    end
end)

RegisterNetEvent("Spectrum:Job:NicheTerminate", function(t)
    if Spectrum.Job.current and jobs[Spectrum.Job.current] then
        menuData.Next = GetGameTimer() + t
    end
end)

RegisterNetEvent("Spectrum:Job:Shipment", function(location)
    Notification("A ~o~Shipment ~s~has arrived in ~b~Los Santos~s~, check your GPS")
    ClearGpsPlayerWaypoint()
    SetNewWaypoint(location.x, location.y)
end)

function RageUI.PoolMenus:Dealer()
    if Spectrum.Job.current and jobs[Spectrum.Job.current] then
        if menuData.Loaded == nil then
            Spectrum.libs.Callbacks.callback("getShipments", function(shipment)
                menuData.Shipments = shipment.shipments
                menuData.Shipment = 1
                menuData.Next = GetGameTimer() + shipment.dist
                menuData.Loaded = true
            end, Spectrum.Job.current)
        end
    else
        if RageUI.Visible(DealerJobMenu) or RageUI.AnyVisible(menusVal) then
            RageUI.CloseAll()
        end
    end
    DealerJobMenu:IsVisible(function(Items)
        if menuData.Loaded then
            local timeDist = menuData.Next - GetGameTimer()
            Items:AddButton(
                timeDist > 0 and ("Shipments available in: " .. ConvertTime(timeDist)) or
                "Shipments are available to order!",
                nil, {}, function()

                end)
            if not TableEmpty(menuData.Shipments) then
                Items:AddSeparator("")
                for k, v in pairs(menuData.Shipments) do
                    Items:AddButton(v.name,
                        ((v.method.vehicle ~= nil) and ("Delivered in a ~b~" .. Config.Vehicles.Names[GetHashKey(v.method.vehicle)]) or "Delivered in a ~b~crate"),
                        { RightLabel = "~r~$" .. v.cost, IsDisabled = timeDist > 0 }, function(onSelected)
                            if onSelected then
                                Spectrum.libs.Callbacks.callback("orderShipment", function(_)

                                end, Spectrum.Job.current, k)
                            end
                        end)
                end
            end
        end
    end, function()

    end)
end
