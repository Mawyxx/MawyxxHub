-- Search / filter helpers: Tab → Group → Control.
-- ASCII + Cyrillic case-fold (string.lower is ASCII-only).

local Filter = {}

local function foldChar(code)
	-- A-Z
	if code >= 0x41 and code <= 0x5A then
		return code + 0x20
	end
	-- А-Я (Cyrillic)
	if code >= 0x410 and code <= 0x42F then
		return code + 0x20
	end
	-- Ё
	if code == 0x401 then
		return 0x451
	end
	return code
end

local function norm(s)
	s = tostring(s or "")
	if s == "" then
		return ""
	end
	local parts = table.create(#s)
	local n = 0
	for _, code in utf8.codes(s) do
		n += 1
		parts[n] = utf8.char(foldChar(code))
	end
	return table.concat(parts)
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
