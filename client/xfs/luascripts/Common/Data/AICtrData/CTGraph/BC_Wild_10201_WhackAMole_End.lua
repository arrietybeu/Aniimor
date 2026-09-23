-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_WhackAMole_End.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_41_0(flow)
end

function _M._to_41_0(flow)
	local _0 = _M._get_33_3(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "AnimationEnd")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_29_2(flow)
	local _2 = _M._get_32_2(flow)
	local _0 = _C(38, "HasEntityTag", flow, _2, "TE_Env_CE_Budclaw_A")

	if not _0 then
		return false
	end

	local _3 = _M._get_32_2(flow)
	local _4 = _C(27, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 45

	if not _1 then
		return false
	end

	return true
end

function _M._get_32_3(flow)
	local _0 = _C(30, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(32, "__iterItem", v)

		if _M._get_29_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_32_2(flow)
	return flow:getCache(32, "__iterItem")
end

function _M._get_33_3(flow)
	local _3 = _M._get_32_3(flow)
	local _0 = not _3 or next(_3) == nil

	if not _0 then
		return false
	end

	local _4 = _M._get_35_0(flow)
	local _1 = _C(34, "IsInBehavTag", flow, _4, "TB_Mimicry_HeadOut_Loop")

	if not _1 then
		return false
	end

	local _5 = _M._get_35_0(flow)
	local _6 = _C(36, "HasAITag", flow, _5, "AnimationEnd")
	local _2 = not _6

	if not _2 then
		return false
	end

	return true
end

function _M._get_35_0(flow)
	return _C(35, "GetSelfId", flow)
end

return _M
