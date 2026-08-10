-- Tab page: col1 left-aligned, col2 glued to trailing edge + inset (cool gutter).

local CreateMod = require(script.Parent.Parent.visual.Create)
local Groups = require(script.Parent.Groups)
local Filter = require(script.Parent.Parent.model.Filter)

local Create = CreateMod.Create

local Pages = {}

local function makeColumn(parent, name)
	local col = Create("Frame", {
		Name = name,
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	Create("UIListLayout", {
		Parent = col,
		Padding = UDim.new(0, 0), -- set by caller via attribute... use hub gap below
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return col
end

function Pages.render(hub)
	hub._pageMaid:DoCleaning()
	hub._bindings = {}

	for _, child in ipairs(hub.pageContainer:GetChildren()) do
		child:Destroy()
	end
	if hub.overlay then
		for _, child in ipairs(hub.overlay:GetChildren()) do
			child:Destroy()
		end
	end
	hub.pages = {}

	local query = hub.searchQuery or ""
	local gcfg = hub.config.group or {}
	local gap = gcfg.gap or 12
	local pad = gcfg.padding or 12
	local columns = gcfg.columns or 2
	local gutter = gcfg.gutter or (gap + 6)
	local endInset = gcfg.endInset or 4

	for _, tab in ipairs(hub.tabs) do
		local page = Create("Frame", {
			Name = tab.name,
			Parent = hub.pageContainer,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = tab == hub.activeTab,
		})
		hub.pages[tab] = page

		local scroll = Create("ScrollingFrame", {
			Name = "PageScroll",
			Parent = page,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		Create("UIPadding", {
			Parent = scroll,
			PaddingLeft = UDim.new(0, pad),
			PaddingRight = UDim.new(0, pad),
			PaddingTop = UDim.new(0, pad),
			PaddingBottom = UDim.new(0, pad),
		})

		local row = Create("Frame", {
			Name = "Columns",
			Parent = scroll,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})

		local cols = {}

		if columns == 2 then
			-- Left sticks to start; right sticks to end (with endInset). Equal width + cool gutter.
			local halfOffset = math.floor(gutter / 2)

			local left = makeColumn(row, "Column1")
			left.Position = UDim2.new(0, 0, 0, 0)
			left.Size = UDim2.new(0.5, -(halfOffset), 0, 0)
			left:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, gap)
			cols[1] = left

			local right = makeColumn(row, "Column2")
			right.AnchorPoint = Vector2.new(1, 0)
			right.Position = UDim2.new(1, -endInset, 0, 0)
			right.Size = UDim2.new(0.5, -(halfOffset + endInset), 0, 0)
			right:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, gap)
			cols[2] = right
		else
			Create("UIListLayout", {
				Parent = row,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, gutter),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			})
			for c = 1, columns do
				local col = makeColumn(row, "Column" .. c)
				col.Size = UDim2.new(1 / columns, -math.ceil(gutter * (columns - 1) / columns), 0, 0)
				col.LayoutOrder = c
				col:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, gap)
				cols[c] = col
			end
		end

		local groups = tab.groups or tab.sections or {}
		local visibleIndex = 0
		for _, group in ipairs(groups) do
			local visible, elements = Filter.groupVisible(group, query)
			if visible then
				visibleIndex = visibleIndex + 1
				local colIndex = ((visibleIndex - 1) % columns) + 1
				Groups.render(hub, group, cols[colIndex], visibleIndex, elements)
			end
		end
	end
end

return Pages
