local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Validate = require(ReplicatedStorage.MawyxxHub.model.Validate)
local Maid = require(ReplicatedStorage.MawyxxHub.util.Maid)

return function()
	describe("Validate", function()
		it("rejects min > max", function()
			expect(function()
				Validate.sliderRange(10, 1, 1)
			end).to.throw()
		end)

		it("rejects empty dropdown options", function()
			expect(function()
				Validate.dropdownOptions({})
			end).to.throw()
		end)

		it("rejects destroyed hub", function()
			expect(function()
				Validate.alive({ _destroyed = true })
			end).to.throw()
		end)
	end)

	describe("Maid", function()
		it("disconnects connections on DoCleaning (regression leak)", function()
			local maid = Maid.new()
			local calls = 0
			local alive = true
			local conn = {
				Disconnect = function()
					alive = false
					calls = calls + 1
				end,
			}
			-- typeof RBXScriptConnection won't match; use function cleanup
			maid:Give(function()
				conn:Disconnect()
			end)
			maid:DoCleaning()
			expect(alive).to.equal(false)
			expect(calls).to.equal(1)
		end)
	end)
end
