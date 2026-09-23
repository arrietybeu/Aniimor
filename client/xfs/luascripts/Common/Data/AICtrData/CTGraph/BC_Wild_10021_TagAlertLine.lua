-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_TagAlertLine.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerTagAlertLine" then
		return _M._to_81_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Puppet_Alert10021Behav")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_82_0(flow)
	end

	if nodeId == 67 then
		return _M._to_60_0(flow)
	end

	if nodeId == 69 then
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

	flow:setActive()

	local _0 = _M._get_53_8(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(58)

		return true
	end
end

function _M._to_60_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Puppet_Alert10021Hide")

	return _M._to_69_0(flow)
end

function _M._to_67_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_66_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_68_8(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(67)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_69_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_71_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_72_8(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(69)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_81_0(flow)
	local _0 = _M._get_76_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Puppet_Alert10021AlertLine")

		return _M._to_58_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_82_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Puppet_Alert10021AlertLine")
	flow:setActive()
	_A(flow, "AddEntityTag", 0, "TE_Puppet_Alert10021Hide")

	return _M._to_67_0(flow)
end

function _M._get_53_8(flow)
	return _C(53, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "AlertLine", "", "")
end

function _M._get_66_1(flow)
	local _1 = _M._get_68_8(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_68_8(flow)
	return _C(68, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "HideHere", "", "")
end

function _M._get_71_1(flow)
	local _1 = _M._get_72_8(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_72_8(flow)
	return _C(72, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "ReturnLine", "", "")
end

function _M._get_76_2(flow)
	local _4 = _C(75, "GetSelfId", flow)
	local _0 = _C(74, "HasEntityTag", flow, _4, "TE_Puppet_Alert10021Behav")

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

return _M
