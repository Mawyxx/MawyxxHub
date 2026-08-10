local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Filter = require(ReplicatedStorage.MawyxxHub.model.Filter)

return function()
	describe("Filter", function()
		it("matches section name", function()
			local section = { name = "Aimbot", elements = { { label = "X", flag = "x", type = "toggle" } } }
			local vis, els = Filter.groupVisible(section, "aim")
			expect(vis).to.equal(true)
			expect(#els).to.equal(1)
		end)

		it("filters elements by label", function()
			local section = {
				name = "Misc",
				elements = {
					{ label = "Speed", flag = "spd", type = "slider" },
					{ label = "Fly", flag = "fly", type = "toggle" },
				},
			}
			local vis, els = Filter.groupVisible(section, "fly")
			expect(vis).to.equal(true)
			expect(#els).to.equal(1)
			expect(els[1].flag).to.equal("fly")
		end)

		it("empty query shows all", function()
			local section = { name = "A", elements = { { label = "B", flag = "b", type = "button" } } }
			local vis, els = Filter.groupVisible(section, "")
			expect(vis).to.equal(true)
			expect(#els).to.equal(1)
		end)
	end)
end
