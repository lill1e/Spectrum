RegisterNetEvent("Spectrum:Licenses:Grant", function(license)
    if Config.Licenses[license] then
        table.insert(Spectrum.PlayerData.licenses, license)
        Notification("You have been granted a ~y~" .. Config.Licenses[license].displayName)
    end
end)

RegisterNetEvent("Spectrum:Licenses:Remove", function(license)
    if Config.Licenses[license] then
        local index = TableIndexOf(Spectrum.PlayerData.licenses, license)
        if index ~= 0 then
            table.remove(Spectrum.PlayerData.licenses, index)
            Notification("You have had your ~y~" .. Config.Licenses[license].displayName .. " ~s~removed")
        end
    end
end)
