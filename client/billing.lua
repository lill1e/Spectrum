local billingMenu = RageUI.CreateMenu("Billing", "~g~What do you owe?")

RegisterKeyMapping("+billing", "Billing/Invoices Menu", "keyboard", "f7")
RegisterCommand("+billing", function()
    if Spectrum.Loaded then
        RageUI.Visible(billingMenu, not RageUI.Visible(billingMenu))
    end
end, false)
RegisterCommand("-billing", function() end, false)

RegisterNetEvent("Spectrum:Bills:Create", function(id, bill)
    Spectrum.bills[id] = bill
    Notification("There is a new ~y~bill ~s~for you to pay")
end)

function RageUI.PoolMenus:Billing()
    billingMenu:IsVisible(function(Items)
        if Spectrum.Job.current and Config.Jobs[Spectrum.Job.current].billing then
            Items:AddButton("Bill Closest Player", "~y~Work Purposes", { RightLabel = "→→→" }, function(onSelected)
                if onSelected then
                    local target = GetClosestPlayer()
                    if target then
                        local input = Input("Amount to bill to user:")
                        if input and tonumber(input) then
                            Spectrum.libs.Callbacks.callback("createBill", function(status)
                                if status then
                                    Notification("You have sent a ~y~bill ~s~of ~g~$" ..
                                        FormatMoney(tonumber(input)) .. "~s~ to the nearest player")
                                else
                                    Notification(
                                        "There was an issue sending the ~y~bill ~s~to the nearest player, please try again")
                                end
                            end, tonumber(input), target) -- TODO add this
                        end
                    else
                        Notification("You must be in range of another ~b~player ~s~in order to send them a ~y~bill")
                    end
                end
            end)
            Items:AddSeparator("")
        end
        if TableEmpty(Spectrum.bills) then
            Items:AddButton("There are no ~y~bills ~s~to pay!!", "must feel nice", {}, function()

            end)
        end
        for id, bill in pairs(Spectrum.bills) do
            Items:AddButton("Invoiced Bill",
                ((Spectrum.PlayerData.money.bank < bill.cost) and "You do not have enough ~g~money ~s~to pay this bill" or nil),
                { RightLabel = "~g~$" .. FormatMoney(bill.cost) },
                function(onSelected)
                    if onSelected then
                        if Spectrum.PlayerData.money.bank >= bill.cost then
                            Spectrum.libs.Callbacks.callback("payBill", function(status)
                                if status then
                                    Spectrum.bills[id] = nil
                                end
                            end, id)
                        else
                            Notification("You do not have enough ~g~money ~s~to pay this ~y~bill")
                        end
                    end
                end)
        end
    end, function()

    end)
end
