-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_HitHeadInTurns.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_Common03" then
		return _M._to_69_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_68_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_49_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_52_2(flow)
		local _1 = _M._get_52_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_53_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 49 then
		return true
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 60 then
		return true
	end

	if nodeId == 62 then
		return true
	end

	if nodeId == 64 then
		return true
	end

	if nodeId == 65 then
		return true
	end

	if nodeId == 68 then
		return _M._to_71_0(flow)
	end

	if nodeId == 69 then
		return _M._to_70_0(flow)
	end

	if nodeId == 70 then
		return _M._to_73_0(flow)
	end

	if nodeId == 71 then
		return _M._to_72_0(flow)
	end

	if nodeId == 72 then
		return _M._to_75_0(flow)
	end

	if nodeId == 73 then
		return _M._to_74_0(flow)
	end

	if nodeId == 74 then
		return _M._to_77_0(flow)
	end

	if nodeId == 75 then
		return _M._to_76_0(flow)
	end

	if nodeId == 76 then
		return _M._to_87_0(flow)
	end

	if nodeId == 77 then
		return _M._to_86_0(flow)
	end

	if nodeId == 78 then
		return _M._to_84_0(flow)
	end

	if nodeId == 79 then
		return _M._to_82_0(flow)
	end

	if nodeId == 80 then
		return _M._to_81_0(flow)
	end

	if nodeId == 81 then
		return true
	end

	if nodeId == 82 then
		return true
	end

	if nodeId == 83 then
		return _M._to_85_0(flow)
	end

	if nodeId == 84 then
		return _M._to_80_0(flow)
	end

	if nodeId == 85 then
		return _M._to_79_0(flow)
	end

	if nodeId == 86 then
		return _M._to_78_0(flow)
	end

	if nodeId == 87 then
		return _M._to_83_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(49)

	return true
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(53)

	return true
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 68, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 69, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 70, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 71, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 72, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_73_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 73, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 74, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 75, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 76, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 77, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 78, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 79, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 80, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 81, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 82, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 83, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 84, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 85, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 86, 0, "EnvBehav_HitHead", 3, "", 5, "", true, false, false)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 87, 0, "EnvBehav_HeadBeHit", 3, "", 5, "", true, false, false)
end

function _M._get_52_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_52_2(flow)
	return flow:getContextValue("tPointId")
end

return _M
