-- TestEZ: deep merge does not share nested tables with Defaults.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Merge = require(ReplicatedStorage.MawyxxHub.config.Merge)
local Defaults = require(ReplicatedStorage.MawyxxHub.config.Defaults)

return function()
	describe("Merge", function()
		it("deep-clones nested tables (AC4)", function()
			local cfg = Merge.merge(Defaults, { window = { width = 100 } })
			cfg.colors.purple = Color3.new(1, 0, 0)
			expect(Defaults.colors.purple).never.to.equal(cfg.colors.purple)
			expect(Defaults.window.width).to.equal(920)
			expect(cfg.window.width).to.equal(100)
			expect(cfg.window.height).to.equal(600)
			expect(cfg.toggleKey).to.equal(Enum.KeyCode.RightControl)
		end)
	end)
end
