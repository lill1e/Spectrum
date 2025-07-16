FundMenu = RageUI.CreateMenu("Fund", "~g~Manage your company's assets")
local fundLock = false

RegisterKeyMapping("+fund", "Fund Menu", "keyboard", "f6")
RegisterCommand("+fund", function()
    if IsPlayerActive() then
        if Spectrum.Job.current and Config.Jobs[Spectrum.Job.current].ranks and Config.Jobs[Spectrum.Job.current].ranks[Spectrum.PlayerData.jobs[Spectrum.Job.current]].fund and (#(GetEntityCoords(PlayerPedId()) - Config.Jobs[Spectrum.Job.current].locations[Spectrum.Job.location]) <= 0.75) then
            if not RageUI.Visible(FundMenu) then
                Spectrum.libs.Callbacks.callback("getJobFund", function(fund, clean)
                    if fund then
                        Spectrum.Job.fund = fund
                        Spectrum.Job.clean = clean
                        RageUI.Visible(FundMenu, true)
                    else
                        Notification("There was an issue requesting the ~b~fund")
                    end
                end, Spectrum.Job.current)
            else
                Spectrum.Job.fund = nil
                RageUI.Visible(FundMenu, false)
            end
        end
    end
end, false)
RegisterCommand("-fund", function() end, false)

function RageUI.PoolMenus:Fund()
    FundMenu:IsVisible(function(Items)
        if Spectrum.Job.fund then
            Items:AddButton("Fund Amount", nil, { RightLabel = "~g~$" .. FormatMoney(Spectrum.Job.fund) },
                function()

                end)
            Items:AddButton("~g~Deposit Money", nil, { RightLabel = "→→→", IsDisabled = fundLock }, function(onSelected)
                if onSelected then
                    local input = Input("Amount to deposit:")
                    if input and tonumber(input) then
                        fundLock = true
                        local inputNum = tonumber(input)
                        if inputNum > Spectrum.PlayerData.money[Spectrum.Job.clean and "clean" or "dirty"] then
                            inputNum = Spectrum.PlayerData.money[Spectrum.Job.clean and "clean" or "dirty"]
                        end
                        Spectrum.libs.Callbacks.callback("depositFund", function(status)
                            fundLock = false
                            if status then
                                Spectrum.Job.fund = Spectrum.Job.fund + inputNum
                            else
                                Notification("An error occured performing that action")
                            end
                        end, Spectrum.Job.current, inputNum)
                    end
                end
            end)
            Items:AddButton("~g~Withdraw Money", nil, { RightLabel = "→→→", IsDisabled = fundLock }, function(onSelected)
                if onSelected then
                    local input = Input("Amount to withdraw:")
                    if input and tonumber(input) then
                        fundLock = true
                        local inputNum = tonumber(input)
                        if inputNum > Spectrum.Job.fund then
                            inputNum = Spectrum.Job.fund
                        end
                        Spectrum.libs.Callbacks.callback("withdrawFund", function(status)
                            fundLock = false
                            if status then
                                Spectrum.Job.fund = Spectrum.Job.fund - inputNum
                            else
                                Notification("An error occured performing that action")
                            end
                        end, Spectrum.Job.current, inputNum)
                    end
                end
            end)
        end
    end, function()

    end)
end
