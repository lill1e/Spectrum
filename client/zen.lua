while not Spectrum.Loaded do
    Wait(0)
end
if Spectrum.debug then
    Spectrum.zen = GetGameTimer()

    Scaleform.Load("MIDSIZED_MESSAGE")
    local scaleform = Scaleform.Create("MIDSIZED_MESSAGE", "SHOW_SHARD_MIDSIZED_MESSAGE", "~y~Zen Mode",
        "Get back to work :3 (or use /reset_zen)", 11, false, false)

    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if GetGameTimer() - Spectrum.zen >= 60000 * 5 then
                scaleform:Draw()
            end
        end
    end)

    RegisterCommand("reset_zen", function()
        Spectrum.zen = GetGameTimer()
    end, false)
end
