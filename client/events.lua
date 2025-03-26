RegisterNetEvent("Spectrum:Notification", function(notification)
    Notification(notification)
end)

RegisterNetEvent("Spectrum:SetHealth", function (health)
    SetEntityHealth(PlayerPedId(), health)
end)