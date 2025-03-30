Spectrum = {
    debug = true,
    loaded = false,
    players = {},
    tokens = {},
    libs = {
        callbacks = {},
        callbackFunctions = {},
        callbackCounts = {},
        tokens = {}
    },
    items = {
        ["med_kit"] = {
            displayName = "Medical Grade Equipment",
            illegal = false,
            rare = true,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:SetHealth", source,
                    (GetEntityModel(GetPlayerPed(source)) == GetHashKey("mp_f_freemode_01")) and 175 or 200,
                    Spectrum.libs.Tokens.CreateToken(source))
            end
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
            usable = true,
            rare = false,
            removeOnUse = false,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source,
                    "You flip a coin and notice it landed on: ~y~" .. (math.random(0, 1) == 1 and "Tails" or "Heads"))
            end,
        },
        ["blueprint"] = {
            displayName = "(Blue)print",
            illegal = true,
            rare = true,
            usable = true,
            removeOnUse = true,
            swapOnUse = false,
            handler = function(source)
                TriggerClientEvent("Spectrum:Notification", source, "~r~there goes your blueprint")
            end
        }
    },
    weapons = {},
    weaponsData = {},
    jobs = {
        ["dealer"] = {},
        ["lspd"] = {},
        ["fib"] = {},
        ["doa"] = {}
    }
}
