-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Full_CatchTutorial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()
		_A(flow, "TriggerBluePrint", "Angry")
		flow:setActive()

		local _0 = _M._get_115_0(flow)

		_A(flow, "AddEntityTag", _0, "TE_Wild_CatchToturialAngry")

		return _M._to_104_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")
	flow:setActive()

	local _0 = _M._get_115_0(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Wild_CatchToturialAngry")

	return _M._to_112_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 104 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 104 then
		return _M._get_111_1(flow)
	end
end

function _M._to_104_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 104)

	if not _1 then
		flow:setActive()
		_C(104, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Angry")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(104)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_112_0(flow)
	local _0 = flow.__finishType == CTRConst.FlowFinishType.Interrupt

	if _0 then
		flow:setActive()
		_A(flow, "TriggerBluePrint", "AngryFinish")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_106_1(flow)
	return _C(106, "GetPerceptibilityValue", flow, 0)
end

function _M._get_111_1(flow)
	local _0 = _C(107, "GetPerceptibilityTable", flow)

	return not _0 or next(_0) == nil
end

function _M._get_115_0(flow)
	return _C(115, "GetSelfId", flow)
end

return _M
