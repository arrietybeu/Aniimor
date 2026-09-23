-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_ExitNoPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_260_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 249 then
		return _M._to_255_0(flow)
	end

	if nodeId == 258 then
		return _M._to_249_0(flow)
	end

	if nodeId == 260 then
		return _M._to_258_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 258 then
		return _M._get_259_1(flow)
	end
end

function _M._to_249_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(249)

	return true
end

function _M._to_255_0(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "MIMICRY")

	return true
end

function _M._to_258_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 258)

	if not _1 then
		flow:setActive()
		_C(258, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 2)
		flow:setContinue(258)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_260_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_245_4(flow)

	if _0 then
		flow:setActive()
		_C(260, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "Green")
		flow.__agent:addSubTreeLocalParam("tTimeout", 1)
		flow:setContinue(260)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_223_1(flow)
	local _0 = _C(224, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(223, "SelectOneByRandom", flow, _0)
end

function _M._get_226_2(flow)
	local _0 = _C(225, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(226, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_227_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_227_2(flow)
	local _0 = flow:getCache(226, "__iterItem")

	return _C(227, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_A")
end

function _M._get_234_2(flow)
	local _0 = _C(233, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(234, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_237_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_237_2(flow)
	local _0 = flow:getCache(234, "__iterItem")

	return _C(237, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_B")
end

function _M._get_242_2(flow)
	local _0 = _C(241, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(242, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_244_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_244_2(flow)
	local _0 = flow:getCache(242, "__iterItem")

	return _C(244, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_C")
end

function _M._get_245_4(flow)
	local _5 = _M._get_226_2(flow)
	local _6 = _C(228, "SelectOneByRandom", flow, _5)
	local _7 = _M._get_223_1(flow)
	local _4 = _C(230, "GetDistance", flow, _6, _7, false)
	local _0 = _4 >= 5.5

	if not _0 then
		return false
	end

	local _8 = _M._get_223_1(flow)
	local _9 = _M._get_234_2(flow)
	local _10 = _C(235, "SelectOneByRandom", flow, _9)
	local _11 = _C(236, "GetDistance", flow, _8, _10, false)
	local _1 = _11 >= 5.5

	if not _1 then
		return false
	end

	local _12 = _M._get_223_1(flow)
	local _15 = _M._get_242_2(flow)
	local _13 = _C(243, "SelectOneByRandom", flow, _15)
	local _14 = _C(239, "GetDistance", flow, _12, _13, false)
	local _2 = _14 >= 5.5

	if not _2 then
		return false
	end

	local _3 = _C(246, "HasAITag", flow, 0, "MIMICRY")

	if not _3 then
		return false
	end

	return true
end

function _M._get_254_0(flow)
	return _C(254, "GetSelfId", flow)
end

function _M._get_259_1(flow)
	local _0 = _M._get_245_4(flow)

	return not _0
end

return _M
