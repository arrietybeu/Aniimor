-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_ExitMimicrySpecial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_34_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 34 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_30_1(flow)

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = "MIMICRYOUT"

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Mimicry_End02")
		flow:setContinue(34)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_27_2(flow)
	return flow:getCache(27, "__iterItem")
end

function _M._get_27_3(flow)
	local _0 = _C(26, "GetAoiEntityTableByLevel", flow, 0, 10, 14)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(27, "__iterItem", v)

		if _M._get_29_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_29_2(flow)
	local _1 = _M._get_27_2(flow)
	local _0 = _C(28, "GetPuppetData", flow, _1, "petPrototypeId", true, 0)

	return _0 == 1022100
end

function _M._get_30_1(flow)
	local _0 = _M._get_27_3(flow)

	return not _0 or next(_0) == nil
end

return _M
