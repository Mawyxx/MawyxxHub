-- Tab page: equal-width columns with a clear gap (no edge-gluing).

local CreateMod = require(script.Parent.Parent.visual.Create)
local Groups = require(script.Parent.Groups)
local Filter = require(script.Parent.Parent.model.Filter)

local Create = CreateMod.Create

local Pages = {}

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
	local pad = gcfg.padding or 16
	local columns = gcfg.columns or 2
	local gutter = gcfg.gutter or 16

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
		Create("UIListLayout", {
			Parent = row,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, gutter),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		})

		local cols = {}
		local widthOffset = -math.ceil(gutter * (columns - 1) / columns)
		for c = 1, columns do
			local col = Create("Frame", {
				Name = "Column" .. c,
				Parent = row,
				Size = UDim2.new(1 / columns, widthOffset, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = c,
			})
			Create("UIListLayout", {
				Parent = col,
				Padding = UDim.new(0, gap),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			cols[c] = col
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
