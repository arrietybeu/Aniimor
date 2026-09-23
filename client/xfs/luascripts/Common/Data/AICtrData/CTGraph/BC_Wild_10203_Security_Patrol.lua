-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Security_Patrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_8_0(flow)
end

function _M._to_8_0(flow)
	local _0 = _M._get_21_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_1_0(flow)

		_A(flow, "StopEffectOnTarget", _1, "Eff_Parmon_10203_Behav_Security_Locking")
		flow:setActive()

		local _2 = _M._get_1_0(flow)

		_A(flow, "PlayEffectOnTarget", _2, "Eff_Parmon_10203_Behav_Security_Finding", -1)
		flow:setActive()
		_A(flow, "AddAITag", 0, "Patrol")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_0(flow)
	return _C(1, "GetSelfId", flow)
end

function _M._get_13_1(flow)
	local _0 = _M._get_19_0(flow)

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

function _M._get_19_0(flow)
	return _C(19, "GetPerceptibilityTable", flow)
end

function _M._get_20_2(flow)
	local _3 = _M._get_19_0(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		return true
	end

	local _5 = _M._get_13_1(flow)
	local _2 = _C(17, "GetPerceptibilityValue", flow, _5)
	local _1 = _2 <= 0

	if _1 then
		return true
	end

	return false
end

function _M._get_21_3(flow)
	local _3 = _C(9, "HasAITag", flow, 0, "Patrol")
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _M._get_20_2(flow)

	if not _1 then
		return false
	end

	local _2 = _C(42, "HasAITag", flow, 0, "Awake")

	if not _2 then
		return false
	end

	return true
end

return _M
