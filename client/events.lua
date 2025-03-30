RegisterNetEvent("Spectrum:Notification", function(notification)
    Notification(notification)
end)

RegisterNetEvent("Spectrum:SetHealth", function(health, token)
    Spectrum.libs.Callbacks.callback("verifyToken", function(verified)
        if verified then
            SetEntityHealth(PlayerPedId(), health)
        end
    end, token)
end)
