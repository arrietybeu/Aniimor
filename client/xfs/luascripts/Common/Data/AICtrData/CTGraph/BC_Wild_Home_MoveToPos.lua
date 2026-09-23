-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Home_MoveToPos.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPosition", value0)
	agent:addSubTreeLocalParam("tYaw", value1)
	agent:addSubTreeLocalParam("tMaxTime", value2)
	agent:addSubTreeLocalParam("tSpeed", value3)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Msg_Home_MoveToPos" then
		return _M._to_9_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_8_0(flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Env_Home_Item_PetHandling")

	return _M._to_5_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 11 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_Node_Home_MoveToPos") then
		return
	end

	local _0 = _M._get_0_1(flow)
	local _1 = _M._get_0_2(flow)
	local _2 = _M._get_0_3(flow)
	local _3 = _M._get_0_4(flow)

	return _doBehaviourTail_0(flow, 1, _0, _1, _2, _3)
end

function _M._to_5_0(flow)
	local _1 = flow.__finishType == CTRConst.FlowFinishType.Break
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "FinishHomeLandOperation", false)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_9_0(flow)
	local _0 = _M._get_0_5(flow)

	if _0 then
		flow:setActive()

		local _3 = _M._get_8_0(flow)

		_A(flow, "PlayEffectOnTarget", _3, "Eff_Env_Home_Item_PetHandling", -1)

		return _M._to_1_0(flow)
	end

	local _2 = _M._get_0_5(flow)
	local _1 = not _2

	if _1 then
		return _M._to_11_0(flow)
	end
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_Node_Home_MoveToPos") then
		return
	end

	local _0 = _M._get_0_1(flow)
	local _1 = _M._get_0_2(flow)
	local _2 = _M._get_0_3(flow)
	local _3 = _M._get_0_4(flow)

	return _doBehaviourTail_0(flow, 11, _0, _1, _2, _3)
end

function _M._get_0_1(flow)
	return flow:getContextValue("pos")
end

function _M._get_0_2(flow)
	return flow:getContextValue("yawAngle")
end

function _M._get_0_3(flow)
	return flow:getContextValue("moveMaxTime")
end

function _M._get_0_4(flow)
	return flow:getContextValue("moveSpeed")
end

function _M._get_0_5(flow)
	return flow:getContextValue("isTransport")
end

function _M._get_8_0(flow)
	return _C(8, "GetSelfId", flow)
end

return _M
