-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_LevelMsg_MimicryOutToPatrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_89_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 59 then
		return _M._to_97_0(flow)
	end

	if nodeId == 89 then
		return _M._to_59_0(flow)
	end

	if nodeId == 97 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_59_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_94_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_96_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(59)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(89)

	return true
end

function _M._to_97_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(97)

	return true
end

function _M._get_91_8(flow)
	local _0 = _C(90, "GetSelfId", flow)

	return _C(91, "GetRouteIdFromEntity", flow, _0, -1, 0, 0, "", "", "", "")
end

function _M._get_94_1(flow)
	local _1 = _M._get_96_1(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_96_1(flow)
	local _0 = flow:getCache(96, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_91_8(flow)

	flow:setCache(96, "1", _0)

	return _0
end

return _M
