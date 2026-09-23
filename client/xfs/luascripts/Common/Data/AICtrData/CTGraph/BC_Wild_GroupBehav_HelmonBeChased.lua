-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_HelmonBeChased.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_25_2(flow)
		local _1 = _M._get_25_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_28_0(flow)
	end

	if eventName == "GBPMsg_ResPoint02" then
		return _M._to_77_0(flow)
	end

	if eventName == "GBPMsg_ResPoint03" then
		return _M._to_79_0(flow)
	end

	if eventName == "GBPMsg_ResPoint04" then
		return _M._to_86_0(flow)
	end

	if eventName == "GBPMsg_ResPoint05" then
		return _M._to_89_0(flow)
	end

	if eventName == "GBPMsg_ResPoint06" then
		return _M._to_93_0(flow)
	end

	if eventName == "GBPMsg_ResPoint09" then
		return _M._to_99_0(flow)
	end

	if eventName == "GBPMsg_ResPoint08" then
		return _M._to_103_0(flow)
	end

	if eventName == "GBPMsg_ResPoint07" then
		return _M._to_107_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_115_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 79 then
		return true
	end

	if nodeId == 86 then
		return true
	end

	if nodeId == 89 then
		return true
	end

	if nodeId == 93 then
		return true
	end

	if nodeId == 99 then
		return true
	end

	if nodeId == 103 then
		return true
	end

	if nodeId == 107 then
		return true
	end

	if nodeId == 115 then
		return _M._to_118_0(flow)
	end

	if nodeId == 117 then
		return true
	end

	if nodeId == 118 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(28)

	return true
end

function _M._to_77_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_78_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(77)

		return true
	end
end

function _M._to_79_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_80_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(79)

		return true
	end
end

function _M._to_86_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_85_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(86)

		return true
	end
end

function _M._to_89_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_90_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(89)

		return true
	end
end

function _M._to_93_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_94_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(93)

		return true
	end
end

function _M._to_99_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_100_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(99)

		return true
	end
end

function _M._to_103_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_104_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(103)

		return true
	end
end

function _M._to_107_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_108_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(107)

		return true
	end
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Laugh")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(115)

	return true
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 2.5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(118)

	return true
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_78_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _1 = flow:getContextValue("tPortId")

	return _C(78, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_80_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 2

	return _C(80, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_85_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 2

	return _C(85, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_90_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 6

	return _C(90, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_94_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 5

	return _C(94, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_100_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 2

	return _C(100, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_104_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 4

	return _C(104, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

function _M._get_108_1(flow)
	local _0 = flow:getContextValue("tPointId")
	local _2 = flow:getContextValue("tPortId")
	local _1 = _2 + 1

	return _C(108, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

return _M
