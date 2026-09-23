-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10421_PER_Happy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {
	"Event_PER_Happy"
}

function _M.getEventTriggerList()
	return _eventTriggerList
end

local _messageTriggerList = {}

function _M.getMessageTriggerList()
	return _messageTriggerList
end

local _tickLodTriggerLevel = -1

function _M.getTickLodTriggerLevel()
	return _tickLodTriggerLevel
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Happy" then
		return _M._to_63_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 45 then
		return true
	end

	if nodeId == 54 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 45 then
		return _M._get_68_2(flow)
	end
end

function _M._to_45_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 45)

	if not _1 then
		flow:setActive()
		_C(45, "DoBehaviour", flow, "PBT_Behav_Com_Happy")

		local _1 = _M._get_44_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(45)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_54_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(54, "DoBehaviour", flow, "PBT_Behav_Com_Happy")

	local _0 = _M._get_44_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(54)

	return true
end

function _M._to_55_0(flow)
	local _0 = _M._get_57_1(flow)

	if _0 then
		return _M._to_64_0(flow)
	end

	return _M._to_54_0(flow)
end

function _M._to_59_0(flow)
	local _0 = _M._get_70_1(flow)

	if _0 then
		flow:setActive()
		_C(59, "DoAction", flow, "SendMessageToTrigger", 0, 1042101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_63_0(flow)
	flow:setActive()

	local _0 = _M._get_44_2(flow)

	_C(63, "DoAction", flow, "PlayEmojiOnTarget", _0, "Happy", 2)

	return _M._to_55_0(flow)
end

function _M._to_64_0(flow)
	flow:addTimer(1, _M, "_to_59_0", flow)

	return _M._to_45_0(flow)
end

function _M._get_44_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_57_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_57_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_66_3(flow)
	local _0 = _M._get_44_2(flow)

	return _C(66, "GetDistance", flow, _0, 0, false)
end

function _M._get_67_2(flow)
	local _0 = _M._get_66_3(flow)

	return _C(67, "IsGreaterThan", flow, _0, 10)
end

function _M._get_68_2(flow)
	local _0 = _M._get_67_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_57_3(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_69_1(flow)
	local _0 = _M._get_71_1(flow)

	return _C(69, "IsControllingPet", flow, _0)
end

function _M._get_70_1(flow)
	local _0 = _M._get_69_1(flow)

	return _C(70, "Not", flow, _0)
end

function _M._get_71_1(flow)
	local _0 = _M._get_44_2(flow)

	return _C(71, "GetPetMaster", flow, _0)
end

return _M
