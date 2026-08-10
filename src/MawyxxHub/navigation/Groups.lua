-- Named group card: equal WIDTH (from column), HEIGHT follows controls.

local CreateMod = require(script.Parent.Parent.visual.Create)
local Factory = require(script.Parent.Parent.controls.Factory)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Corner = CreateMod.Corner
local TextLabel = CreateMod.TextLabel

local Groups = {}

function Groups.render(hub, group, parent, layoutOrder, elements)
	elements = elements or group.elements
	local config = hub.config
	local g = config.group or {}
	local headerH = g.headerHeight or 36
	local inset = g.innerPadding or 12

	local frame = Create("Frame", {
		Name = "Group_" .. group.name,
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = config.colors.surface,
		BorderSizePixel = 0,
		ClipsDescendants = false, -- never clip toggles/sliders at the card edge
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = layoutOrder or 0,
	})
	Stroke(frame, config.colors.border, 1)
	Corner(frame, g.corner or 4)

	Create("UIListLayout", {
		Parent = frame,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local headerRow = Create("Frame", {
		Parent = frame,
		Size = UDim2.new(1, 0, 0, headerH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
	})
	local header = TextLabel(headerRow, group.name, 15, config.colors.textSoft, config.font)
	header.Position = UDim2.new(0, inset, 0, 0)
	header.Size = UDim2.new(1, -inset * 2, 1, 0)

	Create("Frame", {
		Parent = frame,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = config.colors.borderSoft,
		BorderSizePixel = 0,
		LayoutOrder = 2,
	})

	local list = Create("Frame", {
		Name = "Body",
		Parent = frame,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
	})
	Create("UIListLayout", {
		Parent = list,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	Create("UIPadding", {
		Parent = list,
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, inset),
		PaddingRight = UDim.new(0, inset),
	})

	for _, element in ipairs(elements) do
		local row = Factory.build(hub, element)
		if row then
			row.Parent = list
		end
	end

	return frame
end

return Groups
