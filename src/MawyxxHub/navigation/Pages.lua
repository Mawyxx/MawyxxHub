-- Tab page: N-column group layout (horizontal columns, vertical cards per column).

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
		FillDirection = Enum.FillDirection.Vertical,
	})
end

local function layoutPads(gcfg, fallbackPad)
	local padL = gcfg.paddingLeft or fallbackPad or 14
	local padR = gcfg.paddingRight or 10
	local scrollBar = gcfg.scrollBarGutter or 6
	return math.max(padL, 8), math.max(padR, 0), math.max(scrollBar, 0)
end

local function relayoutRow(scroll, row, cols, columns, gutter, padL, padR, scrollBar)
	local viewW = scroll.AbsoluteSize.X
	if viewW <= 1 then
		return false
	end
	local usable = math.max(viewW - padL - padR - scrollBar, 80)
	local g = math.max(gutter, 8)
	local gaps = g * math.max(columns - 1, 0)
	local colW = math.max(math.floor((usable - gaps) / columns), 40)

	row.Size = UDim2.new(0, usable, 0, 0)
	row.Position = UDim2.new(0, padL, 0, padL)

	for i, col in ipairs(cols) do
		col.Size = UDim2.new(0, colW, 0, 0)
		col.LayoutOrder = i
	end
	return true
end

function Pages.render(hub)
	if hub._suspendLayout then
		return
	end

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
	hub._layoutHooks = {}

	local query = hub.searchQuery or ""
	local gcfg = hub.config.group or {}
	local gap = gcfg.gap or 7
	local pad = gcfg.padding or 14
	local padL, padR, scrollBar = layoutPads(gcfg, pad)
	local columns = math.max(1, math.floor(gcfg.columns or 2))
	local gutter = gcfg.gutter or 12

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
			ClipsDescendants = true,
		})

		local row = Create("Frame", {
			Name = "Columns",
			Parent = scroll,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})

		-- Always horizontal strip of columns (fixes cards stacking under each other)
		Create("UIListLayout", {
			Parent = row,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, gutter),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local cols = {}
		for c = 1, columns do
			local col = Create("Frame", {
				Name = "Column" .. c,
				Parent = row,
				Size = UDim2.new(0, 200, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = c,
			})
			addColumnList(col, gap)
			cols[c] = col
		end

		local function relayout()
			if hub._suspendLayout then
				return
			end
			relayoutRow(scroll, row, cols, columns, gutter, padL, padR, scrollBar)
		end
		hub._pageMaid:Connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), relayout)
		hub._pageMaid:Connect(page:GetPropertyChangedSignal("AbsoluteSize"), relayout)
		if hub.window then
			hub._pageMaid:Connect(hub.window:GetPropertyChangedSignal("AbsoluteSize"), relayout)
		end
		table.insert(hub._layoutHooks, relayout)
		task.defer(relayout)
		task.delay(0.05, relayout)
		task.delay(0.2, relayout)

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
