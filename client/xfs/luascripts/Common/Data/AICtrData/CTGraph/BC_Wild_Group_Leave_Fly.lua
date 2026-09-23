-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Group_Leave_Fly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Flyaway" then
		return _M._to_103_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 72 then
		return _M._to_95_0(flow)
	end

	if nodeId == 95 then
		return _M._to_96_0(flow)
	end

	if nodeId == 96 then
		return true
	end

	if nodeId == 103 then
		return _M._to_94_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(72)

	return true
end

function _M._to_94_0(flow)
	flow:setActive()

	local _0 = _M._get_82_2(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Flyaway", _1)
	end

	return _M._to_72_0(flow)
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_102_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 150)
	flow.__agent:addSubTreeLocalParam("tSpeed", 7)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 6)
	flow:setContinue(95)

	return true
end

function _M._to_96_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(96)

	return true
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0.01)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(103)

	return true
end

function _M._get_82_2(flow)
	local _0 = _C(81, "GetAoiEntityTableByLevel", flow, 0, 30, 8)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(82, "__iterItem", v)

		if _M._get_106_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_82_3(flow)
	return flow:getCache(82, "__iterItem")
end

function _M._get_102_1(flow)
	local _0 = _C(97, "GetAoiEntityTableByLevel", flow, 0, 100, 2)

	return _C(102, "SelectOneByRandom", flow, _0)
end

function _M._get_106_2(flow)
	local _2 = _M._get_82_3(flow)
	local _3 = _C(84, "GetDistance", flow, _2, 0, false)
	local _0 = _3 <= 12

	if not _0 then
		return false
	end

	local _4 = _M._get_82_3(flow)
	local _5 = _C(104, "IsInBehavTag", flow, _4, "TB_Leave_Fly")
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

return _M
