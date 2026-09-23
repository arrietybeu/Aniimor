-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_MiserBro_Konoe.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_127_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 129 then
		return true
	end

	if nodeId == 157 then
		return true
	end

	if nodeId == 179 then
		return _M._to_157_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_127_0(flow)
	local _0 = _M._get_124_2(flow)

	if _0 then
		return _M._to_130_0(flow)
	end
end

function _M._to_129_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_119_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(129)

	return true
end

function _M._to_130_0(flow)
	local _0 = _M._get_195_3(flow)

	if _0 then
		return _M._to_179_0(flow)
	end

	local _2 = _M._get_195_3(flow)
	local _1 = not _2

	if _1 then
		return _M._to_129_0(flow)
	end
end

function _M._to_157_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_139_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12010110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(157)

	return true
end

function _M._to_179_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 0.6)
	flow:setContinue(179)

	return true
end

function _M._get_119_1(flow)
	local _0 = _M._get_125_0(flow)

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

function _M._get_124_2(flow)
	local _3 = _M._get_125_0(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _5 = _M._get_119_1(flow)
	local _2 = _C(123, "GetPerceptibilityValue", flow, _5)
	local _1 = _2 >= 100

	if not _1 then
		return false
	end

	return true
end

function _M._get_125_0(flow)
	return _C(125, "GetPerceptibilityTable", flow)
end

function _M._get_135_2(flow)
	local _2 = _M._get_138_2(flow)
	local _0 = _C(137, "HasEntityTag", flow, _2, "TE_Chest_Metal")

	if not _0 then
		return false
	end

	local _3 = _M._get_138_2(flow)
	local _4 = _C(140, "GetDistance", flow, _3, 0, true)
	local _1 = _4 < 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_136_3(flow)
	local _0 = flow:getCache(139, "__iterItem")

	return _C(136, "GetDistance", flow, _0, 0, false)
end

function _M._get_138_3(flow)
	local _0 = _C(142, "GetAoiEntityTableByLevel", flow, 0, 50, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(138, "__iterItem", v)

		if _M._get_135_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_138_2(flow)
	return flow:getCache(138, "__iterItem")
end

function _M._get_139_2(flow)
	local _0 = _M._get_138_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(139, "__iterItem", v)

		_1 = _M._get_136_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_183_3(flow)
	local _0 = _C(184, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(183, "__iterItem", v)

		if _M._get_186_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_183_2(flow)
	return flow:getCache(183, "__iterItem")
end

function _M._get_185_3(flow)
	local _0 = flow:getCache(190, "__iterItem")

	return _C(185, "GetDistance", flow, _0, 0, false)
end

function _M._get_186_2(flow)
	local _0 = _M._get_183_2(flow)

	return _C(186, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_B")
end

function _M._get_188_2(flow)
	local _0 = _M._get_189_2(flow)

	return _C(188, "HasEntityTag", flow, _0, "TE_Chest_Metal")
end

function _M._get_189_3(flow)
	local _0 = _C(192, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(189, "__iterItem", v)

		if _M._get_188_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_189_2(flow)
	return flow:getCache(189, "__iterItem")
end

function _M._get_190_2(flow)
	local _0 = _M._get_189_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(190, "__iterItem", v)

		_1 = _M._get_185_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_194_2(flow)
	local _0 = _M._get_183_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(194, "__iterItem", v)

		_1 = _M._get_196_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_195_3(flow)
	local _8 = _M._get_189_3(flow)
	local _9 = not _8 or next(_8) == nil
	local _0 = not _9

	if not _0 then
		return false
	end

	local _6 = _M._get_183_3(flow)
	local _7 = not _6 or next(_6) == nil
	local _1 = not _7

	if not _1 then
		return false
	end

	local _4 = _M._get_190_2(flow)
	local _5 = _M._get_194_2(flow)
	local _3 = _C(191, "GetDistance", flow, _4, _5, false)
	local _2 = _3 < 3

	if not _2 then
		return false
	end

	return true
end

function _M._get_196_3(flow)
	local _0 = flow:getCache(194, "__iterItem")

	return _C(196, "GetDistance", flow, _0, 0, false)
end

return _M
