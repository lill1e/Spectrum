RegisterNetEvent("Spectrum:Property:Toggle", function(property)
    local source = tostring(source)
    if Spectrum.properties[property] and Spectrum.properties[property].owner == Spectrum.players[source].id then
        Spectrum.properties[property].locked = not Spectrum.properties[property].locked
        TriggerClientEvent("Spectrum:Property:Dispatch", -1, property, "locked", Spectrum.properties[property].locked)
        TriggerClientEvent("Spectrum:Property:Release", source)
    end
end)
