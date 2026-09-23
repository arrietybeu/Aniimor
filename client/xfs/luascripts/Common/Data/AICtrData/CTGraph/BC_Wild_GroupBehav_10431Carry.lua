-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10431Carry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPointId", value0)
	agent:addSubTreeLocalParam("tPortId", value1)
	agent:addSubTreeLocalParam("tTimeout", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value5)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointGO" then
		flow:setActive()

		local _0 = _M._get_25_2(flow)
		local _1 = _M._get_25_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_28_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol1" then
		return _M._to_212_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol2" then
		return _M._to_214_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol3" then
		return _M._to_216_0(flow)
	end

	if eventName == "GBPMsg_ResPointCarry01" then
		return _M._to_169_0(flow)
	end

	if eventName == "GBPMsg_ResPointCarry02" then
		return _M._to_171_0(flow)
	end

	if eventName == "GBPMsg_ResPointCarry03" then
		return _M._to_174_0(flow)
	end

	if eventName == "GBPMsg_ResPointBack01" then
		return _M._to_175_0(flow)
	end

	if eventName == "GBPMsg_ResPointBack02" then
		return _M._to_180_0(flow)
	end

	if eventName == "GBPMsg_ResPointBack03" then
		return _M._to_185_0(flow)
	end

	if eventName == "GBPMsg_ResPointDrop01" then
		return _M._to_193_0(flow)
	end

	if eventName == "GBPMsg_ResPointDrop02" then
		return _M._to_199_0(flow)
	end

	if eventName == "GBPMsg_ResPointDrop03" then
		return _M._to_205_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return _M._to_233_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 103 then
		return _M._to_220_0(flow)
	end

	if nodeId == 139 then
		return true
	end

	if nodeId == 141 then
		return _M._to_144_0(flow)
	end

	if nodeId == 144 then
		return true
	end

	if nodeId == 147 then
		return _M._to_150_0(flow)
	end

	if nodeId == 150 then
		return true
	end

	if nodeId == 152 then
		return _M._to_157_0(flow)
	end

	if nodeId == 158 then
		return _M._to_161_0(flow)
	end

	if nodeId == 162 then
		return _M._to_165_0(flow)
	end

	if nodeId == 166 then
		return true
	end

	if nodeId == 167 then
		return true
	end

	if nodeId == 168 then
		return true
	end

	if nodeId == 175 then
		return _M._to_222_0(flow)
	end

	if nodeId == 178 then
		return true
	end

	if nodeId == 180 then
		return _M._to_183_0(flow)
	end

	if nodeId == 183 then
		return true
	end

	if nodeId == 185 then
		return _M._to_188_0(flow)
	end

	if nodeId == 188 then
		return true
	end

	if nodeId == 191 then
		return true
	end

	if nodeId == 194 then
		return _M._to_190_0(flow)
	end

	if nodeId == 198 then
		return true
	end

	if nodeId == 201 then
		return _M._to_197_0(flow)
	end

	if nodeId == 204 then
		return true
	end

	if nodeId == 207 then
		return _M._to_203_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	return _doBehaviourTail_0(flow, 28, _0, _1, 1000, 1, 0, false)
end

function _M._to_103_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_102_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(103)

		return true
	end
end

function _M._to_139_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_140_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(139)

		return true
	end
end

function _M._to_141_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_143_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(141)

		return true
	end
end

function _M._to_144_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_145_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(144)

		return true
	end
end

function _M._to_147_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_149_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(147)

		return true
	end
end

function _M._to_150_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_151_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(150)

		return true
	end
end

function _M._to_152_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_154_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(152)

		return true
	end
end

function _M._to_157_0(flow)
	flow:setActive()

	local _0 = _M._get_153_2(flow)
	local _1 = _M._get_153_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_218_0(flow)
end

function _M._to_158_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_160_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(158)

		return true
	end
end

function _M._to_161_0(flow)
	flow:setActive()

	local _0 = _M._get_159_2(flow)
	local _1 = _M._get_159_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_167_0(flow)
end

function _M._to_162_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_164_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(162)

		return true
	end
end

function _M._to_165_0(flow)
	flow:setActive()

	local _0 = _M._get_163_2(flow)
	local _1 = _M._get_163_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_168_0(flow)
