-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Home_Work.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Msg_Home_Common" then
		return _M._to_2_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Behav_Home_Operate") then
		return
	end

	local _0 = flow:getContextValue("animationKey")
	local _1 = flow:getContextValue("faceAnimationKey")
	local _2 = flow:getContextValue("pos")
	local _3 = flow:getContextValue("yawAngle")
	local _4 = flow:getContextValue("workPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationKey", _0)
	flow.__agent:addSubTreeLocalParam("tFaceAnimationkey", _1)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _2)
	flow.__agent:addSubTreeLocalParam("tYaw", _3)
	flow.__agent:addSubTreeLocalParam("tWorkPos", _4)
	flow:setContinue(2)

	return true
end

return _M
