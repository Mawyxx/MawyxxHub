-- Tab page: equal-width columns; gutter from AbsoluteSize (never collapses).

local CreateMod = require(script.Parent.Parent.visual.Create)
local Groups = require(script.Parent.Groups)
local Filter = require(script.Parent.Parent.model.Filter)

local Create = CreateMod.Create

local Pages = {}

local function addColumnList(col, gap)
	Create("UIListLayout", {
		Parent = col,
		Padding = UDim.new(0, gap),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function layoutTwoColumns(row, left, right, gutter)
	local w = row.AbsoluteSize.X
	if w <= 0 then
		return
	end
	local g = math.max(gutter, 12)
	local colW = math.max(math.floor((w - g) / 2), 1)
	left.Size = UDim2.new(0, colW, 0, 0)
	left.Position = UDim2.new(0, 0, 0, 0)
	right.Size = UDim2.new(0, colW, 0, 0)
	right.Position = UDim2.new(0, colW + g, 0, 0)
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
	local gap = gcfg.gap or 14
	local pad = gcfg.padding or 18
	local columns = math.max(1, gcfg.columns or 2)
	local gutter = gcfg.gutter or 24

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

		if columns == 1 then
			local col = Create("Frame", {
				Name = "Column1",
				Parent = row,
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			addColumnList(col, gap)
			cols[1] = col
		elseif columns == 2 then
			local left = Create("Frame", {
				Name = "Column1",
				Parent = row,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			addColumnList(left, gap)
			cols[1] = left

			local right = Create("Frame", {
				Name = "Column2",
				Parent = row,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			addColumnList(right, gap)
			cols[2] = right

			local function relayout()
				layoutTwoColumns(row, left, right, gutter)
			end
			hub._pageMaid:Connect(row:GetPropertyChangedSignal("AbsoluteSize"), relayout)
			task.defer(relayout)
			task.delay(0, relayout)
		else
			local shrink = math.ceil(gutter * (columns - 1) / columns)
			Create("UIListLayout", {
				Parent = row,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, gutter),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			for c = 1, columns do
				local col = Create("Frame", {
					Name = "Column" .. c,
					Parent = row,
					Size = UDim2.new(1 / columns, -shrink, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = c,
				})
				addColumnList(col, gap)
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
