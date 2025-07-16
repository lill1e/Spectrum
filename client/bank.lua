local bankMenu = RageUI.CreateMenu("Bank", "~g~money money money")
local bankLock = false

for _, coord in ipairs(Config.Banks) do
    local blip = AddBlipForCoord(coord)
    SetBlipSprite(blip, 272)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Bank")
    EndTextCommandSetBlipName(blip)
end

function RageUI.PoolMenus:Bank()
    bankMenu:IsVisible(function(Items)
        Items:AddButton("Balance", nil, { RightLabel = "~g~$" .. FormatMoney(Spectrum.PlayerData.money.bank) },
            function() end)
        Items:AddButton("Cash (Clean)", nil, { RightLabel = "~g~$" .. FormatMoney(Spectrum.PlayerData.money.clean) },
            function() end)
        Items:AddSeparator("")
        Items:AddButton("Deposit", nil, { RightLabel = "→→→", IsDisabled = bankLock }, function(onSelected)
            if onSelected then
                local input = Input("Amount to deposit (Max: " .. Spectrum.PlayerData.money.clean .. "):")
                if input and tonumber(input) then
                    local inputNum = tonumber(input)
                    if inputNum > Spectrum.PlayerData.money.clean or inputNum <= 0 then
                        Notification("You can deposit a maximum of ~g~$" .. FormatMoney(Spectrum.PlayerData.money.clean))
                    else
                        bankLock = true
                        Spectrum.libs.Callbacks.callback("depositBank", function(status)
                            bankLock = false
                        end, inputNum)
                    end
                end
            end
        end)
        Items:AddButton("Withdraw", nil, { RightLabel = "→→→", IsDisabled = bankLock }, function(onSelected)
            if onSelected then
                local input = Input("Amount to withdraw (Max: " .. Spectrum.PlayerData.money.bank .. "):")
                if input and tonumber(input) then
                    local inputNum = tonumber(input)
                    if inputNum > Spectrum.PlayerData.money.bank or inputNum <= 0 then
                        Notification("You can withdraw a maximum of ~g~$" .. FormatMoney(Spectrum.PlayerData.money.bank))
                    else
                        bankLock = true
                        Spectrum.libs.Callbacks.callback("withdrawBank", function(status)
                            bankLock = false
                        end, inputNum)
                    end
                end
            end
        end)
    end, function()

    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for _, coord in ipairs(Config.Banks) do
            if #(GetEntityCoords(PlayerPedId()) - coord) <= 3 and IsPlayerActive() then
                if not RageUI.Visible(bankMenu) then
                    HelpText("Press ~INPUT_CONTEXT~ to manage your ~g~money")
                end
                if IsControlJustPressed(0, 51) then
                    RageUI.Visible(bankMenu, not RageUI.Visible(bankMenu))
                end
            end
        end
    end
end)
