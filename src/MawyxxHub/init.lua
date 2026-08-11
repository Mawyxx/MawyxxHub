--[[
	MawyxxHub — Roblox GUI framework (composition root).

		local MawyxxHub = require(ReplicatedStorage.MawyxxHub)
		local hub = MawyxxHub.new(config?, deps?)
]]

local Hub = require(script.hub.MawyxxHub)
local Version = require(script.config.Version)

Hub.VERSION = Version.id or "dev"

return Hub
