-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_Fire.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeTickLodTrigger(flow)
	return _M._to_42_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 42 then
		return _M._to_100_0(flow)
	end

	if nodeId == 52 then
		return true
	end

	if nodeId == 54 then
		return _M._to_95_0(flow)
	end

	if nodeId == 56 then
		return _M._to_104_0(flow)
	end

	if nodeId == 95 then
		return true
	end

	if nodeId == 100 then
		return _M._to_106_0(flow)
	end

	if nodeId == 104 then
		return _M._to_105_0(flow)
	end

	if nodeId == 105 then
		return true
	end

	if nodeId == 106 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_42_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_87_1(flow)

	if _0 then
		flow:setActive()
		_C(42, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_101_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(42)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "DashStart")
	flow:setContinue(95)

	return true
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 100, 0, "JumpBack", 0.5, "Alert", 0.5, "", false, true, false)
end

function _M._to_104_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 104, 0, "Alert", 1, "", 0, "", false, true, false)
end

function _M._to_105_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 105, 0, "Idle", 3, "", 0, "", false, true, false)
end

function _M._to_106_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 106, 0, "Behav_Angry", 1, "", 0, "", false, true, false)
end

function _M._get_82_2(flow)
	local _0 = _C(81, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(82, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_83_1(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_83_1(flow)
	local _0 = flow:getCache(82, "__iterItem")

	return _C(83, "CheckHasChemState", flow, _0, "STATE_AFLAME_KEY")
end

function _M._get_85_1(flow)
	local _0 = _M._get_82_2(flow)

	return _C(85, "SelectOneByRandom", flow, _0)
end

function _M._get_87_1(flow)
	local _1 = _M._get_82_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_101_1(flow)
	local _0 = flow:getCache(101, "envObj")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_85_1(flow)

	flow:setCache(101, "envObj", _0)

	return _0
end

return _M
