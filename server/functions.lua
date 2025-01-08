function GetSteamHex(source)
    return Spectrum.debug and "steam:debug" or GetPlayerIdentifierByType(source, "steam")
end
