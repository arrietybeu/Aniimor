-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10031TeachInvisible.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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
	if eventName == "GBPMsg_CommonStartChat" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 100310022, 0)

		return _M._to_158_0(flow)
	end

	if eventName == "GBPMsg_CommonCopyThat" then
		return _M._to_204_0(flow)
	end

	if eventName == "GBPMsg_Common10032StartInvisible" then
		return _M._to_162_0(flow)
	end

	if eventName == "GBPMsg_CommonChat1" then
		return _M._to_206_0(flow)
	end

	if eventName == "GBPMsg_CommonChat2" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 100310028, 0)

		return true
	end

	if eventName == "GBPMsg_Common10031StartInvisible1" then
		return _M._to_173_0(flow)
	end

	if eventName == "GBPMsg_CommonEndChat" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 100310031, 0)

		return true
	end

	if eventName == "GBPMsg_ResPointGoRoute" then
		flow:setActive()

		local _0 = _M._get_198_2(flow)
		local _1 = _M._get_198_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_197_0(flow)
	end

	if eventName == "GBPMsg_Common10031StartInvisible2" then
		return _M._to_221_0(flow)
	end

	if eventName == "GBPMsg_Common10031StartInvisible3" then
		return _M._to_234_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_198_2(flow)
	local _1 = _M._get_198_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 158 then
		return _M._to_156_0(flow)
	end

	if nodeId == 162 then
		return _M._to_167_0(flow)
	end

	if nodeId == 167 then
		return _M._to_168_0(flow)
	end

	if nodeId == 168 then
		return _M._to_169_0(flow)
	end

	if nodeId == 170 then
		return _M._to_171_0(flow)
	end

	if nodeId == 173 then
		return _M._to_174_0(flow)
	end

	if nodeId == 174 then
		return _M._to_177_0(flow)
	end

	if nodeId == 177 then
		return _M._to_180_0(flow)
	end

	if nodeId == 197 then
		return true
	end

	if nodeId == 205 then
		return true
	end

	if nodeId == 207 then
		return true
	end

	if nodeId == 209 then
		return true
	end

	if nodeId == 212 then
		return true
	end

	if nodeId == 221 then
		return _M._to_225_0(flow)
	end

	if nodeId == 225 then
		return _M._to_227_0(flow)
	end

	if nodeId == 227 then
		return _M._to_228_0(flow)
	end

	if nodeId == 230 then
		return true
	end

	if nodeId == 233 then
		return true
	end

	if nodeId == 234 then
		return _M._to_237_0(flow)
	end

	if nodeId == 237 then
		return _M._to_239_0(flow)
	end

	if nodeId == 239 then
		return _M._to_240_0(flow)
	end

	if nodeId == 242 then
		return true
	end

	if nodeId == 245 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_156_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310023, 0)

	return true
end

function _M._to_158_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_0(flow, 158, 2)
end

function _M._to_160_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310024, 0)

	return true
end

function _M._to_162_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 162, 0, 10320900, 0, "", 5, false, 0)
end

function _M._to_164_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310027, 0)

	return true
end

function _M._to_167_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_0(flow, 167, 5)
end

function _M._to_168_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 168, 0, 10320000, 0, "", 5, false, 0)
end

function _M._to_169_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310025, 0)

	return _M._to_170_0(flow)
end

function _M._to_170_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_0(flow, 170, 2)
end

function _M._to_171_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310026, 0)

	return true
end

function _M._to_173_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 173, 0, 10310900, 0, "", 5, false, 0)
end

function _M._to_174_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _M._get_248_1(flow)

	return _doBehaviourTail_0(flow, 174, _0)
end

function _M._to_177_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 177, 0, 10310910, 0, "", 5, false, 0)
end

function _M._to_178_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310029, 0)

	return true
end

function _M._to_180_0(flow)
	local _1 = _M._get_248_1(flow)
	local _0 = _1 >= 5

	if _0 then
		return _M._to_210_0(flow)
	end

	return _M._to_211_0(flow)
end

function _M._to_197_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_198_2(flow)
	local _1 = _M._get_198_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(197)

	return true
end

