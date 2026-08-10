-- Hub class: Tab → Group → Controls. Public API + lifecycle.
-- Batch updates, unique flags, remove*, applyTheme (PRIME contract surface).

local Defaults = require(script.Parent.Parent.config.Defaults)
local Merge = require(script.Parent.Parent.config.Merge)
local Maid = require(script.Parent.Parent.util.Maid)
local Model = require(script.Parent.Parent.model.Model)
local Validate = require(script.Parent.Parent.model.Validate)
local DefaultDeps = require(script.Parent.Parent.adapters.DefaultDeps)
local WindowBuild = require(script.Parent.Parent.window.Build)
local Drag = require(script.Parent.Parent.window.Drag)
local Shortcuts = require(script.Parent.Parent.window.Shortcuts)
local CustomCursor = require(script.Parent.Parent.window.CustomCursor)
local Sidebar = require(script.Parent.Parent.navigation.Sidebar)
local Pages = require(script.Parent.Parent.navigation.Pages)

local MawyxxHub = {}
MawyxxHub.__index = MawyxxHub

local function mergeDeps(overrides)
	local base = {
		input = DefaultDeps.input,
		guiHost = DefaultDeps.guiHost,
		tween = DefaultDeps.tween,
		textMetrics = DefaultDeps.textMetrics,
		settings = DefaultDeps.settings,
	}
	if overrides then
		for k, v in pairs(overrides) do
			base[k] = v
		end
	end
	return base
end

local function scheduleRefresh(hub, wantSidebar)
	if (hub._batchDepth or 0) > 0 then
		hub._pendingRefresh = true
		if wantSidebar then
			hub._pendingSidebar = true
		end
		return
	end
	hub:_refreshPages()
	if wantSidebar then
		hub:_renderSidebar()
	end
end

local function appendControl(hub, group, el)
	Validate.alive(hub)
	Validate.group(group)
	if el.flag then
		Validate.flagUnique(hub, el.flag)
	end
	table.insert(group.elements, el)
	scheduleRefresh(hub, false)
	return el
end

function MawyxxHub.new(userConfig, deps)
	local self = setmetatable({}, MawyxxHub)
	self.config = Merge.merge(Defaults, userConfig or {})
	self.deps = mergeDeps(deps)
	self.tabs = {}
	self.activeTab = nil
	self._destroyed = false
	self._bindings = {}
	self._batchDepth = 0
	self._pendingRefresh = false
	self._pendingSidebar = false
	self.searchQuery = ""
	self._maid = Maid.new()
	self._pageMaid = Maid.new()
	self._navMaid = Maid.new()
	self._maid:Give(self._pageMaid)
	self._maid:Give(self._navMaid)

	self.settings = self.deps.settings.Bind(self.config.settingsTable)

	WindowBuild.window(self)
	Drag.setup(self)
	Shortcuts.setup(self)
	CustomCursor.setup(self)
	self:_renderSidebar()
	return self
end

--- Batch structural changes into one refresh (call endUpdate when done).
function MawyxxHub:beginUpdate()
	Validate.alive(self)
	self._batchDepth += 1
end

function MawyxxHub:endUpdate()
	Validate.alive(self)
	self._batchDepth = math.max(0, (self._batchDepth or 0) - 1)
	if self._batchDepth > 0 then
		return
	end
	local needPages = self._pendingRefresh
	local needSidebar = self._pendingSidebar
	self._pendingRefresh = false
	self._pendingSidebar = false
	if needPages then
		self:_refreshPages()
	end
	if needSidebar then
		self:_renderSidebar()
	end
end

function MawyxxHub:tween(object, properties, info)
	if not self.config.animations then
		for k, v in pairs(properties) do
			object[k] = v
		end
		return nil
	end
	return self.deps.tween(object, properties, info)
end

function MawyxxHub:_renderSidebar()
	self._navMaid:DoCleaning()
	Sidebar.render(self)
end

function MawyxxHub:_refreshPages()
	Validate.alive(self)
	Pages.render(self)
	Sidebar.updateHighlight(self)
end

--- Sidebar entry. Text label only (no icons/emoji).
function MawyxxHub:addTab(name)
	Validate.alive(self)
	Validate.label(name)
	local tab = Model.attachGroupsAlias(Model.newTab(name))
	table.insert(self.tabs, tab)
	if #self.tabs == 1 then
		tab.active = true
		self.activeTab = tab
	end
	scheduleRefresh(self, true)
	return tab
end

function MawyxxHub:activateTab(tab)
	Validate.alive(self)
	Validate.tab(tab)
	for _, t in ipairs(self.tabs) do
		t.active = false
	end
	tab.active = true
	self.activeTab = tab

	-- Fast path: flip page visibility without full rebuild
	if self.pages and next(self.pages) ~= nil then
		for t, page in pairs(self.pages) do
			page.Visible = t == tab
		end
		Sidebar.updateHighlight(self)
		return
	end
	scheduleRefresh(self, false)
end

--- Explicit group by text name only (equal width, height from controls).
function MawyxxHub:addGroup(tab, name)
	Validate.alive(self)
	Validate.tab(tab)
	Validate.label(name)
	local group = Model.newGroup(name)
	table.insert(tab.groups, group)
	scheduleRefresh(self, false)
	return group
end

