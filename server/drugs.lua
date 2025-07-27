-- property interiors are non-existant
-- let's make a fake property
local properties = {
    [1] = {
        type = "Coke",
        states = {
            -- this is a table of times (end ts)
            pour = {},
            process = {
                -- ts = source
            },
            mash = {},
            sift = {},
            bag = {},
            debug = {}
        },
        output = {
            process = {
                -- cocaine_solid = 25
            }
        }
    }
}

local grabQueue = {}

RegisterNetEvent("Spectrum:Property:Stage", function(id, stage)
    local source = tostring(source)
    if properties[id] and not Spectrum.players[source].action then
        local stageData = Config.Drugs.Types[properties[id].type].stages[stage]
        local counter = 0
        for _, _ in pairs(properties[id].states[stage]) do
            counter = counter + 1
        end
        local hasItems = true
        for _, item in ipairs(stageData.input.items) do
            if not HasItemThreshold(source, item, stageData.input.count) then
                hasItems = false
                break
            end
        end
        if counter < stageData.threshold and hasItems then
            for _, item in ipairs(stageData.input.items) do
                RemoveItem(source, item, stageData.input.count)
            end
            local t = os.time() + (stageData.cooldown / 1000)
            properties[id].states[stage][t] = source
            TriggerClientEvent("Spectrum:Property:Action:Start", source, stage, stageData.cooldown,
                not stageData.background)
        elseif not hasItems then
            TriggerClientEvent("Spectrum:Property:Action:Empty", source)
        else
            TriggerClientEvent("Spectrum:Property:Action:Full", source)
        end
    else
        TriggerClientEvent("Spectrum:Property:Action:Busy", source)
    end
end)

RegisterNetEvent("Spectrum:Property:StageGrab", function(id, stage)
    local source = tostring(source)
    local new = true
    for _, entry in ipairs(grabQueue) do
        if entry.source == source then
            new = false
            break
        end
    end
    if new then
        table.insert(grabQueue, { source = source, property = id, stage = stage })
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        for id, property in ipairs(properties) do
            for state, actions in pairs(property.states) do
                for ts, source in pairs(actions) do
                    if os.time() >= ts then
                        properties[id].states[state][ts] = nil
                        if Config.Drugs.Types[property.type].stages[state].background then
                            local data = properties[id].output[state]
                            local output = Config.Drugs.Types[property.type].stages[state].output
                            for _, item in ipairs(output.items) do
                                if not data[item] then
                                    properties[id].output[state][item] = output.count
                                else
                                    properties[id].output[state][item] = properties[id].output[state][item] +
                                        output.count
                                end
                            end
                            TriggerClientEvent("Spectrum:Property:StageState", -1, id, state,
                                properties[id].output[state])
                        else
                            for _, item in ipairs(Config.Drugs.Types[property.type].stages[state].output.items) do
                                AddItem(source, item, Config.Drugs.Types[property.type].stages[state].output.count, true)
                            end
                        end

                        TriggerClientEvent("Spectrum:Property:Action:End", source, state,
                            not Config.Drugs.Types[property.type].stages[state].background)
                    end
                end
            end
        end
        if #grabQueue > 0 then
            local first = grabQueue[1]
            table.remove(grabQueue, 1)
            local res = AddItemMost(first.source,
                Config.Drugs.Types[properties[first.property].type].stages[first.stage].output.displayItem,
                Config.Drugs.Types[properties[first.property].type].stages[first.stage].output.count)
            if res > 0 then
                properties[first.property].output[first.stage][Config.Drugs.Types[properties[first.property].type].stages[first.stage].output.displayItem] =
                    properties[first.property].output[first.stage]
                    [Config.Drugs.Types[properties[first.property].type].stages[first.stage].output.displayItem] - res
                TriggerClientEvent("Spectrum:Property:StageState", -1, first.property, first.stage,
                    properties[first.property].output[first.stage])
                TriggerClientEvent("Spectrum:Property:Action:GrabEnd", first.source)
            end
        end
    end
end)
