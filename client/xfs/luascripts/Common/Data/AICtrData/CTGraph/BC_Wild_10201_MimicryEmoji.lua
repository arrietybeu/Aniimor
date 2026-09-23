-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_MimicryEmoji.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_10_0(flow)
end

function _M._to_3_0(flow)
	local _0 = _M._get_0_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(4, "GetSelfId", flow)

		_A(flow, "PlayEmojiOnTarget", _1, "Angry", 3)
		flow:setActive()
		_A(flow, "AddAITag", 0, "TIMER")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_10_0(flow)
	local _2 = _M._get_9_2(flow)
	local _0 = not _2

	if _0 then
		return _M._to_3_0(flow)
	end

	local _1 = _M._get_9_2(flow)

	if _1 then
		return _M._to_12_0(flow)
	end
end

function _M._to_12_0(flow)
	local _0 = _M._get_0_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TIMER")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return _C(0, "HasAITag", flow, 0, "MIMICRY")
end

function _M._get_9_2(flow)
	return _C(9, "HasAITag", flow, 0, "TIMER")
end

return _M
