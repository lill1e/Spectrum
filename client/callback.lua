while not Spectrum.Loaded do
    Wait(0)
end
Spectrum.Callbacks = {}
Spectrum.NumCallbacks = 0
Spectrum.libs.Callbacks = {}

Spectrum.libs.Callbacks.callback = function(type, func, ...)
    Spectrum.Callbacks[Spectrum.NumCallbacks] = func
    Spectrum.NumCallbacks = Spectrum.NumCallbacks + 1
    TriggerServerEvent("Spectrum:Callback", type, ...)
end

RegisterNetEvent("Spectrum:Callback", function(n, val)
    Spectrum.Callbacks[n](val)
    Spectrum.Callbacks[n] = nil
end)
