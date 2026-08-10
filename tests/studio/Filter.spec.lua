local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Filter = require(ReplicatedStorage.MawyxxHub.model.Filter)
local Validate = require(ReplicatedStorage.MawyxxHub.model.Validate)

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

		it("folds Cyrillic case for labels", function()
			local section = {
				name = "Бой",
				elements = {
					{ label = "Включено", flag = "on", type = "toggle" },
				},
			}
			local vis, els = Filter.groupVisible(section, "включ")
			expect(vis).to.equal(true)
			expect(#els).to.equal(1)
		end)
	end)

	describe("Validate.flagUnique", function()
		it("rejects duplicate flags", function()
			local hub = {
				tabs = {
					{
						groups = {
							{
								elements = {
									{ flag = "aim_on", label = "Enabled" },
								},
							},
						},
					},
				},
			}
			expect(function()
				Validate.flagUnique(hub, "aim_on")
			end).to.throw()
		end)

		it("allows unused flags", function()
			local hub = { tabs = { { groups = { { elements = {} } } } } }
			Validate.flagUnique(hub, "fresh_flag")
		end)
	end)
end
