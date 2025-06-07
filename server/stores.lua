RegisterNetEvent("Spectrum:Purchase", function(store, storeLoc, item)
    local source = tostring(source)

    if Spectrum.stores[store] and Spectrum.stores[store].items[item] and #(GetEntityCoords(GetPlayerPed(source)) - storeLoc) <= Spectrum.stores[store].range and (not Spectrum.stores[store].attribute or Spectrum.players[source].attributes[Spectrum.stores[store].attribute]) then
        if Spectrum.stores[store].items[item].clean and (HasCash(source, true, Spectrum.stores[store].items[item].clean, Spectrum.stores[store].items[item].cost) or HasCash(source, false, Spectrum.stores[store].items[item].clean, Spectrum.stores[store].items[item].cost)) or HasCash(source, true, Spectrum.stores[store].items[item].clean, Spectrum.stores[store].items[item].cost) then
            if HasItemSpace(source, item, 1) then
                if Spectrum.stores[store].items[item].clean then
                    if HasCash(source, true, true, Spectrum.stores[store].items[item].cost) then
                        RemoveCash(source, true, true, Spectrum.stores[store].items[item].cost)
                    else
                        RemoveCash(source, false, true, Spectrum.stores[store].items[item].cost)
                    end
                else
                    RemoveCash(source, true, Spectrum.stores[store].items[item].clean,
                        Spectrum.stores[store].items[item].cost)
                end
                if Spectrum.stores[store].items[item].type == 0 then
                    AddCash(source, true, item == "clean",
                        Spectrum.stores[store].items[item].quantity and Spectrum.stores[store].items[item].quantity or 1)
                elseif Spectrum.stores[store].items[item].type == 1 then
                    AddItem(source, item,
                        Spectrum.stores[store].items[item].quantity and Spectrum.stores[store].items[item].quantity or 1)
                elseif Spectrum.stores[store].items[item].type == 2 then
                    AddWeapon(source, CreateWeapon(item), 0)
                elseif Spectrum.stores[store].items[item].type == 3 then
                    AddAmmo(source, item,
                        Spectrum.stores[store].items[item].quantity and Spectrum.stores[store].items[item].quantity or 1)
                end
            else
                Notification(source,
                    "You do not have enough ~" ..
                    (Spectrum.stores[store].items[item].clean and "g" or "r") .. "~money~s~ for this item")
            end
        else
            Notification(source,
                "You are unable to hold a " .. Spectrum.items[item].displayName)
        end
    else
        -- TODO: add some action here, this should not ever happen
    end
end)
