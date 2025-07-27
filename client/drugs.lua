local actionLock = false
local takeLock = false
local state = {
    type = "Coke",
    stages = {
        pour = false,
        process = {},
        mash = false,
        sift = false,
        bag = false
    },
    count = 0
}
local outputs = {}
local endTime = nil
local totalTime = nil

local actionTimerbar

RegisterNetEvent("Spectrum:Property:Action:GrabEnd", function()
    takeLock = false
end)

RegisterNetEvent("Spectrum:Property:StageState", function(id, stage, output)
    outputs[stage] = output
end)

RegisterNetEvent("Spectrum:Property:Action:Empty", function()
    actionLock = false
    Notification("You do not have sufficient materials for this task")
end)

RegisterNetEvent("Spectrum:Property:Action:Busy", function()
    actionLock = false
    Notification("You already doing something, please finish your current task")
end)

RegisterNetEvent("Spectrum:Property:Action:Full", function()
    actionLock = false
    Notification("There is already too many of this action going on, please wait or do something else")
end)

RegisterNetEvent("Spectrum:Property:Action:Start", function(stage, time, fullLock)
    Notification("You start to " ..
        Config.Drugs.Types[Config.Drugs.Interiors[GetInteriorFromEntity(PlayerPedId())]].stages[stage].text)
    if fullLock then
        Spectrum.Property.action = stage
        totalTime = time
        endTime = GetGameTimer() + time
        actionTimerbar:SetStatus(1.0 - ((endTime - GetGameTimer()) / totalTime))
        actionTimerbar:Drawing(true)
    else
        actionLock = false
    end
end)

RegisterNetEvent("Spectrum:Property:Action:End", function(stage, notify)
    actionLock = false
    actionTimerbar:Drawing(false)
    if notify then
        if Config.Drugs.Interiors[GetInteriorFromEntity(PlayerPedId())] then
            Notification(Config.Drugs.Types[Config.Drugs.Interiors[GetInteriorFromEntity(PlayerPedId())]].stages[stage]
                .endText)
        else
            Notification("You have finished your previous action")
        end
    end
end)

Citizen.CreateThread(function()
    while not Timerbars do
        Wait(0)
    end
    actionTimerbar = Timerbars.New(Timerbars.Types.Progress, "Action", 0.0)
    while true do
        Wait(0)
        if totalTime and endTime and (GetGameTimer() < endTime) then
            actionTimerbar:SetStatus(1.0 - ((endTime - GetGameTimer()) / totalTime))
        elseif totalTime and endTime and (GetGameTimer() >= endTime) then
            actionTimerbar:Drawing(false)
        end
        local interior = GetInteriorFromEntity(PlayerPedId())
        if Config.Drugs.Interiors[interior] then
            local drug = Config.Drugs.Interiors[interior]
            local stages = Config.Drugs.Types[drug].stages
            for stage, stageData in pairs(stages) do
                if #(stageData.position - GetEntityCoords(PlayerPedId())) <= 0.75 then
                    local hasInput = true
                    for _, item in ipairs(stageData.input.items) do
                        if not Spectrum.PlayerData.items[item] or Spectrum.PlayerData.items[item] < stageData.input.count then
                            hasInput = false
                            break
                        end
                    end
                    if not actionLock and hasInput then
                        HelpText("Press ~INPUT_CONTEXT~ to " .. stageData.text)
                        if IsControlJustPressed(0, 51) then
                            actionLock = true
                            TriggerServerEvent("Spectrum:Property:Stage", 1, stage)
                        end
                    elseif not takeLock then
                        if outputs[stage] and outputs[stage][stageData.output.displayItem] and outputs[stage][stageData.output.displayItem] > 0 then
                            HelpText("Press ~INPUT_CONTEXT~ to take ~b~" ..
                                Spectrum.items[stageData.output.displayItem].displayName)
                            if IsControlJustPressed(0, 51) then
                                takeLock = true
                                TriggerServerEvent("Spectrum:Property:StageGrab", 1, stage)
                            end
                        end
                    end
                end
            end
        end
    end
end)
