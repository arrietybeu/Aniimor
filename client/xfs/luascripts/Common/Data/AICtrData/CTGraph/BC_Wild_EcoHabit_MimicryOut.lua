-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_MimicryOut.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "MimicryOutByEcsStateChangeTrigger" then
		flow:setActive()

		local _0 = _C(158, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _0, 1016)

		return _M._to_147_0(flow)
	end

	if eventName == "MimicryOutByElementAbilityTrigger" then
		return _M._to_160_0(flow)
	end

	if eventName == "MimicryOutByImpulseTrigger" then
		flow:setActive()

		local _1 = _C(161, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1016)

		return _M._to_148_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 146 then
		return true
	end

	if nodeId == 147 then
		return true
	end

	if nodeId == 148 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_146_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOutAndStun") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(146)

	return true
end

function _M._to_147_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOutAndStun") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(147)

	return true
end

function _M._to_148_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOutAndStun") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(148)

	return true
end

function _M._to_160_0(flow)
	local _0 = _M._get_156_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(159, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1016)

		return _M._to_146_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_156_2(flow)
	local _4 = flow:getContextValue("tSrcAbilityId")
	local _5 = _C(153, "GetSkillType", flow, _4)
	local _6 = _5 == 0
	local _0 = not _6

	if not _0 then
		return false
	end

	local _2 = _C(150, "GetPuppetData", flow, 0, "mimicryType", true, 0)
	local _3 = _2 == 2
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
