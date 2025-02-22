RegisterNetEvent("Spectrum:Notification", function(notification)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(notification)
    DrawNotification(false, false)
end)

RegisterNetEvent("Spectrum:SetHealth", function (health)
    SetEntityHealth(PlayerPedId(), health)
end)