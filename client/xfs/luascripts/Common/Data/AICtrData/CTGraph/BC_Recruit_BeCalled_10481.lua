-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_BeCalled_10481.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_75_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 67 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_49_0(flow)
	local _0 = _M._get_79_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_69_0(flow)

		_A(flow, "SendMessageToTrigger", _1, 1048102)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_Wild_10481_Skill14830900") then
		return
	end

	local _0 = _M._get_69_0(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(67)

	return true
end

function _M._to_71_0(flow)
	flow:addTimer(3, _M, "_to_49_0", flow)

	return _M._to_67_0(flow)
end

function _M._to_75_0(flow)
	local _2 = _M._get_77_2(flow)
	local _0 = _C(78, "IsInSkill", flow, _2, 14830900)

	if _0 then
		flow:setActive()

		local _1 = _C(76, "GetSelfId", flow)

		_A(flow, "PlayEmojiOnTarget", _1, "Surprise2", 5)

		return _M._to_71_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_69_0(flow)
	return _C(69, "GetSelfId", flow)
end

function _M._get_77_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_79_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_77_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
