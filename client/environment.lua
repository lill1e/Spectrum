RegisterNetEvent("Spectrum:Environment", function(weather, base)
    if weather ~= Spectrum.Environment.weather then
        Spectrum.Environment.weather = weather
        Spectrum.Environment.update = true
    end
    Spectrum.Environment.time.base = base
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if Spectrum.Environment.update then
            SetWeatherTypeOvertimePersist(Spectrum.Environment.weather, 15.0)
            Wait(15000)
        end
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(Spectrum.Environment.weather)
        SetWeatherTypeNow(Spectrum.Environment.weather)
        SetWeatherTypeNowPersist(Spectrum.Environment.weather)
        if Spectrum.Environment.weather == "XMAS" then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        elseif Spectrum.Environment.update then
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
        Spectrum.Environment.update = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if GetGameTimer() - 500 > Spectrum.Environment.baseChangeTime then
            Spectrum.Environment.time.base = Spectrum.Environment.time.base + 0.25
            Spectrum.Environment.baseChangeTime = GetGameTimer()
        end
        Spectrum.Environment.time.minute = math.floor(Spectrum.Environment.time.base % 60)
        Spectrum.Environment.time.hour = math.floor((Spectrum.Environment.time.base / 60) % 24)
        NetworkOverrideClockTime(Spectrum.Environment.time.hour, Spectrum.Environment.time.minute, 0.0)
    end
end)
