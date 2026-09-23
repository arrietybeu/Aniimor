-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_LeaveFallenLeaves.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tNeedPlayAnim", value0)
	agent:addSubTreeLocalParam("tJumpDistance", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_108_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 96 then
		return true
	end

	if nodeId == 109 then
		return _M._to_111_0(flow)
	end

	if nodeId == 111 then
		return _M._to_112_0(flow)
	end

	if nodeId == 112 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 109 then
		return _M._get_91_1(flow)
	end
end

function _M._to_96_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_0(flow, 96, false, 0)
end

function _M._to_108_0(flow)
	local _0 = _M._get_91_1(flow)

	if _0 then
		flow:setActive()

		local _3 = _C(105, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _3, "Eff_Common_Behav_Doubt", 2)

		return _M._to_96_0(flow)
	end

	local _2 = _M._get_91_1(flow)
	local _1 = not _2

	if _1 then
		return _M._to_109_0(flow)
	end
end

function _M._to_109_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 109)

	if not _1 then
		flow:setActive()
		_C(109, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 15)
		flow:setContinue(109)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_0(flow, 111, true, 3)
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial01")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(112)

	return true
end

function _M._get_89_3(flow)
	local _0 = _C(90, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(89, "__iterItem", v)

		if _M._get_95_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_89_2(flow)
	return flow:getCache(89, "__iterItem")
end

function _M._get_91_1(flow)
	local _0 = _M._get_89_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_95_2(flow)
	local _2 = _M._get_89_2(flow)
	local _0 = _C(84, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _3 = _M._get_89_2(flow)
	local _4 = _C(93, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 2

	if not _1 then
		return false
	end

	return true
end

return _M
