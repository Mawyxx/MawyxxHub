local Errors = require(script.Parent.Parent.util.Errors)
local Toggle = require(script.Parent.Toggle)
local Slider = require(script.Parent.Slider)
local Dropdown = require(script.Parent.Dropdown)
local Button = require(script.Parent.Button)
local ColorPicker = require(script.Parent.ColorPicker)

local builders = {
	toggle = Toggle.build,
	slider = Slider.build,
	dropdown = Dropdown.build,
	button = Button.build,
	colorpicker = ColorPicker.build,
}

local Factory = {}

function Factory.build(hub, element)
	local builder = builders[element.type]
	if not builder then
		Errors.fail("Factory.UnknownType", "unknown control type: " .. tostring(element.type))
	end
	return builder(hub, element)
end

return Factory
