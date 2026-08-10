-- Adapter: text width measurement for brand layout.

local TextService = game:GetService("TextService")

local RobloxTextMetrics = {}

function RobloxTextMetrics.Measure(text, font, textSize)
	local bounds = TextService:GetTextSize(text, textSize, font, Vector2.new(10000, textSize + 8))
	return bounds.X
end

return RobloxTextMetrics
