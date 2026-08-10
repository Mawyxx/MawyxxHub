-- Search / filter: ASCII + Cyrillic, byte-safe (no string.lower on UTF-8).

local Filter = {}

-- Fold without utf8 lib edge-cases: walk UTF-8 bytes for Cyrillic А-Я / Ё and ASCII A-Z.
local function norm(s)
	s = tostring(s or "")
	if s == "" then
		return ""
	end

	local out = table.create(#s)
	local n = 0
	local i = 1
	local len = #s

	while i <= len do
		local b1 = string.byte(s, i)

		-- UTF-8 2-byte Cyrillic (D0/D1 …)
		if (b1 == 0xD0 or b1 == 0xD1) and i < len then
			local b2 = string.byte(s, i + 1)
			-- Ё U+0401 = D0 81 → ё U+0451 = D1 91
			if b1 == 0xD0 and b2 == 0x81 then
				n += 1
				out[n] = "\209\145" -- D1 91
				i += 2
			-- А-П U+0410..041F = D0 90..9F → а-п D0 B0..BF
			elseif b1 == 0xD0 and b2 >= 0x90 and b2 <= 0x9F then
				n += 1
				out[n] = string.char(0xD0, b2 + 0x20)
				i += 2
			-- Р-Я U+0420..042F = D0 A0..AF → р-я D1 80..8F
			elseif b1 == 0xD0 and b2 >= 0xA0 and b2 <= 0xAF then
				n += 1
				out[n] = string.char(0xD1, b2 - 0x20)
				i += 2
			else
				-- already lower Cyrillic or other D0/D1 char — keep
				n += 1
				out[n] = string.char(b1, b2)
				i += 2
			end
		elseif b1 >= 0x41 and b1 <= 0x5A then
			n += 1
			out[n] = string.char(b1 + 0x20)
			i += 1
		else
			n += 1
			out[n] = string.sub(s, i, i)
			i += 1
		end
	end

	return table.concat(out)
end

local function contains(haystack, needle)
	if needle == "" then
		return true
	end
	if string.find(haystack, needle, 1, true) then
		return true
	end
	-- raw fallback (in case fold missed something)
	return false
end

function Filter.matchesQuery(query, ...)
	local qRaw = tostring(query or "")
	if qRaw == "" then
		return true
	end
	local q = norm(qRaw)
	for i = 1, select("#", ...) do
		local text = tostring(select(i, ...) or "")
		if contains(norm(text), q) or contains(text, qRaw) then
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

Filter.sectionVisible = Filter.groupVisible
Filter._norm = norm -- for tests / debug

return Filter
