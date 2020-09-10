function math.clamp(min, value, max)
    if min > max then min, max = max, min end
    return math.max(min, math.min(max, value))
end

function findIn(table, object)
	local index = -1
    for ind, name2 in pairs(table) do
    	if object == name2 then
    		index = ind
    	end
    end
    return index
end