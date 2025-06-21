Citizen.CreateThread(function()
    while true do
        Wait(0)
        local base = os.time(os.date("!*t")) / 2 + 360
        Spectrum.Environment.time.base = base
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        TriggerClientEvent("Spectrum:Environment", -1, Spectrum.Environment.weather, Spectrum.Environment.time.base)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        Spectrum.Environment.CycleTimer = Spectrum.Environment.CycleTimer + 1
        if Spectrum.Environment.CycleTimer == 10 then
            Spectrum.Environment.CycleTimer = 0
            if Config.Weather.Cycle[Spectrum.Environment.weather] then
                Spectrum.Environment.weather = Config.Weather.Cycle
                    [math.random(#Config.Weather.Cycle[Spectrum.Environment.weather])]
            end
        end
        TriggerClientEvent("Spectrum:Environment", -1, Spectrum.Environment.weather, Spectrum.Environment.time.base)
    end
end)
