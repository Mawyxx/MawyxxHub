-- Adapter: UserInputService (ONLY place that GetService's UIS for input).

local UserInputService = game:GetService("UserInputService")

local RobloxInput = {}

function RobloxInput.GetMouseLocation()
	return UserInputService:GetMouseLocation()
end

RobloxInput.InputBegan = UserInputService.InputBegan
RobloxInput.InputChanged = UserInputService.InputChanged
RobloxInput.InputEnded = UserInputService.InputEnded

return RobloxInput
