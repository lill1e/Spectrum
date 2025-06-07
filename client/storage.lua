StorageMenu = RageUI.CreateMenu("Storage", "What is this???")
local storeItemMenu = RageUI.CreateSubMenu(StorageMenu, "Storage", "What is this???")
local storageLock = false

function RageUI.PoolMenus:Storage()
    if Spectrum.Storage.active and not RageUI.Visible(StorageMenu) and not RageUI.Visible(storeItemMenu) then
        TriggerServerEvent("Spectrum:Storage:Unlock", Spectrum.Storage.id)
        Spectrum.Storage = {}
    end
    if Spectrum.Storage.handle and ((GetVehiclePedIsIn(PlayerPedId(), false) ~= Spectrum.Storage.handle) and (GetClosest("CVehicle") ~= Spectrum.Storage.handle)) then
        RageUI.CloseAll()
    end
    StorageMenu:IsVisible(function(Items)
        if Spectrum.Storage.active then
            for item, quantity in pairs(Spectrum.Storage.items) do
                Items:AddButton(Spectrum.items[item].displayName, nil,
                    { RightLabel = "x" .. quantity, IsDisabled = storageLock },
                    function(onSelected)
                        if onSelected then
                            local input = "1"
                            if quantity > 1 then
                                input = Input("Amount to take from storage (Max: " .. quantity .. "):")
                            end
                            if input and tonumber(input) then
                                storageLock = true
                                local inputNum = tonumber(input)
                                if inputNum > quantity then
                                    inputNum = quantity
                                end
                                Spectrum.libs.Callbacks.callback("storagePull", function(pulled)
                                    if pulled > 0 then
                                        local count = quantity - pulled
                                        if count > 0 then
                                            Spectrum.Storage.items[item] = count
                                        else
                                            Spectrum.Storage.items[item] = nil
                                        end
                                        storageLock = false
                                    else
                                        storageLock = false
                                    end
                                end, Spectrum.Storage.id, item, inputNum)
                            end
                        end
                    end)
            end
            for id, weapon in pairs(Spectrum.Storage.weapons) do
                Items:AddButton(Config.Weapons[weapon.model].displayName, nil,
                    { RightLabel = weapon.rounds .. " ~b~Rounds", IsDisabled = storageLock },
                    function(onSelected)
                        if onSelected then
                            storageLock = true
                            Spectrum.libs.Callbacks.callback("storagePull", function(pulled)
                                if pulled > 0 then
                                    Spectrum.Storage.weapons[id] = nil
                                    storageLock = false
                                else
                                    storageLock = false
                                end
                            end, Spectrum.Storage.id, id, nil)
                        end
                    end)
            end
            if not TableEmpty(Spectrum.Storage.items) or not TableEmpty(Spectrum.Storage.weapons) then
                Items:AddSeparator("")
            else
                Items:AddButton("There is nothing in the ~b~storage", "You can add something with \"Store\"", {},
                    function()

                    end)
            end
            Items:AddButton("Store", nil, { RightLabel = "→→→" }, function()
            end, storeItemMenu)
        end
    end, function()

    end)
    storeItemMenu:IsVisible(function(Items)
        for item, quantity in pairs(Spectrum.PlayerData.items) do
            Items:AddButton(Spectrum.items[item].displayName, nil,
                { RightLabel = "x" .. quantity, IsDisabled = storageLock },
                function(onSelected)
                    if onSelected then
                        local input = "1"
                        if quantity > 1 then
                            input = Input("Quantity (Max : " .. quantity .. "):")
                        end
                        if input and tonumber(input) then
                            storageLock = true
                            local inputNum = tonumber(input)
                            if inputNum > quantity then
                                inputNum = quantity
                            end
                            Spectrum.libs.Callbacks.callback("storagePush", function(pushed)
                                if pushed > 0 then
                                    local count = Spectrum.Storage.items[item]
                                    if count ~= nil then
                                        Spectrum.Storage.items[item] = count + pushed
                                    else
                                        Spectrum.Storage.items[item] = pushed
                                    end
                                    storageLock = false
                                else
                                    storageLock = false
                                end
                            end, Spectrum.Storage.id, item, inputNum, nil)
                        end
                    end
                end)
        end
        for id, weapon in pairs(Spectrum.PlayerData.weapons) do
            local rounds = Spectrum.PlayerData.ammo[Config.Ammo[GetPedAmmoTypeFromWeapon_2(PlayerPedId(), weapon)]]
            if rounds == nil then
                rounds = 0
            end
            Items:AddButton(Config.Weapons[weapon].displayName, nil,
                { RightLabel = rounds .. " ~b~Rounds", IsDisabled = storageLock },
                function(onSelected)
                    if onSelected then
                        local input = "0"
                        if rounds > 0 then
                            input = Input("# of Rounds (Max: " .. rounds .. "):")
                        end
                        print((rounds == 0 and "none" or Config.Ammo[GetPedAmmoTypeFromWeapon_2(PlayerPedId(), weapon)]))
                        if input and tonumber(input) then
                            storageLock = true
                            local inputNum = tonumber(input)
                            if inputNum > rounds then
                                inputNum = rounds
                            end
                            Spectrum.libs.Callbacks.callback("storagePush", function(pushed)
                                    if pushed and type(pushed) == "table" and pushed.valid then
                                        Spectrum.Storage.weapons[pushed.id] = {
                                            model = pushed.model,
                                            rounds = pushed.rounds,
                                            id = id
                                        }
                                        storageLock = false
                                    else
                                        storageLock = false
                                    end
                                end, Spectrum.Storage.id, tonumber(id), inputNum,
                                (rounds == 0 and "none" or Config.Ammo[GetPedAmmoTypeFromWeapon_2(PlayerPedId(), weapon)]))
                        end
                    end
                end)
        end
        if Spectrum.PlayerData.numItems == 0 and Spectrum.PlayerData.numWeapons == 0 then
            Items:AddButton("There is nothing in your ~b~inventory", "You can grab something from the ~b~storage", {},
                function()

                end)
        end
    end, function()

    end)
end
