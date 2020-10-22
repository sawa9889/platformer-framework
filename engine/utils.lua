function math.clamp(min, value, max)
    if min > max then min, max = max, min end
    return math.max(min, math.min(max, value))
end

function getIndex(table, object, column)
    local index = -1
        for ind, name in pairs(table) do
            if column then
                if object[column] == name then
                    index = ind
                end
            else
                if object == name or object == ind then
                    index = ind
                end
            end
        end
    return index
end

function isIn(table, object, column)
    return getIndex(table, object) ~= -1
end