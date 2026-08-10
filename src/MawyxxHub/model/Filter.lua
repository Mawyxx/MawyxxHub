-- Search / filter helpers: Tab → Group → Control.

local Filter = {}

local function norm(s)
	return string.lower(tostring(s or ""))
end

function Filter.matchesQuery(query, ...)
	local q = norm(query)
	if q == "" then
		return true
	end
	for i = 1, select("#", ...) do
		if string.find(norm(select(i, ...)), q, 1, true) then
			return true
		end
	end
	return false
end

function Filter.groupVisible(group, query)
	if Filter.matchesQuery(query, group.name) then
		return true, group.elements
	end
	local filtered = {}
	for _, el in ipairs(group.elements) do
		if Filter.matchesQuery(query, el.label, el.flag, el.type) then
			table.insert(filtered, el)
		end
	end
	return #filtered > 0, filtered
end

-- Compat
Filter.sectionVisible = Filter.groupVisible

return Filter
