-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_LevelMsg_SquibToMimicryThenDestroy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_69_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 65 then
		return _M._to_70_0(flow)
	end

	if nodeId == 67 then
		return _M._to_65_0(flow)
	end

	if nodeId == 69 then
		return _M._to_67_0(flow)
	end

	if nodeId == 70 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 3)
	flow:setContinue(65)

	return true
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "MIMICRY"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(67)

	return true
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(69)

	return true
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(70)

	return true
end

function _M._get_57_1(flow)
	local _1 = _M._get_59_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_59_3(flow)
	local _0 = _C(58, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(59, "__iterItem", v)

		if _M._get_61_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_59_2(flow)
	return flow:getCache(59, "__iterItem")
end

function _M._get_61_2(flow)
	local _1 = _M._get_59_2(flow)
	local _0 = _C(60, "GetDistance", flow, _1, 0, false)

	return _0 <= 8
end

function _M._get_63_1(flow)
	local _0 = _M._get_59_3(flow)

	return _C(63, "SelectOneByRandom", flow, _0)
end

function _M._get_73_1(flow)
	local _0 = _C(72, "HasAITag", flow, 0, "StartShow")

	return not _0
end

return _M
