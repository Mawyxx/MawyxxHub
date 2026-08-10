-- Custom crosshair cursor (replaces system mouse while hub lives).

local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create

local CROSS = 12
local BAR = 2
local GLOW = 4

local CustomCursor = {}

local function makeBar(parent, size, z, color, transparency)
	return Create("Frame", {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = color,
		BackgroundTransparency = transparency or 0,
		BorderSizePixel = 0,
		ZIndex = z,
	})
end

function CustomCursor.setup(hub)
	local input = hub.deps.input
	local guiHost = hub.deps.guiHost
	local white = (hub.config.colors and hub.config.colors.white) or Color3.new(1, 1, 1)

	if input.SetMouseIconEnabled then
		input.SetMouseIconEnabled(false)
	end

	local gui = Create("ScreenGui", {
		Name = "MawyxxCursor",
		Parent = guiHost.GetPlayerGui(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	hub._maid:Give(gui)
	hub._maid:Give(function()
		if input.SetMouseIconEnabled then
			input.SetMouseIconEnabled(true)
		end
	end)

	local root = Create("Frame", {
		Name = "Cross",
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(CROSS, CROSS),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
	})

	-- Soft glow (slightly thicker, translucent)
	makeBar(root, UDim2.fromOffset(CROSS + 2, GLOW), 10, white, 0.65)
	makeBar(root, UDim2.fromOffset(GLOW, CROSS + 2), 10, white, 0.65)
	-- Sharp cross
	makeBar(root, UDim2.fromOffset(CROSS, BAR), 11, white, 0)
	makeBar(root, UDim2.fromOffset(BAR, CROSS), 11, white, 0)

	local function follow()
		if hub._destroyed then
			return
		end
		local getter = input.GetMouseLocationGui or input.GetMouseLocation
		local m = getter()
		root.Position = UDim2.fromOffset(m.X, m.Y)
	end

	follow()
	if input.RenderStepped then
		hub._maid:Connect(input.RenderStepped, follow)
	end
	hub._maid:Connect(input.InputChanged, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			follow()
		end
	end)

	hub._customCursor = root
end

return CustomCursor
