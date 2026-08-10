-- Element / API validation (explicit errors).

local Errors = require(script.Parent.Parent.util.Errors)

local Validate = {}

function Validate.tab(tab)
	Errors.expect(type(tab) == "table", "Validate.Tab", "tab is required")
	local groups = tab.groups or tab.sections
	Errors.expect(type(groups) == "table", "Validate.Tab", "tab.groups missing — pass hub:addTab result")
end

function Validate.group(group)
	Errors.expect(type(group) == "table", "Validate.Group", "group is required")
	Errors.expect(type(group.elements) == "table", "Validate.Group", "group.elements missing — pass hub:addGroup result")
end

-- Compat alias
Validate.section = Validate.group

function Validate.flag(flag)
	Errors.expect(type(flag) == "string" and flag ~= "", "Validate.Flag", "flag must be a non-empty string")
end

function Validate.flagUnique(hub, flag)
	Validate.flag(flag)
	Errors.expect(type(hub) == "table" and type(hub.tabs) == "table", "Validate.FlagUnique", "hub required")
	for _, tab in ipairs(hub.tabs) do
		for _, group in ipairs(tab.groups or tab.sections or {}) do
			for _, el in ipairs(group.elements or {}) do
				Errors.expect(
					el.flag ~= flag and el.colorFlag ~= flag,
					"Validate.FlagUnique",
					("duplicate flag %q — labels may repeat, flags must be unique"):format(flag)
				)
			end
		end
	end
end

function Validate.flagsDistinct(flag, colorFlag)
	Validate.flag(flag)
	Validate.flag(colorFlag)
	Errors.expect(flag ~= colorFlag, "Validate.Flag", "flag and colorFlag must differ")
end

function Validate.label(label)
	Errors.expect(type(label) == "string" and label ~= "", "Validate.Label", "label must be a non-empty string")
end

function Validate.expectTable(value, ruleId, message)
	Errors.expect(type(value) == "table", ruleId, message)
end

function Validate.sliderRange(min, max, step)
	Errors.expect(type(min) == "number" and type(max) == "number", "Validate.Slider", "min/max must be numbers")
	Errors.expect(min <= max, "Validate.Slider", ("min (%s) > max (%s)"):format(tostring(min), tostring(max)))
	Errors.expect(type(step) == "number" and step > 0, "Validate.Slider", "step must be > 0")
end

function Validate.dropdownOptions(options)
	Errors.expect(type(options) == "table", "Validate.Dropdown", "options must be a table")
	Errors.expect(#options > 0, "Validate.Dropdown", "options must be non-empty")
end

function Validate.alive(hub)
	Errors.expect(hub._destroyed ~= true, "Lifecycle.Destroyed", "hub already destroyed")
end

return Validate
