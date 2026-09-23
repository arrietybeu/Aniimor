-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_LeaveToCreateDarkCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SensedMsgTrigger" then
		return _M._to_94_0(flow)
	end
end

function _M._to_94_0(flow)
	local _0 = _M._get_100_2(flow)

	if _0 then
		flow:setActive()
		_C(94, "CreateEntityGroupBehaviour", flow, "SheepGather")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_100_2(flow)
	local _2 = _C(93, "IsInGroupBehaviour", flow, 0, true, "Any")
	local _0 = not _2

	if not _0 then
		return false
	end

	local _4 = _M._get_104_3(flow)
	local _3 = not _4 or next(_4) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_104_2(flow)
	return flow:getCache(104, "__iterItem")
end

function _M._get_104_3(flow)
	local _0 = _C(102, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(104, "__iterItem", v)

		if _M._get_112_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_112_2(flow)
	local _2 = _M._get_104_2(flow)
	local _3 = _C(101, "GetDistance", flow, _2, 0, false)
	local _0 = _3 <= 10

	if not _0 then
		return false
	end

	local _4 = _M._get_104_2(flow)
	local _5 = _C(113, "GetPuppetData", flow, _4, "id", true, 0)
	local _1 = _5 == 11026101

	if not _1 then
		return false
	end

	return true
end

return _M
