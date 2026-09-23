-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_BonfireParty.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
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
	if eventName == "GBPMsg_Common01" then
		return _M._to_49_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_52_2(flow)
		local _1 = _M._get_52_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_53_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_242_0(flow)
	end

	if eventName == "GBPMsg_ResPoint04" then
		return _M._to_218_0(flow)
	end

	if eventName == "GBPMsg_ResPoint03" then
		return _M._to_239_0(flow)
	end

	if eventName == "GBPMsg_ResPoint05" then
		return _M._to_220_0(flow)
	end

	if eventName == "GBPMsg_ResPoint06" then
		return _M._to_222_0(flow)
	end

	if eventName == "GBPMsg_ResPoint07" then
		return _M._to_224_0(flow)
	end

	if eventName == "GBPMsg_ResPoint08" then
		return _M._to_226_0(flow)
	end

	if eventName == "GBPMsg_ResPoint09" then
		return _M._to_228_0(flow)
	end

	if eventName == "GBPMsg_ResPoint10" then
		return _M._to_230_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 49 then
		return true
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 60 then
		return _M._to_120_0(flow)
	end

	if nodeId == 62 then
		return _M._to_80_0(flow)
	end

	if nodeId == 65 then
		return _M._to_118_0(flow)
	end

	if nodeId == 80 then
		return _M._to_60_0(flow)
	end

	if nodeId == 84 then
		return _M._to_65_0(flow)
	end

	if nodeId == 87 then
		return _M._to_179_0(flow)
	end

	if nodeId == 118 then
		return _M._to_119_0(flow)
	end

	if nodeId == 119 then
		return true
	end

	if nodeId == 120 then
		return _M._to_121_0(flow)
	end

	if nodeId == 121 then
		return _M._to_87_0(flow)
	end

	if nodeId == 177 then
		return true
	end

	if nodeId == 179 then
		return true
	end

	if nodeId == 185 then
		return _M._to_186_0(flow)
	end

	if nodeId == 186 then
		return _M._to_188_0(flow)
	end

	if nodeId == 187 then
		return true
	end

	if nodeId == 188 then
		return _M._to_187_0(flow)
	end

	if nodeId == 190 then
		return _M._to_191_0(flow)
	end

	if nodeId == 191 then
		return _M._to_193_0(flow)
	end

	if nodeId == 192 then
		return true
	end

	if nodeId == 193 then
		return _M._to_192_0(flow)
	end

	if nodeId == 195 then
		return _M._to_196_0(flow)
	end

	if nodeId == 196 then
		return _M._to_198_0(flow)
	end

	if nodeId == 197 then
		return true
	end

	if nodeId == 198 then
		return _M._to_197_0(flow)
	end

	if nodeId == 200 then
		return _M._to_201_0(flow)
	end

	if nodeId == 201 then
		return _M._to_203_0(flow)
	end

	if nodeId == 202 then
		return true
	end

	if nodeId == 203 then
		return _M._to_202_0(flow)
	end

	if nodeId == 205 then
		return _M._to_206_0(flow)
	end

	if nodeId == 206 then
		return _M._to_208_0(flow)
	end

	if nodeId == 207 then
		return true
	end

	if nodeId == 208 then
		return _M._to_207_0(flow)
	end

	if nodeId == 210 then
		return _M._to_211_0(flow)
	end

	if nodeId == 211 then
		return _M._to_213_0(flow)
	end

	if nodeId == 212 then
		return true
	end

	if nodeId == 213 then
		return _M._to_212_0(flow)
	end

	if nodeId == 214 then
		return _M._to_215_0(flow)
	end

	if nodeId == 215 then
		return _M._to_217_0(flow)
	end

	if nodeId == 216 then
		return true
	end

	if nodeId == 217 then
		return _M._to_216_0(flow)
	end

	if nodeId == 218 then
		return true
	end

	if nodeId == 220 then
		return true
	end

	if nodeId == 222 then
		return true
	end

	if nodeId == 224 then
		return true
	end

	if nodeId == 226 then
		return true
	end

	if nodeId == 228 then
		return true
	end

	if nodeId == 230 then
		return true
	end

	if nodeId == 239 then
		return true
	end

	if nodeId == 242 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(49)

	return true
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(53)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 60, 0, "Behav_Happy", 4.5, "Happy", 4.5, "", true, false, false)
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 65, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 80, 0, "Behav_Love", 5, "", 5, "", true, false, false)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 87, 0, "Behav_Happy", 4.5, "Happy", 4.5, "", true, false, false)
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 118, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_119_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 119, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_120_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 120, 0, "Behav_Happy", 4.5, "", 0, "", true, false, false)
end

function _M._to_121_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 121, 0, "Behav_Love", 5, "", 5, "", true, false, false)
end

function _M._to_179_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 179, 0, "Behav_Love", 5, "", 0, "", true, false, false)
end

function _M._to_186_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 186, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_187_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 187, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_188_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 188, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_191_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 191, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_192_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 192, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_193_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 193, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_196_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 196, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_197_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 197, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_198_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 198, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_201_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 201, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_202_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 202, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_203_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 203, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_206_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 206, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_207_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 207, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_208_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 208, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_211_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 211, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_212_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 212, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_213_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 213, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_215_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 215, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_216_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 216, 0, "Behav_Happy", 8.25, "", 0, "", true, false, false)
end

function _M._to_217_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 217, 0, "Behav_Happy", 8.25, "Happy", 8.25, "", true, false, false)
end

function _M._to_218_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_219_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(218)

		return true
	end
end

function _M._to_220_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_221_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(220)

		return true
	end
end

function _M._to_222_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_223_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(222)

		return true
	end
end

function _M._to_224_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_225_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(224)

		return true
	end
end

function _M._to_226_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_227_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(226)

		return true
	end
end

function _M._to_228_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_229_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(228)

		return true
	end
end

function _M._to_230_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_231_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(230)

		return true
	end
end

function _M._to_239_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_240_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(239)

		return true
	end
end

function _M._to_242_0(flow)
	if not _B(flow, "PBT_Com_Happy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow:setContinue(242)

	return true
end

function _M._get_52_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_52_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_178_0(flow)
	return "LOCOMOTION"
end

function _M._get_219_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(219, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_221_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(221, "GetRouteIdFromResPoint", flow, true, _0, 3)
end

function _M._get_223_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(223, "GetRouteIdFromResPoint", flow, true, _0, 4)
end

function _M._get_225_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(225, "GetRouteIdFromResPoint", flow, true, _0, 5)
end

function _M._get_227_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(227, "GetRouteIdFromResPoint", flow, true, _0, 6)
end

function _M._get_229_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(229, "GetRouteIdFromResPoint", flow, true, _0, 7)
end

function _M._get_231_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(231, "GetRouteIdFromResPoint", flow, true, _0, 8)
end

function _M._get_240_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(240, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

return _M