end

function _M._to_166_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_153_2(flow)
	local _1 = _M._get_153_3(flow)

	return _doBehaviourTail_0(flow, 166, _0, _1, 1000, 0, 0, true)
end

function _M._to_167_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_159_2(flow)
	local _1 = _M._get_159_3(flow)

	return _doBehaviourTail_0(flow, 167, _0, _1, 1000, 0, 0, true)
end

function _M._to_168_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_163_2(flow)
	local _1 = _M._get_163_3(flow)

	return _doBehaviourTail_0(flow, 168, _0, _1, 1000, 0, 0, true)
end

function _M._to_169_0(flow)
	flow:addTimer(4, _M, "_to_170_0", flow)

	return _M._to_152_0(flow)
end

function _M._to_170_0(flow)
	flow:setActive()
	_A(flow, "PlayEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001", -1)

	return true
end

function _M._to_171_0(flow)
	flow:addTimer(6, _M, "_to_172_0", flow)

	return _M._to_158_0(flow)
end

function _M._to_172_0(flow)
	flow:setActive()
	_A(flow, "PlayEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001", -1)

	return true
end

function _M._to_173_0(flow)
	flow:setActive()
	_A(flow, "PlayEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001", -1)

	return true
end

function _M._to_174_0(flow)
	flow:addTimer(7, _M, "_to_173_0", flow)

	return _M._to_162_0(flow)
end

function _M._to_175_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_177_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(175)

		return true
	end
end

function _M._to_178_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_179_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(178)

		return true
	end
end

function _M._to_180_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_182_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(180)

		return true
	end
end

function _M._to_183_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_184_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(183)

		return true
	end
end

function _M._to_185_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_187_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(185)

		return true
	end
end

function _M._to_188_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_189_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(188)

		return true
	end
end

function _M._to_190_0(flow)
	flow:setActive()

	local _0 = _M._get_192_2(flow)
	local _1 = _M._get_192_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_191_0(flow)
end

function _M._to_191_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_192_2(flow)
	local _1 = _M._get_192_3(flow)

	return _doBehaviourTail_0(flow, 191, _0, _1, 1000, 0, 0, true)
end

function _M._to_193_0(flow)
	flow:addTimer(3, _M, "_to_209_0", flow)

	return _M._to_194_0(flow)
end

function _M._to_194_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_196_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(194)

		return true
	end
end

function _M._to_197_0(flow)
	flow:setActive()

	local _0 = _M._get_200_2(flow)
	local _1 = _M._get_200_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_198_0(flow)
end

function _M._to_198_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_200_2(flow)
	local _1 = _M._get_200_3(flow)

	return _doBehaviourTail_0(flow, 198, _0, _1, 1000, 0, 0, true)
end

function _M._to_199_0(flow)
	flow:addTimer(5, _M, "_to_210_0", flow)

	return _M._to_201_0(flow)
end

function _M._to_201_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_202_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(201)

		return true
	end
end

function _M._to_203_0(flow)
	flow:setActive()

	local _0 = _M._get_206_2(flow)
	local _1 = _M._get_206_3(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_204_0(flow)
end

function _M._to_204_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_206_2(flow)
	local _1 = _M._get_206_3(flow)

	return _doBehaviourTail_0(flow, 204, _0, _1, 1000, 0, 0, true)
end

function _M._to_205_0(flow)
	flow:addTimer(7, _M, "_to_211_0", flow)

	return _M._to_207_0(flow)
end

function _M._to_207_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_208_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(207)

		return true
	end
end

function _M._to_209_0(flow)
	flow:setActive()
	_A(flow, "StopEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001")

	return true
end

function _M._to_210_0(flow)
	flow:setActive()
	_A(flow, "StopEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001")

	return true
end

function _M._to_211_0(flow)
	flow:setActive()
	_A(flow, "StopEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001")

	return true
end

function _M._to_212_0(flow)
	flow:addTimer(2, _M, "_to_213_0", flow)

	return _M._to_103_0(flow)
end

function _M._to_213_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810006, 0)

	return true
end

function _M._to_214_0(flow)
	flow:addTimer(4, _M, "_to_215_0", flow)

	return _M._to_141_0(flow)
end

function _M._to_215_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810007, 0)

	return true
