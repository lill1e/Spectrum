function GetSteamHex(source)
    return Spectrum.debug and "steam:debug" or GetPlayerIdentifierByType(source, "steam")
end

function GetAllIdentifiers(source)
    local identifiers = {}
    for i = 1, GetNumPlayerIdentifiers(source) do
        table.insert(identifiers, GetPlayerIdentifier(source, i))
    end
    return identifiers
end

function Notification(source, text)
    TriggerClientEvent("Spectrum:Notification", source, text)
end
