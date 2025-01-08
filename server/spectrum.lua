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
        }
    },
    jobs = {
        ["dealer"] = {},
        ["lspd"] = {},
        ["fib"] = {},
        ["doa"] = {}
    }
}
