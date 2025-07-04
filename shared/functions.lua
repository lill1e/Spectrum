function FormatMoney(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

function TableLength(tbl)
    local counter = 0
    for _, _ in pairs(tbl) do
        counter = counter + 1
    end
    return counter
end

function TableIndexOf(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return 0
end

function StripPlate(plate)
    local s = ""
    for c in plate:gmatch(".") do
        if c ~= " " then
            s = s .. c
        end
    end
    return s
end

function PadPlate(plate)
    local n = string.len(plate)
    while n < 8 do
        if 8 - n >= 2 then
            plate = " " .. plate .. " "
            n = n + 2
        else
            plate = plate .. " "
            n = n + 1
        end
    end
    return plate
end

function RandomPlate()
    local plate = ""
    for _ = 1, 8 do
        plate = plate .. Config.Garage.PlateChars[math.random(#Config.Garage.PlateChars)]
    end
    return plate
end

function Whitespace(s)
    for c in s:gmatch(".") do
        if c ~= " " then
            return false
        end
    end
    return true
end

function TableEmpty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

function ConvertTime(seconds)
    seconds = seconds / 1000
    local secs = math.floor(seconds % 60)
    seconds = seconds / 60
    local mins = math.floor(seconds % 60)
    seconds = seconds / 60
    local hours = math.floor(seconds % 24)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

function TableContains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end
