RegisterNetEvent("Spectrum:Job:Toggle", function(job, status)
    local source = tostring(source)
    if Spectrum.players[source].jobs[job] then
        if status and not Spectrum.jobs[job][source] then
            for j, jobPlayers in pairs(Spectrum.jobs) do
                if j ~= job and jobPlayers[source] then
                    Spectrum.jobs[j][source] = nil
                end
            end
            Spectrum.jobs[job][source] = {}
        elseif not status and Spectrum.jobs[job][source] then
            Spectrum.jobs[job][source] = nil
            for item, data in pairs(Config.Jobs[job].items) do
                if data.restrict and Spectrum.players[source].items[item] then
                    RemoveItem(source, item, Spectrum.players[source].items[item])
                end
            end
            for id, weapon in pairs(Spectrum.players[source].weapons) do
                if Config.Jobs[job].weapons[weapon] and Config.Jobs[job].weapons[weapon].restrict then
                    RemoveWeapon(source, id)
                end
            end
        end
    end
end)

RegisterNetEvent("Spectrum:Job:Item", function(job, item)
    local source = tostring(source)
    if Spectrum.jobs[job] and Spectrum.jobs[job][source] and Config.Jobs[job].items[item] and (Config.Jobs[job].items[item].rank == nil or Spectrum.players[source].jobs[job] <= Config.Jobs[job].items[item].rank) then
        AddItem(source, item, 1)
    else
        -- TODO: add logging
    end
end)

RegisterNetEvent("Spectrum:Job:Weapon", function(job, weapon)
    local source = tostring(source)
    if Spectrum.jobs[job] and Spectrum.jobs[job][source] and Config.Jobs[job].weapons[weapon] and (Config.Jobs[job].weapons[weapon].rank == nil or Spectrum.players[source].jobs[job] <= Config.Jobs[job].weapons[weapon].rank) then
        if not HasWeapon(source, weapon) then
            AddWeapon(source, CreateWeapon(weapon), Config.Jobs[job].weapons[weapon].ammo)
            TriggerClientEvent("Spectrum:Job:ReleaseWeapons", source)
        else
            Notification(source, "You already posses a ~b~" .. Config.Weapons[weapon])
        end
    else
        -- TODO: add logging
    end
end)
