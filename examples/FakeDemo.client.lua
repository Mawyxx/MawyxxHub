-- Safe executor bootstrap for the optional demo.
local ls = loadstring or load
assert(ls, "[MawyxxHub] no loadstring/load in this executor")

local url = "https://raw.githubusercontent.com/Mawyxx/MawyxxHub/main/dist/demo.lua?v=" .. tostring(tick())
local ok, src = pcall(function()
	return game:HttpGet(url)
end)
assert(ok and type(src) == "string" and #src > 100, "[MawyxxHub] HttpGet failed: " .. tostring(src))

local fn, err = ls(src)
assert(fn, "[MawyxxHub] compile failed: " .. tostring(err))
fn()