end

function _M._to_216_0(flow)
	flow:addTimer(6, _M, "_to_217_0", flow)

	return _M._to_147_0(flow)
end

function _M._to_217_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810008, 0)

	return true
end

function _M._to_218_0(flow)
	flow:addTimer(1, _M, "_to_219_0", flow)

	return _M._to_166_0(flow)
end

function _M._to_219_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810010, 0)

	return true
end

function _M._to_220_0(flow)
	flow:addTimer(0, _M, "_to_221_0", flow)

	return _M._to_139_0(flow)
end

function _M._to_221_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810009, 0)

	return true
end

function _M._to_222_0(flow)
	flow:addTimer(0, _M, "_to_223_0", flow)

	return _M._to_178_0(flow)
end

function _M._to_223_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 102810011, 0)

	return true
end

function _M._to_233_0(flow)
	local _0 = flow.__finishType == CTRConst.FlowFinishType.Break

	if _0 then
		flow:setActive()
		_A(flow, "StopEffectOnTarget", 0, "Eff_Env_Common_Rock_Crystal_001")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_101_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_102_1(flow)
	local _0 = _M._get_101_2(flow)

	return _C(102, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_140_1(flow)
	local _0 = _M._get_101_2(flow)

	return _C(140, "GetRouteIdFromResPoint", flow, true, _0, 4)
end

function _M._get_142_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_143_1(flow)
	local _0 = _M._get_142_2(flow)

	return _C(143, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_145_1(flow)
	local _0 = _M._get_142_2(flow)

	return _C(145, "GetRouteIdFromResPoint", flow, true, _0, 5)
end

function _M._get_148_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_149_1(flow)
	local _0 = _M._get_148_2(flow)

	return _C(149, "GetRouteIdFromResPoint", flow, true, _0, 3)
end

function _M._get_151_1(flow)
	local _0 = _M._get_148_2(flow)

	return _C(151, "GetRouteIdFromResPoint", flow, true, _0, 6)
end

function _M._get_153_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_153_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_154_1(flow)
	local _0 = _M._get_153_2(flow)

	return _C(154, "GetRouteIdFromResPoint", flow, true, _0, 7)
end

function _M._get_159_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_159_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_160_1(flow)
	local _0 = _M._get_159_2(flow)

	return _C(160, "GetRouteIdFromResPoint", flow, true, _0, 7)
end

function _M._get_163_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_163_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_164_1(flow)
	local _0 = _M._get_163_2(flow)

	return _C(164, "GetRouteIdFromResPoint", flow, true, _0, 7)
end

function _M._get_176_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_177_1(flow)
	local _0 = _M._get_176_2(flow)

	return _C(177, "GetRouteIdFromResPoint", flow, true, _0, 8)
end

function _M._get_179_1(flow)
	local _0 = _M._get_176_2(flow)

	return _C(179, "GetRouteIdFromResPoint", flow, true, _0, 11)
end

function _M._get_181_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_182_1(flow)
	local _0 = _M._get_181_2(flow)

	return _C(182, "GetRouteIdFromResPoint", flow, true, _0, 9)
end

function _M._get_184_1(flow)
	local _0 = _M._get_181_2(flow)

	return _C(184, "GetRouteIdFromResPoint", flow, true, _0, 12)
end

function _M._get_186_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_187_1(flow)
	local _0 = _M._get_186_2(flow)

	return _C(187, "GetRouteIdFromResPoint", flow, true, _0, 10)
end

function _M._get_189_1(flow)
	local _0 = _M._get_186_2(flow)

	return _C(189, "GetRouteIdFromResPoint", flow, true, _0, 13)
end

function _M._get_192_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_192_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_196_1(flow)
	local _0 = _M._get_192_2(flow)

	return _C(196, "GetRouteIdFromResPoint", flow, true, _0, 14)
end

function _M._get_200_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_200_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_202_1(flow)
	local _0 = _M._get_200_2(flow)

	return _C(202, "GetRouteIdFromResPoint", flow, true, _0, 14)
end

function _M._get_206_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_206_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_208_1(flow)
	local _0 = _M._get_206_2(flow)

	return _C(208, "GetRouteIdFromResPoint", flow, true, _0, 14)
end

return _M
