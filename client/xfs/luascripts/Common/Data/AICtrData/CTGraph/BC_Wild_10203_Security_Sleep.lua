-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Security_Sleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_8_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 13 then
		return _M._get_7_1(flow)
	end
end

function _M._to_8_0(flow)
	local _2 = _M._get_7_1(flow)
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Awake")

		return _M._to_13_0(flow)
	end

	local _1 = _M._get_7_1(flow)

	if _1 then
		return _M._to_12_0(flow)
	end
end

function _M._to_12_0(flow)
	local _1 = _C(18, "HasAITag", flow, 0, "Awake")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "Awake")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_13_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 13)

	if not _1 then
		flow:setActive()
		_C(13, "DoBehaviour", flow, "PBT_Sleep")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("sleepTimeOut", 9999)
		flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
		flow.__agent:addSubTreeLocalParam("tisLoop", false)
		flow:setContinue(13)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_2_2(flow)
	local _4 = _M._get_4_2(flow)
	local _0 = _C(5, "HasEntityTag", flow, _4, "TE_Env_UniversalMark_D")

	if not _0 then
		return false
	end

	local _3 = _M._get_4_2(flow)
	local _2 = _C(1, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 3

	if not _1 then
		return false
	end

	return true
end

function _M._get_4_2(flow)
	return flow:getCache(4, "__iterItem")
end

function _M._get_4_3(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(4, "__iterItem", v)

		if _M._get_2_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_1(flow)
	local _0 = _M._get_4_3(flow)

	return not _0 or next(_0) == nil
end

return _M
