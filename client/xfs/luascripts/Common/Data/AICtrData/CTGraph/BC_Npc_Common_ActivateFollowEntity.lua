-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Common_ActivateFollowEntity.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "NpcStatusChangeTrigger" then
		return _M._to_8_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 14 then
		return true
	end

	if nodeId == 29 then
		return true
	end

	if nodeId == 39 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_8_0(flow)
	local _2 = _M._get_10_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_28_0(flow)
	end

	local _1 = _M._get_10_1(flow)

	if _1 then
		return _M._to_39_0(flow)
	end
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_NPC_Novice_Follow") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFollowEntActorID", 0)
	flow:setContinue(14)

	return true
end

function _M._to_28_0(flow)
	local _0 = _M._get_34_1(flow)

	if _0 then
		return _M._to_14_0(flow)
	end

	local _2 = _M._get_34_1(flow)
	local _1 = not _2

	if _1 then
		return _M._to_29_0(flow)
	end
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_NPC_Novice_Follow") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFollowEntActorID", 0)
	flow:setContinue(29)

	return true
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(39)

	return true
end

function _M._get_2_2(flow)
	local _0 = _M._get_3_2(flow)

	return _C(2, "GetTableValueByKey", flow, _0, 1)
end

function _M._get_3_2(flow)
	local _0 = _M._get_5_2(flow)

	return _C(3, "GetTableValueByKey", flow, _0, "behavParams")
end

function _M._get_5_2(flow)
	local _0 = _M._get_11_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(5, "__iterItem", v)

		_1 = _M._get_6_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _3 < _1 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_6_2(flow)
	local _0 = flow:getCache(5, "__iterItem")

	return _C(6, "GetTableValueByKey", flow, _0, "priority")
end

function _M._get_10_1(flow)
	local _0 = _M._get_11_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_11_3(flow)
	local _0 = flow:getSubMacro("BCM_Npc_GetRunningStatus")
	local _1 = _C(12, "GetStaticId", flow, 0)

	_0:setContextValue("behavName", "ActivateFollowEntity")
	_0:setContextValue("staticId", _1)
	_0:setContextValue("status", 1)

	local _2 = _0:getMacroValue("resList")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_15_2(flow)
	local _0 = _M._get_18_2(flow)

	return _C(15, "HasEntityTag", flow, _0, "TE_Par_FollowEntity")
end

function _M._get_18_3(flow)
	local _0 = _C(21, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(18, "__iterItem", k)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_18_2(flow)
	return flow:getCache(18, "__iterItem")
end

function _M._get_34_1(flow)
	local _0 = _M._get_3_2(flow)

	return not _0 or next(_0) == nil
end

return _M
