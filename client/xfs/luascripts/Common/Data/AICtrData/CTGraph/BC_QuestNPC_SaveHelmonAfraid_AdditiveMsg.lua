-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonAfraid_AdditiveMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartFightAfraid" then
		return _M._to_74_0(flow)
	end

	if eventName == "LevelMsgTriggerEndFightAfraid" then
		return _M._to_78_0(flow)
	end

	if eventName == "LevelMsgTriggerEndOutRangeAfraid" then
		return _M._to_86_0(flow)
	end

	if eventName == "LevelMsgTriggerStartOutRangeAfraid" then
		return _M._to_93_0(flow)
	end
end

function _M._to_74_0(flow)
	local _0 = _M._get_89_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_SaveHelmon_InBattle")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_78_0(flow)
	local _0 = _C(79, "HasAITag", flow, 0, "TA_SaveHelmon_InBattle")

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_SaveHelmon_InBattle")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_86_0(flow)
	local _0 = _C(85, "HasAITag", flow, 0, "TA_SaveHelmon_OutRange")

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_SaveHelmon_OutRange")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_93_0(flow)
	local _1 = _C(94, "HasAITag", flow, 0, "TA_SaveHelmon_OutRange")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_SaveHelmon_OutRange")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_52_3(flow)
	local _0 = _C(54, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(52, "__iterItem", v)

		if _M._get_56_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_52_2(flow)
	return flow:getCache(52, "__iterItem")
end

function _M._get_56_2(flow)
	local _1 = _M._get_52_2(flow)
	local _0 = _C(55, "GetDistance", flow, _1, 0, false)

	return _0 <= 20
end

function _M._get_89_2(flow)
	local _4 = _C(90, "HasAITag", flow, 0, "TA_SaveHelmon_InBattle")
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _M._get_52_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
