Timerbars = {
    Pool = {},
    Types = {
        Text = 1,
        Progress = 2,
        Checkpoint = 3
    },
    States = {
        Checkpoint = {
            Neutral = 0,
            Success = 1,
            Failure = 2
        }
    }
}
Timerbars.__index = Timerbars

RequestStreamedTextureDict("timerbars", true)

function Timerbars.New(type, leftText, rightData)
    local key = GetGameTimer()
    while Timerbars.Pool[key] do
        Wait(0)
        key = GetGameTimer()
    end
    if type ~= 3 then
        Timerbars.Pool[key] = {
            left = leftText,
            right = rightData,
            drawing = false,
            type = type,
            key = key
        }
    else
        local temp = {}
        for _ = 1, rightData do
            table.insert(temp, 0)
        end
        Timerbars.Pool[key] = {
            left = leftText,
            right = temp,
            drawing = false,
            type = type,
            key = key
        }
    end
    return setmetatable({ key = key }, Timerbars)
end

function Timerbars:Drawing(state)
    Timerbars.Pool[self.key].drawing = state
end

function Timerbars:SetStatus(status, altStatus)
    if Timerbars.Pool[self.key].type ~= 3 then
        Timerbars.Pool[self.key].right = status
    else
        Timerbars.Pool[self.key].right[status] = altStatus
    end
end

function Timerbars:Dispose()
    Timerbars.Pool[self.key] = nil
end

function drawBackground(y, type)
    y = y + ((type == 2 or type == 3) and 0.012 or 0.008)
    DrawSprite("timerbars", "all_black_bg", 0.874, y, 0.165, ((type == 2 or type == 3) and 0.028 or 0.035),
        0.0, 255, 255, 255, 140)
end

function drawText(x, y, text, wrap, scale)
    SetTextFont(0)
    SetTextScale(0.0, scale or 0.288)
    SetTextColour(240, 240, 240, 255)
    SetTextJustification(2)
    SetTextWrap(0.0, wrap or 0.867)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x or 0.795, y)
end

function Timerbars.Draw()
    local anyDrawn = false
    for _, _ in pairs(Timerbars.Pool) do
        anyDrawn = true
        break
    end
    if anyDrawn then
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)

        SetScriptGfxAlign(82, 66)
        SetScriptGfxAlignParams(0.0, 0.0, 0.952, 0.949)

        local y = 0.923
        if BusyspinnerIsOn() or RageUI.CurrentMenu then
            y = 0.887
        end
        for _, timerbar in pairs(Timerbars.Pool) do
            if timerbar.drawing then
                drawBackground(y, timerbar.type)
                drawText(nil, y, timerbar.left)
                if timerbar.type == Timerbars.Types.Text then
                    drawText(nil, y - 0.011, timerbar.right, 0.95, 0.494)
                elseif timerbar.type == Timerbars.Types.Progress then
                    local width = timerbar.right * 0.069
                    DrawRect(0.913, y + 0.012, 0.069, 0.011, 155, 155, 155, 255)
                    DrawRect((0.913 - 0.069 / 2) + width / 2, y + 0.012, width, 0.011, 240, 240, 240, 255)
                elseif timerbar.type == Timerbars.Types.Checkpoint then
                    local x = 0.9445
                    for i = 1, #timerbar.right do
                        local r, g, b, a = table.unpack(timerbar.right[i] == 0 and { 255, 255, 255, 51 } or
                            (timerbar.right[i] == 1 and { 114, 204, 114, 255 } or { 224, 50, 50, 255 }))
                        DrawSprite("timerbars", "circle_checkpoints", x, y + 0.012, 0.012, 0.023, 0.0, r, g, b, a)
                        x = x - 0.0094
                    end
                end
                y = y - ((timerbar.type == 2 or timerbar.type == 3) and 0.0319 or 0.0399)
            end
        end
        ResetScriptGfxAlign()
    end
end

-- DEBUG CODE
Citizen.CreateThread(function()
    while true do
        Wait(0)
        Timerbars.Draw()
    end
end)

RegisterCommand("tbt", function()
    local n = 14
    local textBar = Timerbars.New(Timerbars.Types.Text, "Deliveries Left", "~o~" .. n)
    textBar:Drawing(true)
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            n = n - 1
            textBar:SetStatus("~o~" .. n)
            if n <= 0 then
                textBar:Drawing(false)
                break
            end
        end
    end)
end, false)

RegisterCommand("tbb", function()
    local p = 0.5
    local textBar = Timerbars.New(Timerbars.Types.Progress, "Job Progress", p)
    textBar:Drawing(true)
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            p = p + 0.1
            textBar:SetStatus(p)
            if p >= 1.0 then
                textBar:Drawing(false)
                break
            end
        end
    end)
end, false)

RegisterCommand("tbc", function()
    local i = 1
    local textBar = Timerbars.New(Timerbars.Types.Checkpoint, "Targets Hit", 5)
    textBar:Drawing(true)
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            textBar:SetStatus(i, 1)
            i = i + 1
            if i > 5 then
                textBar:Drawing(false)
                break
            end
        end
    end)
end, false)

RegisterCommand("pizza", function()
    local deliveries = Timerbars.New(Timerbars.Types.Checkpoint, "Deliveries", 5)
    local tips = Timerbars.New(Timerbars.Types.Text, "Tips", "$0")
    local total = Timerbars.New(Timerbars.Types.Text, "Total Earned", "$0")
    deliveries:Drawing(true)
    tips:Drawing(true)
    total:Drawing(true)
end, false)
