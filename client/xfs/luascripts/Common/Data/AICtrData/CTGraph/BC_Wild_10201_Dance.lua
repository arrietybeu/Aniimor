-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Dance.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_77_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_74_1(flow)
	local _1 = _M._get_74_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 47 then
		return true
	end

	if nodeId == 70 then
		return _M._to_78_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 6)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(47)

	return true
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_74_1(flow)
	local _1 = _M._get_74_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1.6)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(70)

	return true
end

function _M._to_77_0(flow)
	local _0 = _M._get_79_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_74_1(flow)
		local _2 = _M._get_74_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_70_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_78_0(flow)
	flow:setActive()

	local _0 = _M._get_74_1(flow)
	local _1 = _M._get_74_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return _M._to_47_0(flow)
end

function _M._get_56_1(flow)
	local _0 = flow:getCache(57, "__iterItem")

	return _C(56, "CheckHasChemState", flow, _0, nil)
end

function _M._get_57_2(flow)
	local _0 = _C(55, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(57, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_56_1(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_64_1(flow)
	local _0 = _M._get_72_2(flow)

	return _C(64, "SelectOneByRandom", flow, _0)
end

function _M._get_67_1(flow)
	local _0 = flow:getCache(67, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_64_1(flow)

	flow:setCache(67, "resPointPort", _0)

	return _0
end

function _M._get_68_2(flow)
	local _1 = flow:getCache(72, "__iterItem")
	local _0 = _C(73, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 15
end

function _M._get_72_2(flow)
	local _0 = _C(71, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_ZDC_Dance"
	}, {
		""
	})

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(72, "__iterItem", v)

		if _M._get_68_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_74_2(flow)
	local _0 = _M._get_67_1(flow)

	return _C(74, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_74_1(flow)
	local _0 = _M._get_67_1(flow)

	return _C(74, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_79_2(flow)
	local _2 = _M._get_57_2(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_72_2(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

return _M
