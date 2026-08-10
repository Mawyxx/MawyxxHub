-- Deep-clone then overlay-merge so Defaults is never shared/mutated (PRIME config hygiene).

local function deepClone(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = deepClone(v)
	end
	return copy
end

local function merge(base, overlay)
	local result = deepClone(base)
	if overlay == nil then
		return result
	end
	for k, v in pairs(overlay) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = merge(result[k], v)
		else
			result[k] = deepClone(v)
		end
	end
	return result
end

return {
	deepClone = deepClone,
	merge = merge,
}
