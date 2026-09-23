-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Summoner_Glutton_Behav.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_90_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 96 then
		return true
	end

	if nodeId == 97 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 96 then
		return _M._get_91_1(flow)
	end

	if nodeId == 97 then
		return _M._get_104_2(flow)
	end
end

function _M._to_90_0(flow)
	local _0 = _M._get_85_3(flow)

	if _0 then
		return _M._to_96_0(flow)
	end

	local _1 = _M._get_89_3(flow)

	if _1 then
		return _M._to_97_0(flow)
	end
end

function _M._to_96_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 96)

	if not _1 then
		flow:setActive()
		_C(96, "DoBehaviour", flow, "PBT_LoopAnimAndBreak")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_EatStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_EatLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_EatEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 99999)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tBreakTag", "EatBreak")
		flow:setContinue(96)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_97_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 97)

	if not _1 then
		flow:setActive()
		_C(97, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_86_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 15)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 7)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(97)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_78_2(flow)
	local _0 = _M._get_80_2(flow)

	return _C(78, "HasEntityTag", flow, _0, "TE_Chest_Collectible")
end

function _M._get_80_2(flow)
	return flow:getCache(80, "__iterItem")
end

function _M._get_80_3(flow)
	local _0 = _C(82, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(80, "__iterItem", v)

		if _M._get_78_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_85_3(flow)
	local _0 = _C(79, "HasAITag", flow, 0, "Eat")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_86_2(flow)
	local _0 = _M._get_80_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(86, "__iterItem", v)

		_1 = _M._get_87_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_87_3(flow)
	local _0 = flow:getCache(86, "__iterItem")

	return _C(87, "GetDistance", flow, _0, 0, false)
end

function _M._get_89_3(flow)
	if false then
		return false
	end

	if false then
		return false
	end

	local _0 = _C(77, "HasAITag", flow, 0, "Find")

	if not _0 then
		return false
	end

	return true
end

function _M._get_91_1(flow)
	local _0 = _C(92, "HasAITag", flow, 0, "Eat")

	return not _0
end

function _M._get_104_2(flow)
	local _0 = _M._get_85_3(flow)

	if _0 then
		return true
	end

	if false then
		return true
	end

	return false
end

return _M
