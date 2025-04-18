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
