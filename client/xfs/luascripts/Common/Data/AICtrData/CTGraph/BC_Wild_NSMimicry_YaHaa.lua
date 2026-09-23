-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_NSMimicry_YaHaa.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_85_0(flow)
	end

	if nodeId == 77 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 29 then
		return _M._get_83_1(flow)
	end

	if nodeId == 77 then
		return _M._get_83_1(flow)
	end
end

function _M._to_29_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 29)

	if not _1 then
		flow:setActive()
		_C(29, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = "LOCOMOTION"

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(29)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_77_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 77)

	if not _1 then
		flow:setActive()
		_C(77, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(77)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_79_0(flow)
	local _1 = _M._get_53_2(flow)
	local _2 = _C(51, "SelectOneByRandom", flow, _1)
	local _3 = _C(50, "GetDistance", flow, _2, 0, false)
	local _4 = _3 <= 1.5
	local _0 = not _4

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "IsDoing")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "00")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_81_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "IsDoing")

	return _M._to_29_0(flow)
end

function _M._to_85_0(flow)
	local _1 = _C(86, "HasAITag", flow, 0, "00")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "00")

		return _M._to_77_0(flow)
	end
end

function _M._get_52_2(flow)
	local _0 = flow:getCache(53, "__iterItem")

	return _C(52, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_A")
end

function _M._get_53_2(flow)
	local _0 = _C(49, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(53, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_52_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_66_1(flow)
	local _0 = _C(57, "HasAITag", flow, 0, "IsDoing")

	return not _0
end

function _M._get_83_1(flow)
	local _0 = _C(82, "HasAITag", flow, 0, "IsDoing")

	return not _0
end

return _M
