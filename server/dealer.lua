RegisterNetEvent("Spectrum:Dealer:T", function(product, ped, token, session)
    local source = tostring(source)
    local entity = NetworkGetEntityFromNetworkId(ped)
    local tkStatus = Spectrum.libs.callbackFunctions.verifyToken(source, token)
    if Config.Drugs.Dealer.Items[product] then
        if DoesEntityExist(entity) then
            if tkStatus and session == Entity(entity).state.deal_session then
                local priceRange = Config.Drugs.Dealer.Items[product].range
                local payout = math.random(priceRange[1], priceRange[2])
                local quantity = math.random(math.min(Config.Drugs.Dealer.Items[product].max,
                    Spectrum.players[source].items[product]))
                local totalPayout = quantity * payout
                print("debug:", totalPayout)
                RemoveItem(source, product, quantity)
                AddCash(source, true, not Spectrum.items[product].illegal, totalPayout)
                TriggerClientEvent("Spectrum:Dealer:SellConclusion", source, product, quantity, totalPayout)
            else
                -- TODO: add logging
            end
        end
    end
end)
