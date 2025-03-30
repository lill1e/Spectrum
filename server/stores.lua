RegisterNetEvent("Spectrum:Purchase", function(store, storeLoc, item)
    local source = tostring(source)

    if Spectrum.stores[store] and Spectrum.stores[store].items[item] and #(GetEntityCoords(GetPlayerPed(source)) - storeLoc) <= Spectrum.stores[store].range then
        if HasCash(source, Spectrum.stores[store].items[item].clean, Spectrum.stores[store].items[item].cost) then
            RemoveCash(source, Spectrum.stores[store].items[item].clean, Spectrum.stores[store].items[item].cost)
            if Spectrum.stores[store].items[item].type == 0 then
                AddCash(source, item == "clean",
                    Spectrum.stores[store].items[item].quantity and Spectrum.stores[store].items[item].quantity or 1)
            elseif Spectrum.stores[store].items[item].type == 1 then
                AddItem(source, item,
                    Spectrum.stores[store].items[item].quantity and Spectrum.stores[store].items[item].quantity or 1)
            elseif Spectrum.stores[store].items[item].type == 2 then
                CreateWeapon(source, item)
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
        -- TODO: add some action here, this should not ever happen
    end
end)
