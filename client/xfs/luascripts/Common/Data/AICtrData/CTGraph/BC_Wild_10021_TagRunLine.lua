-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_TagRunLine.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerTagRunLine" then
		return _M._to_58_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Puppet_10021Run")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_65_0(flow)
	end

	if nodeId == 65 then
		return _M._to_72_0(flow)
	end

	if nodeId == 72 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_57_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_53_8(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(58)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_65_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_67_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_68_8(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(65)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_72_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_70_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_71_8(flow)

		if _P(flow, 1, _1, -1, nil) then
			flow:setContinue(72)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_53_8(flow)
	return _C(53, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "RunLine", "", "")
end

function _M._get_57_2(flow)
	local _4 = _C(61, "GetSelfId", flow)
	local _0 = _C(56, "HasEntityTag", flow, _4, "TE_Puppet_10021Run")

	if not _0 then
		return false
	end

	local _2 = _M._get_53_8(flow)
	local _3 = _2 == 0
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_67_1(flow)
	local _1 = _M._get_68_8(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_68_8(flow)
	return _C(68, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "RunAfter01", "", "")
end

function _M._get_70_1(flow)
	local _1 = _M._get_71_8(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_71_8(flow)
	return _C(71, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "RunAfter02", "", "")
end

return _M
