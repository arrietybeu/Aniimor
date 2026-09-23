-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_SpEnterCombat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tSensorTgtId", value0)
	agent:addSubTreeLocalParam("tRandomWaitTime", value1)
	agent:addSubTreeLocalParam("tShowExclamation", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnNearByEntityTrapped" then
		return _M._to_278_0(flow)
	end

	if eventName == "SensedMsgTrigger" then
		return _M._to_274_0(flow)
	end
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_AddSelfHate" then
		return _M._to_283_0(flow)
	end

	if eventName == "Msg_Full_ToBrother" then
		return _M._to_276_0(flow)
	end

	if eventName == "VisionValue_Full" then
		return _M._to_270_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 153 then
		return true
	end

	if nodeId == 166 then
		return true
	end

	if nodeId == 172 then
		return true
	end

	if nodeId == 211 then
		return true
	end

	if nodeId == 261 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_153_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_180_1(flow)
	local _1 = _M._get_266_2(flow)

	return _doBehaviourTail_0(flow, 153, _0, _1, true)
end

function _M._to_166_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_182_1(flow)
	local _1 = _M._get_267_2(flow)

	return _doBehaviourTail_0(flow, 166, _0, _1, true)
end

function _M._to_172_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_179_2(flow)

	if _0 then
		flow:setActive()
		_C(172, "DoBehaviour", flow, "PBT_ReadyToFight")

		local _1 = _M._get_152_1(flow)
		local _2 = _M._get_170_2(flow)

		return _doBehaviourTail_0(flow, 172, _1, _2, true)
	else
		flow:setActiveFail()
	end
end

function _M._to_211_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_213_1(flow)

	return _doBehaviourTail_0(flow, 211, _0, 0, false)
end

function _M._to_261_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_213_1(flow)

	return _doBehaviourTail_0(flow, 261, _0, 0, false)
end

function _M._to_270_0(flow)
	local _0 = _M._get_235_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(271, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1003)

		return _M._to_261_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_274_0(flow)
	local _0 = _M._get_235_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(273, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1003)

		return _M._to_211_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_276_0(flow)
	local _3 = _C(191, "GetSelfId", flow)
	local _2 = _C(194, "GetPuppetData", flow, _3, "babySensedBrotherEnterCombatType", true, -1)
	local _0 = _2 == 0

	if _0 then
		flow:setActive()

		local _1 = _C(275, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1003)

		return _M._to_153_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_278_0(flow)
	local _0 = _M._get_199_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(277, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1003)

		return _M._to_166_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_282_0(flow)
	local _0 = _M._get_290_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1003)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_283_0(flow)
	flow:addTimer(0, _M, "_to_282_0", flow)

	return _M._to_172_0(flow)
end

function _M._get_152_1(flow)
	local _0 = _C(151, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(152, "SelectOneByRandom", flow, _0)
end

function _M._get_167_3(flow)
	local _3 = _C(157, "GetSelfId", flow)
	local _4 = _C(158, "GetPuppetData", flow, _3, "ethnicGroup", true, 0)
	local _5 = _M._get_168_1(flow)
	local _6 = _C(155, "GetPuppetData", flow, _5, "ethnicGroup", true, 0)
	local _0 = _4 == _6

	if not _0 then
		return false
	end

	local _7 = _C(165, "GetSelfId", flow)
	local _8 = _C(160, "GetPuppetData", flow, _7, "stage", true, 0)
	local _1 = _8 > 1

	if not _1 then
		return false
	end

	local _9 = _M._get_168_1(flow)
	local _10 = _C(154, "GetPuppetData", flow, _9, "stage", true, 0)
	local _2 = _10 == 1

	if not _2 then
		return false
	end

	return true
end

function _M._get_168_1(flow)
	return flow:getContextValue("targetActorId")
end

function _M._get_170_2(flow)
	local _0 = _C(169, "RandomInteger", flow, 2, 6)

	return 0.05 * _0
end

function _M._get_179_2(flow)
	local _1 = _C(175, "GetSelfId", flow)
	local _0 = _C(174, "GetPuppetData", flow, _1, "partnerEnterCombatType", true, -1)

	return _0 == 0
end

function _M._get_180_1(flow)
	local _0 = _C(181, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(180, "SelectOneByRandom", flow, _0)
end

function _M._get_182_1(flow)
	local _0 = _C(183, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(182, "SelectOneByRandom", flow, _0)
end

function _M._get_199_3(flow)
	if false then
		return false
	end

	local _3 = _C(200, "GetSelfId", flow)
	local _2 = _C(201, "GetPuppetData", flow, _3, "babyCatchedBrotherEnterCombatType", true, -1)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _1 = _M._get_167_3(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_208_2(flow)
	if false then
		return false
	end

	local _2 = _C(209, "GetSelfId", flow)
	local _1 = _C(210, "GetPuppetData", flow, _2, "brotherSensedEnterCombatType", true, -1)
	local _0 = _1 == 0

	if not _0 then
		return false
	end

	return true
end

function _M._get_213_1(flow)
	local _0 = _C(212, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_214_0(flow)
	return _C(214, "GetSelfId", flow)
end

function _M._get_219_3(flow)
	local _7 = _M._get_222_2(flow)
	local _8 = _M._get_214_0(flow)
	local _9 = _C(220, "GetPuppetData", flow, _8, "ethnicGroup", true, 0)
	local _0 = _C(221, "IsEthnicGroup", flow, _7, _9)

	if not _0 then
		return false
	end

	local _5 = _M._get_222_2(flow)
	local _6 = _M._get_214_0(flow)
	local _3 = _C(218, "GetDistance", flow, _5, _6, false)
	local _10 = _M._get_214_0(flow)
	local _4 = _C(226, "GetPuppetData", flow, _10, "partnerEnterCombatDis", true, 0)
	local _1 = _3 <= _4

	if not _1 then
		return false
	end

	local _11 = _M._get_222_2(flow)
	local _12 = _C(224, "GetPuppetData", flow, _11, "stage", true, 0)
	local _2 = _12 <= 1

	if not _2 then
		return false
	end

	return true
end

function _M._get_222_2(flow)
	return flow:getCache(222, "__iterItem")
end

function _M._get_222_3(flow)
	local _0 = _C(223, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(222, "__iterItem", v)

		if _M._get_219_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_235_3(flow)
	local _0 = _M._get_208_2(flow)

	if not _0 then
		return false
	end

	local _3 = _M._get_222_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	local _5 = _M._get_214_0(flow)
	local _6 = _C(227, "GetPuppetData", flow, _5, "stage", true, 0)
	local _2 = _6 >= 2

	if not _2 then
		return false
	end

	return true
end

function _M._get_266_2(flow)
	local _0 = _C(265, "RandomInteger", flow, 2, 6)

	return 0.05 * _0
end

function _M._get_267_2(flow)
	local _0 = _C(268, "RandomInteger", flow, 2, 6)

	return 0.05 * _0
end

function _M._get_290_2(flow)
	local _2 = _C(285, "GetSelfId", flow)
	local _3 = _C(284, "GetPuppetData", flow, _2, "stage", true, 0)
	local _0 = _3 > 1

	if not _0 then
		return false
	end

	local _4 = flow:getContextValue("sourceActorId")
	local _5 = _C(286, "GetPuppetData", flow, _4, "stage", true, 0)
	local _1 = _5 <= 1

	if not _1 then
		return false
	end

	return true
end

return _M
