-- Adapter: UserInputService (ONLY place that GetService's UIS for input).

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local RobloxInput = {}

function RobloxInput.GetMouseLocation()
	return UserInputService:GetMouseLocation()
end

-- Mouse in GuiObject.AbsolutePosition space (GetMouseLocation is screen; AbsolutePosition is inset-shifted).
function RobloxInput.GetMouseLocationGui()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

RobloxInput.InputBegan = UserInputService.InputBegan
RobloxInput.InputChanged = UserInputService.InputChanged
RobloxInput.InputEnded = UserInputService.InputEnded

return RobloxInput
