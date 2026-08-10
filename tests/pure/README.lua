-- Pure-ish merge smoke (no Roblox APIs except none). Run in Studio command bar or copy asserts.

--[[
	Manual:
	local M = require(path.config.Merge)
	local d = { a = { b = 1 }, c = 2 }
	local x = M.merge(d, { a = { b = 9 } })
	x.a.b = 3
	assert(d.a.b == 1)
]]

return true
