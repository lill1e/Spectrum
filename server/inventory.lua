RegisterNetEvent("Spectrum:UseItem", function(item)
    local source = tostring(source)

    if Spectrum.players[source].items[item] and Spectrum.players[source].items[item] > 0 and Spectrum.items[item].usable then
        if Spectrum.items[item] then
            if Spectrum.items[item].removeOnUse or Spectrum.items[item].swapOnUse then
                Spectrum.players[source].items[item] = Spectrum.players[source].items[item] > 1 and
                    Spectrum.players[source].items[item] - 1 or nil
            elseif Spectrum.items[item].swapOnUse then
                Spectrum.players[source].items[Spectrum.items[item].swapOnUse.item] = Spectrum.players[source].items
                    [Spectrum.items[item].swapOnUse.item] and Spectrum.items[item].swapOnUse.item or
                    (Spectrum.players[source].items[Spectrum.items[item].swapOnUse.item] + Spectrum.items[item].swapOnUse.item)
            end
            if Spectrum.items[item].handler then
                Spectrum.items[item].handler(source)
            end
        end
    else
        -- TODO: This should not happen, maybe add some sort of protection/logging
    end
end)

function addItem(source, item, quantity)
    Spectrum.players[source].items[item] = Spectrum.players[source].items[item] and
        Spectrum.players[source].items[item] + quantity or quantity
end

function removeItem(source, item, quantity)
    Spectrum.players[source].items[item] = Spectrum.players[source].items[item] > quantity and
        Spectrum.players[source].items[item] - quantity or nil
end
