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
