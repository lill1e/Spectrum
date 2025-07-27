while not Spectrum.loaded do
    Wait(0)
end

for doorHash, door in pairs(Config.Doors) do
    Spectrum.doors[doorHash] = door.default
end
TriggerClientEvent("Spectrum:Doors", -1, Spectrum.doors)

RegisterNetEvent("Spectrum:Doors:Toggle", function(door)
    local source = tostring(source)
    if Config.Doors[door] then
        if Config.Doors[door].job and Spectrum.jobs[Config.Doors[door].job][source] then
            Spectrum.doors[door] = Spectrum.doors[door] == 0 and 1 or 0
            TriggerClientEvent("Spectrum:Doors:State", source, door, Spectrum.doors[door])
        end
    end
end)
