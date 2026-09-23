-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_SkillSprint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_0_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_111_2(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_SneakSprint")

		local _1 = _M._get_101_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetId", _1)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_101_1(flow)
	local _0 = _M._get_103_2(flow)

	return _C(101, "SelectOneByRandom", flow, _0)
end

function _M._get_103_2(flow)
	local _0 = _C(102, "GetAoiEntityTableByLevel", flow, 0, 10, 2)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(103, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_106_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_106_2(flow)
	local _1 = flow:getCache(103, "__iterItem")
	local _0 = _C(105, "GetDistance", flow, _1, 0, false)

	return _0 <= 5
end

function _M._get_110_1(flow)
	local _0 = _C(107, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_111_2(flow)
	local _3 = _M._get_103_2(flow)
	local _2 = not _3 or next(_3) == nil
	local _0 = not _2

	if not _0 then
		return false
	end

	local _4 = _M._get_110_1(flow)
	local _5 = _C(108, "GetPerceptibilityValue", flow, _4)
	local _1 = _5 >= 1

	if not _1 then
		return false
	end

	return true
end

return _M
