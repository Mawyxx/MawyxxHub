-- Sidebar: text-only tabs (no icons / emoji).

local CreateMod = require(script.Parent.Parent.visual.Create)

local Create = CreateMod.Create
local TextLabel = CreateMod.TextLabel

local Sidebar = {}

function Sidebar.render(hub)
	local maid = hub._navMaid
	for _, child in ipairs(hub.navContainer:GetChildren()) do
		child:Destroy()
	end
	hub.navButtons = {}

	Create("UIListLayout", {
		Parent = hub.navContainer,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	Create("UIPadding", {
		Parent = hub.navContainer,
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 8),
	})

	for _, tab in ipairs(hub.tabs) do
		local btn = Create("TextButton", {
			Parent = hub.navContainer,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = hub.config.colors.bg,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
		})

		local label = TextLabel(btn, tab.name, 16, hub.config.colors.textSoft, hub.config.font)
		label.Position = UDim2.new(0, 16, 0, 0)
		label.Size = UDim2.new(1, -28, 1, 0)

		maid:Connect(btn.MouseEnter, function()
			if tab ~= hub.activeTab then
				hub:tween(btn, {
					BackgroundTransparency = 0.85,
					BackgroundColor3 = hub.config.colors.surfaceHover,
				})
			end
		end)
		maid:Connect(btn.MouseLeave, function()
			if tab ~= hub.activeTab then
				hub:tween(btn, { BackgroundTransparency = 1 })
			end
		end)
		maid:Connect(btn.MouseButton1Click, function()
			hub:activateTab(tab)
		end)

		hub.navButtons[tab] = { btn = btn, label = label }
	end

	Sidebar.updateHighlight(hub)
end

function Sidebar.updateHighlight(hub)
	for tab, data in pairs(hub.navButtons) do
		local active = tab == hub.activeTab
		hub:tween(data.btn, {
			BackgroundTransparency = active and 0.92 or 1,
			BackgroundColor3 = active and hub.config.colors.purple or hub.config.colors.bg,
		})
		hub:tween(data.label, {
			TextColor3 = active and hub.config.colors.text or hub.config.colors.textSoft,
		})
	end
end

return Sidebar
