-- Global keybinds: press/hold → same as clicking the control. Layout-aware badge text.

local CreateMod = require(script.Parent.Parent.visual.Create)
local BindStore = require(script.Parent.Parent.util.BindStore)
local BindMenu = require(script.Parent.BindMenu)

local Create = CreateMod.Create
local Stroke = CreateMod.Stroke
local Corner = CreateMod.Corner

local Binds = {}

local function bindsCfg(hub)
	return hub.config.binds or {}
end

local function bindsEnabled(hub)
	return bindsCfg(hub).enabled ~= false
end

local function displayForKey(hub, keyName)
	local input = hub.deps.input
	local code = BindStore.keyCode(keyName)
	if not code then
		return keyName or ""
	end
	if input.GetStringForKeyCode then
		local s = input.GetStringForKeyCode(code)
		if type(s) == "string" and s ~= "" then
			return s
		end
	end
	return keyName
end

function Binds.refreshBadge(hub, bindId)
	local target = hub._bindTargets and hub._bindTargets[bindId]
	if not target or not target.badge then
		return
	end
	local bind = BindStore.get(hub, bindId)
	local badge = target.badge
	local letter = badge:FindFirstChild("Letter")
	if not bind then
		badge.Visible = false
		return
	end
	badge.Visible = true
	if letter then
		local shown = displayForKey(hub, bind.key)
		if type(shown) == "string" and shown:match("^[%w%p%s]+$") then
			shown = string.upper(shown)
		end
		letter.Text = shown
	end
end

function Binds.refreshAllBadges(hub)
	if not hub._bindTargets then
		return
	end
	for id in pairs(hub._bindTargets) do
		Binds.refreshBadge(hub, id)
	end
end

--- Attach RMB bind UI + optional badge to the left of the switch/button.
-- opts: bindId, kind ("toggle"|"button"), title, row, badgeParent, badgeRightOffset,
--       firePress, fireHoldStart, fireHoldEnd, clickTargets (array of GuiObjects for RMB)
function Binds.attach(hub, opts)
	if not bindsEnabled(hub) then
		return
	end

	hub._bindTargets = hub._bindTargets or {}
	local bindId = opts.bindId
	local badgeRight = opts.badgeRightOffset or -56

	local badge = Create("Frame", {
		Name = "BindBadge",
		Parent = opts.badgeParent or opts.row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, badgeRight, 0.5, 0),
		Size = UDim2.fromOffset(22, 18),
		BackgroundColor3 = hub.config.colors.control,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 6,
	})
	Stroke(badge, hub.config.colors.borderSoft, 1, 0.35)
	Corner(badge, 3)
	local letter = Create("TextLabel", {
		Name = "Letter",
		Parent = badge,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = hub.config.colors.text,
		TextSize = 11,
		Font = hub.config.font,
		ZIndex = 7,
	})

	local function onChanged()
		Binds.refreshAllBadges(hub)
	end

	local function openMenu(anchor)
		BindMenu.open(hub, {
			bindId = bindId,
			title = opts.title or "Bind",
			anchor = anchor or opts.row,
			onChanged = onChanged,
		})
	end

	hub._bindTargets[bindId] = {
		kind = opts.kind or "toggle",
		firePress = opts.firePress,
		fireHoldStart = opts.fireHoldStart,
		fireHoldEnd = opts.fireHoldEnd,
		badge = badge,
		letter = letter,
	}

	local targets = opts.clickTargets or { opts.row }
	for _, gui in ipairs(targets) do
		hub._pageMaid:Connect(gui.InputBegan, function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then
				openMenu(gui)
			end
		end)
	end

	Binds.refreshBadge(hub, bindId)
end

function Binds.setup(hub)
	if not bindsEnabled(hub) then
		return
	end

	hub._bindTargets = hub._bindTargets or {}
	local held = {} -- [bindId] = true while hold-key down
	local input = hub.deps.input

	local function typing()
		local box = hub.searchBox
		if box and box:IsFocused() then
			return true
		end
		return false
	end

	local function windowAllows()
		local cfg = bindsCfg(hub)
		if cfg.whenHidden == false then
			return hub.window and hub.window.Visible
		end
		return true
	end

	local function findTargetByKey(keyCode)
		local name = BindStore.keyName(keyCode)
		if not name then
			return nil, nil
		end
		for id, _ in pairs(hub._bindTargets or {}) do
			local bind = BindStore.get(hub, id)
			if bind and bind.key == name then
				return id, bind
			end
		end
		-- Also allow binds whose target is temporarily off-page (flag still in store)
		for id, bind in pairs(BindStore.all(hub)) do
			if type(bind) == "table" and bind.key == name then
				return id, BindStore.get(hub, id)
			end
		end
		return nil, nil
	end

	local function fireTarget(id, bind, phase)
		local target = hub._bindTargets and hub._bindTargets[id]
		if not target then
			-- Off-page toggle: still flip settings + no UI
			if phase == "press" or phase == "holdStart" then
				local flag = id
				if string.sub(id, 1, 6) == "__btn_" then
					return
				end
				local cur = hub:get(flag)
				if phase == "holdStart" then
					if cur ~= true then
						hub:set(flag, true)
					end
				elseif phase == "press" then
					hub:set(flag, not cur)
				end
			elseif phase == "holdEnd" then
				if string.sub(id, 1, 6) ~= "__btn_" then
					hub:set(id, false)
				end
			end
			return
		end

		if phase == "press" and target.firePress then
			target.firePress()
		elseif phase == "holdStart" and target.fireHoldStart then
			target.fireHoldStart()
		elseif phase == "holdEnd" and target.fireHoldEnd then
			target.fireHoldEnd()
		end
	end

	hub._maid:Connect(input.InputBegan, function(inp, _gameProcessed)
		if hub._destroyed or hub._bindMenuOpen or typing() or not windowAllows() then
			return
		end
		if inp.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local id, bind = findTargetByKey(inp.KeyCode)
		if not id or not bind then
			return
		end
		if bind.mode == "hold" then
			if held[id] then
				return
			end
			held[id] = true
			fireTarget(id, bind, "holdStart")
		else
			fireTarget(id, bind, "press")
		end
	end)

	hub._maid:Connect(input.InputEnded, function(inp)
		if hub._destroyed then
			return
		end
		if inp.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local id, bind = findTargetByKey(inp.KeyCode)
		if not id or not bind or bind.mode ~= "hold" then
			return
		end
		if held[id] then
			held[id] = nil
			fireTarget(id, bind, "holdEnd")
		end
	end)

	-- Refresh badge glyphs when layout changes (GetStringForKeyCode follows OS layout)
	local acc = 0
	if input.RenderStepped then
		hub._maid:Connect(input.RenderStepped, function(dt)
			acc += dt or 0.016
			if acc < 0.35 then
				return
			end
			acc = 0
			Binds.refreshAllBadges(hub)
		end)
	end
end

return Binds