-- Compat: old name
function MawyxxHub:addSection(tab, name)
	return self:addGroup(tab, name)
end

function MawyxxHub:addToggle(group, label, flag, default, callback)
	Validate.label(label)
	Validate.flag(flag)
	local el = {
		type = "toggle",
		label = label,
		flag = flag,
		default = default,
		callback = callback,
	}
	if el.default == nil then
		el.default = false
	end
	return appendControl(self, group, el)
end

function MawyxxHub:addSlider(group, label, flag, min, max, step, default, callback)
	Validate.label(label)
	Validate.flag(flag)
	min = min or 0
	max = max or 100
	step = step or 1
	Validate.sliderRange(min, max, step)
	return appendControl(self, group, {
		type = "slider",
		label = label,
		flag = flag,
		min = min,
		max = max,
		step = step,
		default = default or min,
		callback = callback,
	})
end

function MawyxxHub:addDropdown(group, label, flag, options, default, callback)
	Validate.label(label)
	Validate.flag(flag)
	Validate.dropdownOptions(options)
	return appendControl(self, group, {
		type = "dropdown",
		label = label,
		flag = flag,
		options = options,
		default = default or options[1],
		callback = callback,
	})
end

function MawyxxHub:addButton(group, label, callback)
	Validate.label(label)
	return appendControl(self, group, {
		type = "button",
		label = label,
		callback = callback,
	})
end

function MawyxxHub:addColorPicker(group, label, flag, default, callback)
	Validate.label(label)
	Validate.flag(flag)
	return appendControl(self, group, {
		type = "colorpicker",
		label = label,
		flag = flag,
		default = default or Color3.new(1, 1, 1),
		callback = callback,
	})
end

--- Toggle + color swatch on one row. Two flags: bool + Color3.
function MawyxxHub:addToggleColor(group, label, flag, colorFlag, defaultOn, defaultColor, callback, colorCallback)
	Validate.label(label)
	Validate.flagsDistinct(flag, colorFlag)
	Validate.flagUnique(self, colorFlag)
	return appendControl(self, group, {
		type = "togglecolor",
		label = label,
		flag = flag,
		colorFlag = colorFlag,
		default = defaultOn == nil and false or defaultOn,
		colorDefault = defaultColor or Color3.new(1, 1, 1),
		callback = callback,
		colorCallback = colorCallback,
	})
end

function MawyxxHub:get(flag)
	Validate.alive(self)
	Validate.flag(flag)
	return self.deps.settings.Get(self.settings, flag)
end

function MawyxxHub:set(flag, value)
	Validate.alive(self)
	Validate.flag(flag)
	self.deps.settings.Set(self.settings, flag, value)
	local binding = self._bindings[flag]
	if binding and binding.apply then
		binding.apply(value)
		return
	end
	scheduleRefresh(self, false)
end

--- Remove a stateful control by flag (or colorFlag). Returns true if removed.
function MawyxxHub:removeControl(flag)
	Validate.alive(self)
	Validate.flag(flag)
	for _, tab in ipairs(self.tabs) do
		for _, group in ipairs(tab.groups or {}) do
			for i, el in ipairs(group.elements) do
				if el.flag == flag or el.colorFlag == flag then
					table.remove(group.elements, i)
					if el.flag then
						self._bindings[el.flag] = nil
					end
					if el.colorFlag then
						self._bindings[el.colorFlag] = nil
					end
					scheduleRefresh(self, false)
					return true
				end
			end
		end
	end
	return false
end

--- Remove a group from its tab.
function MawyxxHub:removeGroup(tab, group)
	Validate.alive(self)
	Validate.tab(tab)
	Validate.group(group)
	local groups = tab.groups or {}
	for i, g in ipairs(groups) do
		if g == group then
			table.remove(groups, i)
			scheduleRefresh(self, false)
			return true
		end
	end
	return false
end

--- Remove a tab (and its groups). Activates first remaining tab if needed.
function MawyxxHub:removeTab(tab)
	Validate.alive(self)
	Validate.tab(tab)
	for i, t in ipairs(self.tabs) do
		if t == tab then
			table.remove(self.tabs, i)
			if self.activeTab == tab then
				self.activeTab = self.tabs[1]
				if self.activeTab then
					self.activeTab.active = true
				end
			end
			scheduleRefresh(self, true)
			return true
		end
	end
	return false
end

--- Merge color overrides and rebuild visible chrome.
function MawyxxHub:applyTheme(partialColors)
	Validate.alive(self)
	Validate.expectTable(partialColors, "Theme.Colors", "partialColors must be a table")
	for k, v in pairs(partialColors) do
		self.config.colors[k] = v
	end
	if self.window and partialColors.bg then
		self.window.BackgroundColor3 = partialColors.bg
	end
	if self.sidebar and partialColors.bg then
		self.sidebar.BackgroundColor3 = partialColors.bg
	end
	if self.topbar and partialColors.bg then
		self.topbar.BackgroundColor3 = partialColors.bg
	end
	if self.content and partialColors.bg then
		self.content.BackgroundColor3 = partialColors.bg
	end
	scheduleRefresh(self, true)
end

function MawyxxHub:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._bindings = {}
	self._maid:Destroy()
	self.screenGui = nil
	self.window = nil
end

MawyxxHub.destroy = MawyxxHub.Destroy

return MawyxxHub
