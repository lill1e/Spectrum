local inventoryMenu = RageUI.CreateMenu("Inventory", "~b~Your belongings")

RegisterNetEvent("Spectrum:RemoveItem", function(item, quantity)
    if Spectrum.PlayerData.items[item] then
        Spectrum.PlayerData.items[item] = Spectrum.PlayerData.items[item] > quantity and
            Spectrum.PlayerData.items[item] - quantity or nil
    end
end)

RegisterNetEvent("Spectrum:AddItem", function(item, quantity)
    Spectrum.PlayerData.items[item] = Spectrum.PlayerData.items[item] and Spectrum.PlayerData.items[item] + quantity or
        quantity
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
                    if onSelected then
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
    if Spectrum.HasLoaded then
        RageUI.Visible(inventoryMenu, not RageUI.Visible(inventoryMenu))
    end
end, false)
RegisterCommand("-inventory", function() end, false)
