-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_Test_3.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_63_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 63 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_63_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_55_1(flow)

	if _0 then
		flow:setActive()
		_C(63, "DoBehaviour", flow, "PBT_Node_Com_SwitchToHideMimicryOut")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tNeedPlayAnim", true)
		flow.__agent:addSubTreeLocalParam("tJumpDistance", 0)
		flow:setContinue(63)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_48_2(flow)
	return flow:getCache(48, "__iterItem")
end

function _M._get_48_3(flow)
	local _0 = _C(46, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(48, "__iterItem", v)

		if _M._get_59_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_55_1(flow)
	local _0 = _M._get_48_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_59_2(flow)
	local _2 = _M._get_48_2(flow)
	local _0 = _C(47, "HasEntityTag", flow, _2, "TE_Env_Food")

	if not _0 then
		return false
	end

	local _3 = _C(69, "GetSelfId", flow)
	local _4 = _M._get_48_2(flow)
	local _5 = _C(68, "GetDistance", flow, _3, _4, false)
	local _1 = _5 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_75_0(flow)
	return _C(75, "GetSelfId", flow)
end

return _M
