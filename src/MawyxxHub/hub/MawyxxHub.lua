-- Hub class: Tab → Group → Controls. Public API + lifecycle.

local Defaults = require(script.Parent.Parent.config.Defaults)
local Merge = require(script.Parent.Parent.config.Merge)
local Maid = require(script.Parent.Parent.util.Maid)
local Model = require(script.Parent.Parent.model.Model)
local Validate = require(script.Parent.Parent.model.Validate)
local DefaultDeps = require(script.Parent.Parent.adapters.DefaultDeps)
local WindowBuild = require(script.Parent.Parent.window.Build)
local Drag = require(script.Parent.Parent.window.Drag)
local Shortcuts = require(script.Parent.Parent.window.Shortcuts)
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

local function appendControl(hub, group, el)
	Validate.alive(hub)
	Validate.group(group)
	table.insert(group.elements, el)
	hub:_refreshPages()
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
	self:_renderSidebar()
	return self
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
	self:_renderSidebar()
	if #self.tabs == 1 then
		self:activateTab(tab)
	end
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
	self:_refreshPages()
end

--- Explicit group by text name only (equal width, height from controls).
function MawyxxHub:addGroup(tab, name)
	Validate.alive(self)
	Validate.tab(tab)
	Validate.label(name)
	local group = Model.newGroup(name)
	table.insert(tab.groups, group)
	self:_refreshPages()
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
	self:_refreshPages()
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
