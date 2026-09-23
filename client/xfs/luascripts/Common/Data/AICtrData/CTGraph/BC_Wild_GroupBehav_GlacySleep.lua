-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_GlacySleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_CommonPlay1" then
		return _M._to_256_0(flow)
	end

	if eventName == "GBPMsg_CommonDoPatrol" then
		return _M._to_85_0(flow)
	end

	if eventName == "GBPMsg_CommonHappy1" then
		return _M._to_255_0(flow)
	end

	if eventName == "GBPMsg_CommonHappy2" then
		return _M._to_252_0(flow)
	end

	if eventName == "GBPMsg_CommonHappy" then
		return _M._to_103_0(flow)
	end

	if eventName == "GBPMsg_CommonPlay2" then
		return _M._to_257_0(flow)
	end

	if eventName == "GBPMsg_CommonPlay3" then
		return _M._to_258_0(flow)
	end

	if eventName == "GBPMsg_CommonCry" then
		return _M._to_125_0(flow)
	end

	if eventName == "GBPMsg_CommonLookAround" then
		return _M._to_196_0(flow)
	end

	if eventName == "GBPMsg_CommonBack2" then
		return _M._to_259_0(flow)
	end

	if eventName == "GBPMsg_CommonBack3" then
		return _M._to_260_0(flow)
	end

	if eventName == "GBPMsg_CommonBack1" then
		return _M._to_261_0(flow)
	end

	if eventName == "GBPMsg_CommonHappy3" then
		return _M._to_254_0(flow)
	end

	if eventName == "GBPMsg_CommonGlacyGoSleep" then
		return _M._to_249_0(flow)
	end

	if eventName == "GBPMsg_CommonGlacyWakeUp" then
		return _M._to_207_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 85 then
		return true
	end

	if nodeId == 89 then
		return true
	end

	if nodeId == 91 then
		return true
	end

	if nodeId == 103 then
		return true
	end

	if nodeId == 114 then
		return true
	end

	if nodeId == 125 then
		return true
	end

	if nodeId == 196 then
		return true
	end

	if nodeId == 207 then
		return _M._to_114_0(flow)
	end

	if nodeId == 249 then
		return _M._to_89_0(flow)
	end

	if nodeId == 252 then
		return true
	end

	if nodeId == 254 then
		return true
	end

	if nodeId == 255 then
		return _M._to_91_0(flow)
	end

	if nodeId == 256 then
		return true
	end

	if nodeId == 257 then
		return true
	end

	if nodeId == 258 then
		return true
	end

	if nodeId == 259 then
		return true
	end

	if nodeId == 260 then
		return true
	end

	if nodeId == 261 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_Behav_Com_IdlePatrol") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("SpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("Speed", 1)
	flow:setContinue(85)

	return true
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("sleepTimeOut", 99999)
	flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
	flow.__agent:addSubTreeLocalParam("tisLoop", false)
	flow:setContinue(89)

	return true
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 91, 0, "Behav_Happy", 3, "Happy", 3, "", false, false, false)
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 103, 0, "Behav_Happy", 3, "Happy", 3, "", false, false, false)
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_Com_Angry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(114)

	return true
end

function _M._to_125_0(flow)
	if not _B(flow, "PBT_Com_Cry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow:setContinue(125)

	return true
end

function _M._to_196_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 196, 0, "Behav_Alert", 4.18, "Angry", 4, "", false, false, false)
end

function _M._to_207_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 207, 0, "Behav_SleepEnd", 1.74, "", 0, "", false, false, false)
end

function _M._to_249_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263311, 1, nil) then
		flow:setContinue(249)

		return true
	end
end

function _M._to_252_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263308, 1, nil) then
		flow:setContinue(252)

		return true
	end
end

function _M._to_254_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263310, 1, nil) then
		flow:setContinue(254)

		return true
	end
end

function _M._to_255_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263309, 1, nil) then
		flow:setContinue(255)

		return true
	end
end

function _M._to_256_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263312, 1, nil) then
		flow:setContinue(256)

		return true
	end
end

function _M._to_257_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263313, 1, nil) then
		flow:setContinue(257)

		return true
	end
end

function _M._to_258_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263314, 1, nil) then
		flow:setContinue(258)

		return true
	end
end

function _M._to_259_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263318, 1, nil) then
		flow:setContinue(259)

		return true
	end
end

function _M._to_260_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263316, 1, nil) then
		flow:setContinue(260)

		return true
	end
end

function _M._to_261_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90263317, 1, nil) then
		flow:setContinue(261)

		return true
	end
end

return _M
