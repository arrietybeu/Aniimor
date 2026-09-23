-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_DrawAttention_EnvObjHint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_188_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 188 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_188_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_225_2(flow)

	if _0 then
		flow:setActive()
		_C(188, "DoBehaviour", flow, "PBT_Com_HintChestBox")

		local _1 = _M._get_190_1(flow)
		local _2 = _M._get_221_1(flow)
		local _3 = _M._get_183_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 2.5)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tTgtId", _2)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("IsCloseEnough", _3)
		flow:setContinue(188)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_182_3(flow)
	local _0 = flow:getCache(183, "__iterItem")
	local _1 = _M._get_221_1(flow)

	return _C(182, "GetDistance", flow, _0, _1, false)
end

function _M._get_183_2(flow)
	local _0 = _M._get_189_1(flow)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(183, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_217_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_189_1(flow)
	return _C(189, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
end

function _M._get_190_1(flow)
	local _0 = _M._get_189_1(flow)

	return _C(190, "SelectOneByRandom", flow, _0)
end

function _M._get_217_2(flow)
	local _2 = _M._get_182_3(flow)
	local _0 = _2 <= 7.5

	if not _0 then
		return false
	end

	local _3 = _M._get_182_3(flow)
	local _1 = _3 > 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_221_1(flow)
	local _0 = _C(220, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(221, "SelectOneByRandom", flow, _0)
end

function _M._get_224_3(flow)
	local _0 = flow:getCache(225, "__iterItem")
	local _1 = _M._get_221_1(flow)

	return _C(224, "GetDistance", flow, _0, _1, false)
end

function _M._get_225_2(flow)
	local _0 = _M._get_189_1(flow)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(225, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_227_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_227_2(flow)
	local _2 = _M._get_224_3(flow)
	local _0 = _2 <= 30

	if not _0 then
		return false
	end

	local _3 = _M._get_224_3(flow)
	local _1 = _3 > 2

	if not _1 then
		return false
	end

	return true
end

return _M
