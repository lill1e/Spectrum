local inventoryMenu = RageUI.CreateMenu("Inventory", "~b~Your belongings")

RegisterNetEvent("Spectrum:Inventory", function(item, quantity, type, itemType)
    local condFlag = true
    if type == 1 then
        if itemType == 1 then
            Spectrum.PlayerData.items[item] = Spectrum.PlayerData.items[item] and
                Spectrum.PlayerData.items[item] + quantity or
                quantity
        elseif itemType == 2 then
            GiveWeaponToPed(PlayerPedId(), GetHashKey(item), 0, false, false)
        else
            Spectrum.PlayerData.ammo[item] = Spectrum.PlayerData.ammo[item] + quantity
            SetPedAmmoByType(PlayerPedId(), GetHashKey(item),
                GetPedAmmoByType(PlayerPedId(), GetHashKey(item)) + quantity)
        end
    elseif type == 2 then
        if itemType == 1 then
            if Spectrum.PlayerData.items[item] then
                Spectrum.PlayerData.items[item] = (Spectrum.PlayerData.items[item] > quantity and
                    Spectrum.PlayerData.items[item] - quantity or nil)
            else
                condFlag = false
            end
        elseif itemType == 2 then
            RemoveWeaponFromPed(PlayerPedId(), GetHashKey(item))
        else
            Spectrum.PlayerData.ammo[item] = Spectrum.PlayerData.ammo[item] >= quantity and
                Spectrum.PlayerData.ammo[item] - quantity or 0
            local ammoCount = GetPedAmmoByType(PlayerPedId(), GetHashKey(item))
            SetPedAmmoByType(PlayerPedId(), GetHashKey(item), ammoCount < 0 and quantity or ammoCount - quantity)
        end
    end
    if condFlag then
        SendNUIMessage({
            action = "notification",
            type = type,
            item = (itemType == 2 or itemType == 3) and Config.Weapons[item].displayName or
                Spectrum.items[item].displayName,
            itemType = itemType,
            quantity = quantity
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if Spectrum.Loaded and Spectrum.Spawned and not IsPedShooting(PlayerPedId()) then
            for k, _ in pairs(Spectrum.PlayerData.ammo) do
                if GetPedAmmoByType(PlayerPedId(), k) ~= Spectrum.PlayerData.ammo[k] then
                    Spectrum.PlayerData.ammo[k] = GetPedAmmoByType(PlayerPedId(), k)
                    TriggerServerEvent("Spectrum:Ammo", k, Spectrum.PlayerData.ammo[k])
                end
            end
        end
    end
end)

RegisterNetEvent("Spectrum:InventoryRelease", function()
    Spectrum.InventoryLock = false
end)

function RageUI.PoolMenus:Inventory()
    inventoryMenu:IsVisible(function(Items)
        Items:AddButton("Clean Money", nil, { RightLabel = "~g~$" .. FormatMoney(Spectrum.PlayerData.money.clean) },
            function(onSelected)

            end, inventoryMenu)
        Items:AddButton("Dirty Money", nil, { RightLabel = "~r~$" .. FormatMoney(Spectrum.PlayerData.money.dirty) },
            function(onSelected)

            end, inventoryMenu)

        if TableLength(Spectrum.PlayerData.items) > 0 then
            Items:AddSeparator("")

            for k, v in pairs(Spectrum.PlayerData.items) do
                Items:AddButton(Spectrum.items[k].displayName, nil, { RightLabel = "x" .. v }, function(onSelected)
                    if onSelected and not Spectrum.InventoryLock and Spectrum.items[k].usable and (type(Spectrum.items[k].usable) == "boolean" or Spectrum.items[k].usable > 0) then
                        Spectrum.InventoryLock = true
                        TriggerServerEvent("Spectrum:UseItem", k)
                    end
                end)
            end
        else
            Items:AddButton("Your ~b~inventory ~s~is empty.", nil, {}, function(onSelected)

            end, inventoryMenu)
        end
    end, function()

    end)
end

RegisterKeyMapping("+inventory", "Inventory Menu", "keyboard", "f1")
RegisterCommand("+inventory", function()
    if Spectrum.Loaded then
        RageUI.Visible(inventoryMenu, not RageUI.Visible(inventoryMenu))
    end
end, false)
RegisterCommand("-inventory", function() end, false)
