-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_SelectEnvObjinDisbyEntityTag.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "HasEntity" then
		return false
	end

	if valueName == "Actorid" then
		return _M._get_5_1(flow)
	end
end

function _M._get_1_2(flow)
	local _3 = _M._get_12_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, _3, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(1, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_6_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_1_3(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_4_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(4, "SelectOneByRandom", flow, _0)
end

function _M._get_5_1(flow)
	local _0 = flow:getCache(5, "ActorId")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_4_1(flow)

	flow:setCache(5, "ActorId", _0)

	return _0
end

function _M._get_6_2(flow)
	local _2 = _M._get_1_3(flow)
	local _3 = flow:getContextValue("EntityTag")
	local _0 = _C(2, "HasEntityTag", flow, _2, _3)

	if not _0 then
		return false
	end

	local _4 = _M._get_1_3(flow)
	local _5 = _M._get_12_2(flow)
	local _6 = _C(3, "GetDistance", flow, _4, _5, false)
	local _7 = flow:getContextValue("Distance")
	local _1 = _6 <= _7

	if not _1 then
		return false
	end

	return true
end

function _M._get_12_2(flow)
	return flow:getContextValue("TargetId")
end

function _M._get_15_1(flow)
	local _1 = _M._get_1_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
