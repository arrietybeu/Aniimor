-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Empathy_Happy_Additive.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelUpTrigger" then
		flow:setActive()

		local _0 = _M._get_89_0(flow)

		_A(flow, "PlayEmojiOnTarget", _0, "Happy", 3)

		return true
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 95 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._get_89_0(flow)
	return _C(89, "GetSelfId", flow)
end

function _M._get_100_2(flow)
	local _2 = _C(98, "GetAnimTagDuration", flow, 0)
	local _0 = _2 > 5

	if not _0 then
		return false
	end

	local _3 = _M._get_89_0(flow)
	local _1 = _C(101, "IsInCharState", flow, _3, 1, 4)

	if not _1 then
		return false
	end

	return true
end

return _M
