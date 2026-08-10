-- Explicit framework errors (PRIME-A10). rule_id in message for observability.

local Errors = {}

function Errors.fail(ruleId, message)
	error(("[MawyxxHub.%s] %s"):format(ruleId, message), 2)
end

function Errors.expect(condition, ruleId, message)
	if not condition then
		Errors.fail(ruleId, message)
	end
end

return Errors
