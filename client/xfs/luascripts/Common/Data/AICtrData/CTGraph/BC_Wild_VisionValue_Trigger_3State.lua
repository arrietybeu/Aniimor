-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Trigger_3State.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_50_0(flow)
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "CatchResult_Failure" then
		return _M._to_122_0(flow)
	end
end

function _M._to_50_0(flow)
	local _0 = _M._get_52_2(flow)

	if _0 then
		flow:setActive()

		local _4 = _M._get_63_0(flow)
		local _5 = flow:getMessageContext()
		local _6 = _M._get_48_1(flow)

		_5.sensorTgtId = _6
		_5.sourceActorId = flow.__actorId

		flow:sendMessage(_4, "VisionValue_Alert", _5)

		return true
	end

	local _1 = _M._get_98_2(flow)

	if _1 then
		flow:setActive()

		local _7 = _M._get_63_0(flow)
		local _8 = flow:getMessageContext()
		local _9 = _M._get_48_1(flow)

		_8.sensorTgtId = _9
		_8.sourceActorId = flow.__actorId

		flow:sendMessage(_7, "VisionValue_Full", _8)

		return _M._to_146_0(flow)
	end

	local _2 = _M._get_100_2(flow)

	if _2 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionFull")

		return true
	end

	local _3 = _M._get_174_2(flow)

	if _3 then
		flow:setActive()

		local _10 = _M._get_63_0(flow)
		local _11 = flow:getMessageContext()

		_11.sourceActorId = flow.__actorId

		flow:sendMessage(_10, "VisionValue_None", _11)

		return true
	end
end

function _M._to_122_0(flow)
	local _0 = _M._get_96_2(flow)

	if _0 then
		flow:setActive()

		local _3 = _M._get_145_0(flow)
		local _4 = flow:getMessageContext()
		local _5 = _M._get_141_1(flow)

		_4.sensorTgtId = _5
		_4.sourceActorId = flow.__actorId

		flow:sendMessage(_3, "VisionValue_Full", _4)

		return true
	end

	local _2 = _M._get_96_2(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()

		local _6 = _M._get_145_0(flow)
		local _7 = flow:getMessageContext()
		local _8 = _M._get_141_1(flow)

		_7.sensorTgtId = _8
		_7.sourceActorId = flow.__actorId

		flow:sendMessage(_6, "VisionValue_Alert", _7)

		return true
	end
end

function _M._to_146_0(flow)
	local _0 = _M._get_169_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_170_2(flow)
		local _2 = flow:getMessageContext()

		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_Full_ToBrother", _2)

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
	local _0 = _2 > 10

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

function _M._get_52_2(flow)
	local _2 = _C(91, "HasAITag", flow, 0, "TA_VisionAlert", "TA_VisionFull")
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _M._get_21_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_63_0(flow)
	return _C(63, "GetSelfId", flow)
end

function _M._get_96_2(flow)
	return _C(96, "HasAITag", flow, 0, "TA_VisionAlert")
end

function _M._get_98_2(flow)
	local _2 = _M._get_18_1(flow)
	local _0 = _2 >= 100

	if not _0 then
		return false
	end

	local _3 = _C(142, "HasAITag", flow, 0, "TA_VisionFull")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_100_2(flow)
	local _0 = _M._get_137_1(flow)

	if not _0 then
		return false
	end

	local _1 = _C(136, "HasAITag", flow, 0, "TA_VisionAlert", "TA_VisionFull")

	if not _1 then
		return false
	end

	return true
end

function _M._get_137_1(flow)
	local _0 = _M._get_15_0(flow)

	return not _0 or next(_0) == nil
end

function _M._get_141_1(flow)
	local _0 = _C(140, "GetAoiEntityTableByLevel", flow, 0, 100, 2)

	return _C(141, "SelectOneByRandom", flow, _0)
end

function _M._get_145_0(flow)
	return _C(145, "GetSelfId", flow)
end

function _M._get_151_3(flow)
	local _0 = _C(153, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(151, "__iterItem", v)

		if _M._get_164_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_151_2(flow)
	return flow:getCache(151, "__iterItem")
end

function _M._get_164_3(flow)
	local _3 = _M._get_151_2(flow)
	local _4 = _C(154, "GetDistance", flow, _3, 0, false)
	local _0 = _4 <= 10

	if not _0 then
		return false
	end

	local _5 = _M._get_151_2(flow)
	local _6 = _C(156, "GetPuppetData", flow, _5, "ethnicGroup", true, 0)
	local _7 = _C(158, "GetSelfId", flow)
	local _8 = _C(157, "GetPuppetData", flow, _7, "ethnicGroup", true, 0)
	local _1 = _6 == _8

	if not _1 then
		return false
	end

	local _9 = _M._get_151_2(flow)
	local _10 = _C(160, "GetPuppetData", flow, _9, "stage", true, 0)
	local _2 = _10 > 1

	if not _2 then
		return false
	end

	return true
end

function _M._get_169_2(flow)
	local _2 = _C(147, "GetSelfId", flow)
	local _3 = _C(148, "GetPuppetData", flow, _2, "stage", true, 0)
	local _0 = _3 == 1

	if not _0 then
		return false
	end

	local _4 = _M._get_151_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

function _M._get_170_2(flow)
	local _0 = _M._get_151_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(170, "__iterItem", v)

		_1 = _M._get_171_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_171_3(flow)
	local _0 = flow:getCache(170, "__iterItem")

	return _C(171, "GetDistance", flow, _0, 0, false)
end

function _M._get_174_2(flow)
	local _2 = _C(172, "HasAITag", flow, 0, "TA_VisionAlert", "TA_VisionFull")
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _M._get_137_1(flow)

	if not _1 then
		return false
	end

	return true
end

return _M
