-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_CommonSub_ActivateFollowEntity.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeSubFlow(flow)
	return _M._to_14_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return true
	end

	if nodeId == 10 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_NPC_Novice_Follow") then
		return
	end

	local _0 = _M._get_12_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _0)
	flow:setContinue(9)

	return true
end

function _M._to_10_0(flow)
	if not _B(flow, "PBT_NPC_Novice_Follow") then
		return
	end

	local _0 = _C(16, "GetAuthorityPlayer", flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _0)
	flow:setContinue(10)

	return true
end

function _M._to_14_0(flow)
	local _0 = _M._get_17_1(flow)

	if _0 then
		return _M._to_10_0(flow)
	end

	local _2 = _M._get_17_1(flow)
	local _1 = not _2

	if _1 then
		return _M._to_9_0(flow)
	end
end

function _M._get_12_1(flow)
	local _1 = _M._get_13_2(flow)
	local _0 = _C(11, "GetTableValueByKey", flow, _1, 1)

	return _C(12, "GetActorId", flow, _0)
end

function _M._get_13_2(flow)
	local _0 = flow:getContextValue("stateTable")

	return _C(13, "GetTableValueByKey", flow, _0, "behavParams")
end

function _M._get_17_1(flow)
	local _0 = _M._get_13_2(flow)

	return not _0 or next(_0) == nil
end

return _M
