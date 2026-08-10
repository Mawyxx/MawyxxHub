-- Instance construction helpers (no GetService).

local function Create(className, properties)
	local obj = Instance.new(className)
	for prop, val in pairs(properties or {}) do
		obj[prop] = val
	end
	return obj
end

local function Corner(parent, radius)
	return Create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 0),
	})
end

local function Stroke(parent, color, thickness, transparency)
	return Create("UIStroke", {
		Parent = parent,
		Color = color or Color3.fromRGB(31, 31, 33),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	})
end

local function Padding(parent, left, right, top, bottom)
	return Create("UIPadding", {
		Parent = parent,
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	})
end

local function TextLabel(parent, text, size, color, font)
	return Create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color or Color3.fromRGB(224, 224, 226),
		TextSize = size or 14,
		Font = font or Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BorderSizePixel = 0,
	})
end

return {
	Create = Create,
	Corner = Corner,
	Stroke = Stroke,
	Padding = Padding,
	TextLabel = TextLabel,
}
