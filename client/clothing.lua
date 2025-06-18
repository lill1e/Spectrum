for _, coord in ipairs(Config.Clothing.Stores) do
    local blip = AddBlipForCoord(coord)
    SetBlipSprite(blip, 73)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Clothing Store")
    EndTextCommandSetBlipName(blip)
end

local store = nil

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if Config.Clothing.Interiors[GetInteriorFromEntity(PlayerPedId())] and not Spectrum.PlayerData.dead and not Spectrum.StaffMenu.spectating then
            if not RageUI.AnyVisible({ ClothingMenu, SoloApparelMenu }) then
                HelpText("Press ~INPUT_CONTEXT~ to browse ~b~clothing")
                if IsControlJustPressed(0, 51) then
                    if RageUI.AnyVisible({ ClothingMenu, SoloApparelMenu }) then
                        Spectrum.skin.IsEditing = false
                        RageUI.CloseAll()
                    else
                        store = GetInteriorFromEntity(PlayerPedId())
                        Spectrum.skin.Outfit = true
                        Spectrum.skin.IsEditing = true
                        RageUI.Visible(ClothingMenu, true)
                    end
                end
            end
        end
        if RageUI.AnyVisible({ ClothingMenu, SoloApparelMenu }) then
            if store then
                if not Config.Clothing.Interiors[GetInteriorFromEntity(PlayerPedId())] then
                    ResetClothing()
                    Spectrum.skin.IsEditing = false
                    RageUI.CloseAll()
                    store = nil
                end
            else
                ResetClothing()
                Spectrum.skin.IsEditing = false
                RageUI.CloseAll()
            end
        elseif store then
            ResetClothing()
            Spectrum.skin.IsEditing = false
            RageUI.CloseAll()
            store = nil
        end
    end
end)
