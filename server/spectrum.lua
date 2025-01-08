Spectrum = {
    debug = true,
    players = {},
    items = {
        ["med_kit"] = {
            displayName = "Medical Grade Equipment",
            illegal = false,
            rare = true,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function()
                print("MedKit used")
            end,
            event = {
                name = "Spectrum:SetHealth",
                data = { 100 }
            }
        },
        ["box"] = {
            displayName = "Mystery Box",
            illegal = false,
            rare = false,
            usable = true,
            removeOnUse = false,
            swapOnUse = {
                item = "coin",
                quantity = 5
            },
            handler = false,
        },
        ["coin"] = {
            displayName = "Gold Coin",
            illegal = false,
            usable = false,
            rare = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source,
                    "You flip a coin and notice it landed on: ~y~" .. math.random(0, 1) and "Tails" or "Heads")
            end,
        }
    },
    jobs = {
        ["dealer"] = {},
        ["lspd"] = {},
        ["fib"] = {},
        ["doa"] = {}
    }
}
