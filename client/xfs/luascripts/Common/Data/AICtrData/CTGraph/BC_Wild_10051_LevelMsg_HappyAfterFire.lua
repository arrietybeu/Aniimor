-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_LevelMsg_HappyAfterFire.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerHappyAfterFire" then
		return _M._to_10_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 10 then
		return _M._to_12_0(flow)
	end

	if nodeId == 12 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)

	if _0 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_7_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(10)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_HappyLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(12)

	return true
end

function _M._get_3_3(flow)
	local _0 = _C(9, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_5_2(flow)
	local _0 = _M._get_3_2(flow)

	return _C(5, "HasEntityTag", flow, _0, "TE_Env_10051_FireShrub")
end

function _M._get_6_1(flow)
	local _1 = _M._get_3_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_7_2(flow)
	local _0 = _M._get_3_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(7, "__iterItem", v)

		_1 = _M._get_8_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_8_3(flow)
	local _0 = flow:getCache(7, "__iterItem")

	return _C(8, "GetDistance", flow, _0, 0, false)
end

return _M
