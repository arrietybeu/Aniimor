-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_EnterNearPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_140_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 130 then
		return _M._to_137_0(flow)
	end

	if nodeId == 140 then
		return _M._to_130_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_130_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "MIMICRYIDLE")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(130)

	return true
end

function _M._to_137_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "MIMICRY")

	return true
end

function _M._to_140_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_143_2(flow)

	if _0 then
		flow:setActive()
		_C(140, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 1)
		flow:setContinue(140)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_90_1(flow)
	local _0 = _C(87, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_143_2(flow)
	local _4 = _C(145, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _5 = _C(144, "SelectOneByRandom", flow, _4)
	local _6 = _C(146, "GetDistance", flow, _5, 0, false)
	local _0 = _6 <= 4.5

	if _0 then
		return true
	end

	local _2 = _M._get_90_1(flow)
	local _3 = _C(88, "GetPerceptibilityValue", flow, _2)
	local _1 = _3 >= 100

	if _1 then
		return true
	end

	return false
end

return _M
