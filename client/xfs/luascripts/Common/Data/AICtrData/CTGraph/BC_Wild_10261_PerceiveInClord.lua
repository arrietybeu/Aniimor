-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_PerceiveInClord.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_8_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 8 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 8 then
		return _M._get_17_2(flow)
	end
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_4_3(flow)
	local _1 = _M.checkInterrupt(flow, 8)

	if _0 and not _1 then
		flow:setActive()
		_C(8, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "AI_SprintLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "AI_SprintLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "AI_SprintLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", -1)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow:setContinue(8)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_0(flow)
	return _C(0, "GetSelfId", flow)
end

function _M._get_1_1(flow)
	local _0 = _M._get_16_1(flow)

	return _C(1, "GetPerceptibilityValue", flow, _0)
end

function _M._get_4_3(flow)
	local _3 = _M._get_1_1(flow)
	local _0 = _3 >= 100

	if not _0 then
		return false
	end

	local _4 = _M._get_0_0(flow)
	local _1 = _C(19, "HasAITag", flow, _4, "TA_InLowGravity")

	if not _1 then
		return false
	end

	local _5 = _M._get_0_0(flow)
	local _2 = _C(20, "IsChildOfCharState", flow, _5, "FLYHOVER")

	if not _2 then
		return false
	end

	return true
end

function _M._get_16_1(flow)
	local _0 = _C(15, "GetPerceptibilityTable", flow)

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

function _M._get_17_2(flow)
	local _0 = _M._get_1_1(flow)

	return _0 < 70
end

return _M
