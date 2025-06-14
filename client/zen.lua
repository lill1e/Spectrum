while not Spectrum.Loaded do
    Wait(0)
end
if Spectrum.debug then
    Spectrum.zen = GetGameTimer()

    local scaleform = Scaleform.Load("MIDSIZED_MESSAGE")
    scaleform:Call("SHOW_SHARD_MIDSIZED_MESSAGE", "~y~Zen Mode", "Get back to work :3 (or use /reset_zen)", 11, false,
        false)
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if GetGameTimer() - Spectrum.zen >= 1000 * 5 then
                scaleform:DrawFullscreen()
            end
        end
    end)

    RegisterCommand("reset_zen", function()
        Spectrum.zen = GetGameTimer()
    end, false)
end
