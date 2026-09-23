-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10601_yuni.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_10_0(flow)
end

function _M.executeEndTrigger(flow)
	return _M._to_28_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 10 then
		return _M._to_11_0(flow)
	end

	if nodeId == 11 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 10 then
		return _M._get_13_1(flow)
	end

	if nodeId == 11 then
		return _M._get_13_1(flow)
	end

	if nodeId == 20 then
		return _M._get_13_1(flow)
	end
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)
	local _1 = _M.checkInterrupt(flow, 10)

	if _0 and not _1 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _2 = _M._get_8_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 0)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(10)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 11)

	if not _1 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_HappyLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_20_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 20)

	if not _1 then
		flow:setActive()
		_C(20, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(20)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_28_0(flow)
	local _0 = _M._get_30_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(29, "GetSelfId", flow)

		_A(flow, "PlayEmojiOnTarget", _1, "Angry", 5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(4, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_1_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_1_2(flow)
	local _0 = _M._get_0_2(flow)

	return _C(1, "HasEntityTag", flow, _0, "TE_Env_Mud")
end

function _M._get_3_3(flow)
	local _0 = flow:getCache(7, "__iterItem")

	return _C(3, "GetDistance", flow, _0, 0, false)
end

function _M._get_6_1(flow)
	local _1 = _M._get_0_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_7_2(flow)
	local _0 = _M._get_0_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(7, "__iterItem", v)

		_1 = _M._get_3_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_8_1(flow)
	local _0 = flow:getCache(8, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_7_2(flow)

	flow:setCache(8, "1", _0)

	return _0
end

function _M._get_13_1(flow)
	local _0 = _M._get_15_2(flow)

	return not _0
end

function _M._get_15_2(flow)
	local _3 = _M._get_8_1(flow)
	local _0 = _C(14, "CheckEntityExist", flow, _3)

	if not _0 then
		return false
	end

	local _2 = _M._get_8_1(flow)
	local _1 = _C(12, "HasEntityTag", flow, _2, "TE_Env_Mud")

	if not _1 then
		return false
	end

	return true
end

function _M._get_30_2(flow)
	local _0 = flow.__finishType == CTRConst.FlowFinishType.Break

	if _0 then
		return true
	end

	local _1 = flow.__finishType == CTRConst.FlowFinishType.Interrupt

	if _1 then
		return true
	end

	return false
end

return _M
