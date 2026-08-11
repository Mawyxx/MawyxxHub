-- Adapter: UserInputService (ONLY place that GetService's UIS for input).

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local RobloxInput = {}

function RobloxInput.GetMouseLocation()
	return UserInputService:GetMouseLocation()
end

-- Mouse in GuiObject.AbsolutePosition space (GetMouseLocation is screen; AbsolutePosition is inset-shifted).
function RobloxInput.GetMouseLocationGui()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

function RobloxInput.SetMouseIconEnabled(enabled)
	UserInputService.MouseIconEnabled = enabled and true or false
end

function RobloxInput.GetStringForKeyCode(keyCode)
	if keyCode == nil then
		return ""
	end
	local ok, s = pcall(function()
		return UserInputService:GetStringForKeyCode(keyCode)
	end)
	if ok and type(s) == "string" and s ~= "" then
		return s
	end
	local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
	return name
end

RobloxInput.InputBegan = UserInputService.InputBegan
RobloxInput.InputChanged = UserInputService.InputChanged
RobloxInput.InputEnded = UserInputService.InputEnded
RobloxInput.RenderStepped = RunService.RenderStepped

return RobloxInput
