while not Spectrum.Loaded do
    Wait(0)
end

for _, storeData in pairs(Spectrum.stores) do
    for _, location in ipairs(storeData.locations) do
        if storeData.blip == nil or (storeData.attribute and not Spectrum.PlayerData.attributes[storeData.attribute]) then
            goto continue
        end
        local blip = AddBlipForCoord(location)
        if storeData.blip.sprite then
            SetBlipSprite(blip, storeData.blip.sprite)
        end
        if storeData.blip.colour then
            SetBlipColour(blip, storeData.blip.colour)
        end
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(storeData.name)
        EndTextCommandSetBlipName(blip)
        ::continue::
    end
end

local storeMenu = RageUI.CreateMenu("placeholder", "what are you looking at?")

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for store, storeData in pairs(Spectrum.stores) do
            for _, location in ipairs(storeData.locations) do
                if #(GetEntityCoords(PlayerPedId()) - location) <= storeData.range and (not storeData.attribute or Spectrum.PlayerData.attributes[storeData.attribute]) then
                    if Spectrum.currentStore.current == nil then
                        HelpText("Press ~INPUT_CONTEXT~ to view " ..
                            (storeData.colour and storeData.colour or "~s~") .. storeData.name)
                        if IsControlJustPressed(0, 51) then
                            Spectrum.currentStore.current = store
                            Spectrum.currentStore.currentLoc = location
                            storeMenu:SetTitle(storeData.menu.title)
                            storeMenu:SetSubtitle(storeData.menu.description)
                            if storeData.menu.banner then
                                storeMenu:SetBanner(storeData.menu.banner)
                            else
                                storeMenu:ResetBanner()
                            end
                            RageUI.Visible(storeMenu, true)
                        end
                    elseif IsControlJustPressed(0, 51) then
                        Spectrum.currentStore.current = nil
                        Spectrum.currentStore.currentLoc = nil
                        RageUI.Visible(storeMenu, false)
                    end
                elseif Spectrum.currentStore.currentLoc == location or not RageUI.Visible(storeMenu) then
                    Spectrum.currentStore.current = nil
                    Spectrum.currentStore.currentLoc = nil
                    if RageUI.Visible(storeMenu) then
                        RageUI.Visible(storeMenu, false)
                    end
                end
            end
        end
    end
end)

function RageUI.PoolMenus:Store()
    storeMenu:IsVisible(function(Items)
        if not Spectrum.currentStore.current or not Spectrum.stores[Spectrum.currentStore.current] then
            RageUI.Visible(storeMenu, false)
            goto continue
        end
        for item, itemData in pairs(Spectrum.stores[Spectrum.currentStore.current].items) do
            local name = "Unknown Item"
            if itemData.type == 0 then
                name = (item == "clean" and "Clean Money" or "Dirty Money")
            elseif itemData.type == 1 then
                name = Spectrum.items[item].displayName
            elseif itemData.type == 2 or itemData.type == 3 then
                name = Config.Weapons[item].displayName .. (itemData.type == 3 and "Ammo" or "")
            end

            Items:AddButton(
                name .. ((itemData.quantity and itemData.quantity > 1) and (" (x" .. itemData.quantity .. ")") or ""),
                nil,
                {
                    RightLabel = "~" ..
                        (Spectrum.stores[Spectrum.currentStore.current].items[item].clean and "g" or "r") ..
                        "~$" .. FormatMoney(itemData.cost),
                    IsDisabled = (itemData.type == 2 and HasPedGotWeapon(PlayerPedId(), item, false))
                },
                function(onSelected)
                    if onSelected then
                        TriggerServerEvent("Spectrum:Purchase", Spectrum.currentStore.current,
                            Spectrum.currentStore.currentLoc, item)
                    end
                end)
        end
        ::continue::
    end, function()

    end)
end
