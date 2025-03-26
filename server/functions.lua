function GetSteamHex(source)
    return Spectrum.debug and "steam:debug" or GetPlayerIdentifierByType(source, "steam")
end

function Notification(source, text)
    TriggerClientEvent("Spectrum:Notification", source, text)
end
