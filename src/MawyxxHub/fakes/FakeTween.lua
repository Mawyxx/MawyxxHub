-- Instant property apply (ITween Fake / animations=false path helper).

local function FakeTween(object, properties, _info)
	for k, v in pairs(properties) do
		object[k] = v
	end
	return { Play = function() end, Cancel = function() end }
end

return FakeTween
