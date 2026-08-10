-- Document model helpers: Tab → Group → Control.

local Model = {}

function Model.newTab(name)
	return {
		name = name,
		groups = {},
		-- compat alias used by older call sites / filters
		sections = nil, -- set to same table below
		active = false,
	}
end

function Model.attachGroupsAlias(tab)
	-- sections == groups (same list) for backward-compatible validation paths
	tab.sections = tab.groups
	return tab
end

function Model.newGroup(name)
	return {
		name = name,
		elements = {},
	}
end

return Model
