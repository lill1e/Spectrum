RegisterNetEvent("Spectrum:Doors", function(doorStates)
    for k, v in pairs(Config.Doors) do
        AddDoorToSystem(k, v.model, v.position)
        DoorSystemSetDoorState(k, doorStates[k])
    end
end)

RegisterNetEvent("Spectrum:Doors:State", function(door, newState)
    if Config.Doors[door] then
        DoorSystemSetDoorState(door, newState)
    end
end)

RegisterCommand("sd", function(_, args)
    if Config.Doors[args[1]] then
        DoorSystemSetDoorState(args[1], DoorSystemGetDoorState(args[1]) == 0 and 1 or 0)
    end
end, false)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local meCoords = GetEntityCoords(PlayerPedId())
        local closest
        local closestDist
        if Spectrum.Job.current then
            for doorHash, door in pairs(Config.Doors) do
                local dist = #(meCoords - door.position)
                if dist <= 1.5 and (not closest or (dist < closestDist)) then
                    closest = doorHash
                    closestDist = dist
                end
            end
            if closest then
                HelpText((DoorSystemGetDoorState(closest) == 1 and "~r~Locked" or "~g~Unlocked") ..
                    "~s~ (Press ~INPUT_CONTEXT~ to toggle)")
                if IsControlJustPressed(0, 51) then
                    TriggerServerEvent("Spectrum:Doors:Toggle", closest)
                end
            end
        end
    end
end)
