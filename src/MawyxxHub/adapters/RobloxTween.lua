-- Adapter: TweenService.

local TweenService = game:GetService("TweenService")

local DEFAULT_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function RobloxTween(object, properties, info)
	local tween = TweenService:Create(object, info or DEFAULT_INFO, properties)
	tween:Play()
	return tween
end

return RobloxTween
