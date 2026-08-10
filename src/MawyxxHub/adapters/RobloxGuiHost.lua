-- Adapter: PlayerGui host.

local Players = game:GetService("Players")

local RobloxGuiHost = {}

function RobloxGuiHost.GetPlayerGui()
	local player = Players.LocalPlayer
	if not player then
		error("[MawyxxHub.GuiHost] LocalPlayer missing — client-only framework", 2)
	end
	return player:WaitForChild("PlayerGui")
end

function RobloxGuiHost.DestroyNamed(name)
	local gui = RobloxGuiHost.GetPlayerGui()
	local old = gui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

return RobloxGuiHost
