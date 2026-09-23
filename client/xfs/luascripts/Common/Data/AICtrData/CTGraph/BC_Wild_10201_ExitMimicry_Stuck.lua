-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_ExitMimicry_Stuck.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_35_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return true
	end

	if nodeId == 35 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "EnvBehav_StuckLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 999)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 9999)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(35)

	return true
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 999)
	flow:setContinue(37)

	return true
end

function _M._get_6_2(flow)
	return flow:getCache(6, "__iterItem")
end

function _M._get_6_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(6, "__iterItem", v)

		if _M._get_16_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_11_1(flow)
	local _1 = _M._get_6_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_0(flow)
	return "LOCOMOTION"
end

function _M._get_16_2(flow)
	local _0 = _M._get_23_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_6_2(flow)
	local _3 = _C(8, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_20_2(flow)
	local _0 = _M._get_21_1(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_6_2(flow)
	local _3 = _C(17, "GetControllingPetActorId", flow, _2)
	local _4 = _C(18, "IsSameSpecies", flow, _3, 0)
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

function _M._get_21_1(flow)
	local _0 = _M._get_6_2(flow)

	return _C(21, "IsControllingPet", flow, _0)
end

function _M._get_23_2(flow)
	local _2 = _M._get_21_1(flow)
	local _0 = not _2

	if _0 then
		return true
	end

	local _1 = _M._get_20_2(flow)

	if _1 then
		return true
	end

	return false
end

return _M
