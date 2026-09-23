-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_90213_Combat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tSensorTgtId", value0)
	agent:addSubTreeLocalParam("tRandomWaitTime", value1)
	agent:addSubTreeLocalParam("tShowExclamation", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerExitFengYinRed" then
		return _M._to_48_0(flow)
	end

	if eventName == "LevelMsgTriggerExitFengYinGreen" then
		return _M._to_71_0(flow)
	end

	if eventName == "LevelMsgTriggerExitFengYinBlue" then
		return _M._to_73_0(flow)
	end

	if eventName == "LevelMsgTriggerRed01" then
		return _M._to_74_0(flow)
	end

	if eventName == "LevelMsgTriggerGreen01" then
		return _M._to_77_0(flow)
	end

	if eventName == "LevelMsgTriggerBlue01" then
		return _M._to_78_0(flow)
	end

	if eventName == "LevelMsgTriggerRed02" then
		return _M._to_80_0(flow)
	end

	if eventName == "LevelMsgTriggerGreen02" then
		return _M._to_83_0(flow)
	end

	if eventName == "LevelMsgTriggerBlue02" then
		return _M._to_84_0(flow)
	end

	if eventName == "LevelMsgTriggerExitFengYinGreen02" then
		return _M._to_87_0(flow)
	end

	if eventName == "LevelMsgTriggerExitFengYinBlue02" then
		return _M._to_89_0(flow)
	end

	if eventName == "LevelMsgTriggerExitFengYinRed02" then
		return _M._to_90_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return _M._to_107_0(flow)
	end

	if nodeId == 71 then
		return _M._to_118_0(flow)
	end

	if nodeId == 73 then
		return _M._to_119_0(flow)
	end

	if nodeId == 74 then
		return true
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 78 then
		return true
	end

	if nodeId == 80 then
		return true
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 84 then
		return true
	end

	if nodeId == 87 then
		return true
	end

	if nodeId == 89 then
		return true
	end

	if nodeId == 90 then
		return true
	end

	if nodeId == 107 then
		return true
	end

	if nodeId == 118 then
		return true
	end

	if nodeId == 119 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 48, 0, 902132301, 0, "", 5, false, 0)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 71, 0, 902132302, 0, "", 5, false, 0)
end

function _M._to_73_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 73, 0, 902132303, 0, "", 5, false, 0)
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 74, 0, 902132000, _0, "", 5, false, 0)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 77, 0, 902132200, _0, "", 5, false, 0)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 78, 0, 902132100, _0, "", 5, false, 0)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 80, 0, 902132600, _0, "", 5, false, 0)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 83, 0, 902132700, _0, "", 5, false, 0)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_106_1(flow)

	return _doBehaviourTail_0(flow, 84, 0, 902132500, _0, "", 5, false, 0)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 87, 0, 902132302, 0, "", 5, false, 0)
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 89, 0, 902132303, 0, "", 5, false, 0)
end

function _M._to_90_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 90, 0, 902132301, 0, "", 5, false, 0)
end

function _M._to_107_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()
		_C(107, "DoBehaviour", flow, "PBT_ReadyToFightwithoutQuestionMark")

		local _1 = _M._get_108_2(flow)

		return _doBehaviourTail_1(flow, 107, _1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_118_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()
		_C(118, "DoBehaviour", flow, "PBT_ReadyToFightwithoutQuestionMark")

		local _1 = _M._get_108_2(flow)

		return _doBehaviourTail_1(flow, 118, _1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_119_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()
		_C(119, "DoBehaviour", flow, "PBT_ReadyToFightwithoutQuestionMark")

		local _1 = _M._get_108_2(flow)

		return _doBehaviourTail_1(flow, 119, _1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._get_97_2(flow)
	local _1 = _M._get_105_2(flow)
	local _0 = _C(98, "GetDistance", flow, _1, 100, false)

	return _0 <= 100
end

function _M._get_105_3(flow)
	local _0 = _C(104, "GetAoiEntityTableByLevel", flow, 0, 100, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(105, "__iterItem", v)

		if _M._get_97_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_105_2(flow)
	return flow:getCache(105, "__iterItem")
end

function _M._get_106_1(flow)
	local _0 = _M._get_105_3(flow)

	return _C(106, "SelectOneByRandom", flow, _0)
end

function _M._get_108_2(flow)
	local _0 = _M._get_110_1(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(108, "__iterItem", v)

		_1 = _M._get_109_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_109_3(flow)
	local _0 = flow:getCache(108, "__iterItem")

	return _C(109, "GetDistance", flow, _0, 0, false)
end

function _M._get_110_1(flow)
	return _C(110, "GetAoiEntityTableByLevel", flow, 0, 100, 2)
end

function _M._get_117_2(flow)
	local _4 = _C(114, "GetSelfId", flow)
	local _5 = _C(113, "GetTargetBuffLayerCount", flow, _4, 1145108)
	local _0 = _5 < 1

	if not _0 then
		return false
	end

	local _2 = _M._get_110_1(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
