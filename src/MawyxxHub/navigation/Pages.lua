-- Tab page: column widths from scroll viewport (UIPadding does not shrink AbsoluteSize).

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

local function layoutPads(gcfg, fallbackPad)
	local padL = gcfg.paddingLeft or fallbackPad or 14
	local padR = gcfg.paddingRight or 10
	local scrollBar = gcfg.scrollBarGutter or 6
	return math.max(padL, 8), math.max(padR, 0), math.max(scrollBar, 0)
end

--- Layout against the visible scroll width, not row.AbsoluteSize (padding-safe).
local function layoutTwoColumns(scroll, row, left, right, gutter, padL, padR, scrollBar)
	local viewW = scroll.AbsoluteSize.X
	if viewW <= 1 then
		return false
	end
	local g = math.max(gutter, 8)
	local usable = math.max(viewW - padL - padR - scrollBar, 80)
	local colW = math.max(math.floor((usable - g) / 2), 40)

	row.Size = UDim2.new(0, usable, 0, 0)
	row.Position = UDim2.new(0, padL, 0, padL)

	left.Size = UDim2.new(0, colW, 0, 0)
	left.Position = UDim2.new(0, 0, 0, 0)
	right.Size = UDim2.new(0, colW, 0, 0)
	right.Position = UDim2.new(0, colW + g, 0, 0)
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
	local columns = math.max(1, gcfg.columns or 2)
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

			local function relayout1()
				if hub._suspendLayout then
					return
				end
				local viewW = scroll.AbsoluteSize.X
				if viewW <= 0 then
					return
				end
				local usable = math.max(viewW - padL - padR - scrollBar, 80)
				row.Size = UDim2.new(0, usable, 0, 0)
				row.Position = UDim2.new(0, padL, 0, padL)
				col.Size = UDim2.new(1, 0, 0, 0)
			end
			hub._pageMaid:Connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), relayout1)
			task.defer(relayout1)
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
				if hub._suspendLayout then
					return
				end
				layoutTwoColumns(scroll, row, left, right, gutter, padL, padR, scrollBar)
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
		else
			Create("UIPadding", {
				Parent = scroll,
				PaddingLeft = UDim.new(0, padL),
				PaddingRight = UDim.new(0, padR),
				PaddingTop = UDim.new(0, padL),
				PaddingBottom = UDim.new(0, padL),
			})
			local shrink = math.ceil(gutter * (columns - 1) / columns)
			row.Size = UDim2.new(1, 0, 0, 0)
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