function _M._to_204_0(flow)
	flow:addTimer(0, _M, "_to_160_0", flow)

	return _M._to_205_0(flow)
end

function _M._to_205_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 205, 0, "Behav_Happy", 3, "", 5, "", false, false, false)
end

function _M._to_206_0(flow)
	flow:addTimer(0, _M, "_to_164_0", flow)

	return _M._to_207_0(flow)
end

function _M._to_207_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 207, 0, "Behav_Alert", 3, "", 5, "", false, false, false)
end

function _M._to_209_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 209, 0, "Behav_Love", 4, "", 5, "", false, false, false)
end

function _M._to_210_0(flow)
	flow:addTimer(0, _M, "_to_178_0", flow)

	return _M._to_209_0(flow)
end

function _M._to_211_0(flow)
	flow:addTimer(0, _M, "_to_220_0", flow)

	return _M._to_212_0(flow)
end

function _M._to_212_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 212, 0, "Behav_Doubt", 4, "", 5, "", false, false, false)
end

function _M._to_220_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310030, 0)

	return true
end

function _M._to_221_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 221, 0, 10310900, 0, "", 5, false, 0)
end

function _M._to_222_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310029, 0)

	return true
end

function _M._to_223_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310030, 0)

	return true
end

function _M._to_225_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _M._get_251_1(flow)

	return _doBehaviourTail_0(flow, 225, _0)
end

function _M._to_227_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 227, 0, 10310910, 0, "", 5, false, 0)
end

function _M._to_228_0(flow)
	local _1 = _M._get_251_1(flow)
	local _0 = _1 >= 5

	if _0 then
		return _M._to_232_0(flow)
	end

	return _M._to_231_0(flow)
end

function _M._to_230_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 230, 0, "Behav_Love", 4, "", 5, "", false, false, false)
end

function _M._to_231_0(flow)
	flow:addTimer(0, _M, "_to_223_0", flow)

	return _M._to_233_0(flow)
end

function _M._to_232_0(flow)
	flow:addTimer(0, _M, "_to_222_0", flow)

	return _M._to_230_0(flow)
end

function _M._to_233_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 233, 0, "Behav_Doubt", 4, "", 5, "", false, false, false)
end

function _M._to_234_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 234, 0, 10310900, 0, "", 5, false, 0)
end

function _M._to_235_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310029, 0)

	return true
end

function _M._to_236_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 100310030, 0)

	return true
end

function _M._to_237_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _M._get_252_1(flow)

	return _doBehaviourTail_0(flow, 237, _0)
end

function _M._to_239_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 239, 0, 10310910, 0, "", 5, false, 0)
end

function _M._to_240_0(flow)
	local _1 = _M._get_252_1(flow)
	local _0 = _1 >= 5

	if _0 then
		return _M._to_244_0(flow)
	end

	return _M._to_243_0(flow)
end

function _M._to_242_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 242, 0, "Behav_Love", 4, "", 5, "", false, false, false)
end

function _M._to_243_0(flow)
	flow:addTimer(0, _M, "_to_236_0", flow)

	return _M._to_245_0(flow)
end

function _M._to_244_0(flow)
	flow:addTimer(0, _M, "_to_235_0", flow)

	return _M._to_242_0(flow)
end

function _M._to_245_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 245, 0, "Behav_Doubt", 4, "", 5, "", false, false, false)
end

function _M._get_175_2(flow)
	return _C(175, "RandomInteger", flow, 2, 5)
end

function _M._get_198_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_198_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_226_2(flow)
	return _C(226, "RandomInteger", flow, 2, 5)
end

function _M._get_238_2(flow)
	return _C(238, "RandomInteger", flow, 2, 5)
end

function _M._get_248_1(flow)
	local _0 = flow:getCache(248, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_175_2(flow)

	flow:setCache(248, "1", _0)

	return _0
end

function _M._get_251_1(flow)
	local _0 = flow:getCache(251, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_226_2(flow)

	flow:setCache(251, "1", _0)

	return _0
end

function _M._get_252_1(flow)
	local _0 = flow:getCache(252, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_238_2(flow)

	flow:setCache(252, "1", _0)

	return _0
end

return _M
