Sets = {}
Sets.__index = Sets

function Sets.new()
    return setmetatable({ arr = {} }, Sets)
end

function Sets:insert(key)
    self.arr[key] = true
end

function Sets:remove(key)
    self.arr[key] = nil
end

function Sets:contains(key)
    return self.arr[key] and true or false
end

function Sets:toString()
    local str = ""
    for k, _ in pairs(self.arr) do
        str = str .. "," .. k
    end
    return "{ " .. string.sub(str, 2) .. " }"
end

Config.Libs.Sets = Sets
