-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Trigger.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_50_0(flow)
end

function _M._to_50_0(flow)
	local _0 = _M._get_52_2(flow)

	if _0 then
		flow:setActive()

		local _2 = _M._get_63_0(flow)
		local _3 = flow:getMessageContext()

		_3.sourceActorId = flow.__actorId

		flow:sendMessage(_2, "VisionValue_AlertDoubt", _3)

		return true
	end

	local _1 = _M._get_62_2(flow)

	if _1 then
		flow:setActive()

		local _4 = _M._get_63_0(flow)
		local _5 = flow:getMessageContext()

		_5.sensorTgtId = 0
		_5.sourceActorId = flow.__actorId

		flow:sendMessage(_4, "VisionValue_AlertState", _5)

		return true
	end
end

function _M._get_15_0(flow)
	return _C(15, "GetPerceptibilityTable", flow)
end

function _M._get_18_1(flow)
	local _0 = _M._get_48_1(flow)

	return _C(18, "GetPerceptibilityValue", flow, _0)
end

function _M._get_21_2(flow)
	local _2 = _M._get_18_1(flow)
	local _0 = _2 > 5

	if not _0 then
		return false
	end

	local _3 = _M._get_18_1(flow)
	local _1 = _3 <= 99

	if not _1 then
		return false
	end

	return true
end

function _M._get_48_1(flow)
	local _0 = _M._get_15_0(flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_51_2(flow)
	local _2 = _M._get_15_0(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_48_1(flow)
	local _1 = _C(17, "IsEntityType", flow, _4, "ACTOR_TYPE_PLAYER")

	if not _1 then
		return false
	end

	return true
end

function _M._get_52_2(flow)
	local _0 = _M._get_51_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_21_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_62_2(flow)
	if false then
		return false
	end

	local _1 = _M._get_18_1(flow)
	local _0 = _1 > 99

	if not _0 then
		return false
	end

	return true
end

function _M._get_63_0(flow)
	return _C(63, "GetSelfId", flow)
end

return _M
