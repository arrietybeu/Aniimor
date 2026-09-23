-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Budclaw_Macro.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_216_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 144 then
		return true
	end

	if nodeId == 193 then
		return true
	end

	if nodeId == 249 then
		return true
	end

	if nodeId == 251 then
		return true
	end

	if nodeId == 267 then
		return true
	end

	if nodeId == 269 then
		return true
	end

	if nodeId == 284 then
		return true
	end

	if nodeId == 286 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_144_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_354_4(flow)

	return _doBehaviourTail_0(flow, 144, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_192_0(flow)
	local _0 = _M._get_354_2(flow)

	if _0 then
		return _M._to_144_0(flow)
	end

	local _1 = _M._get_354_3(flow)

	if _1 then
		return _M._to_193_0(flow)
	end
end

function _M._to_193_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_354_5(flow)

	return _doBehaviourTail_0(flow, 193, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_216_0(flow)
	local _2 = _C(204, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _3 = _C(201, "SelectOneByRandom", flow, _2)
	local _1 = _C(206, "GetDistance", flow, 0, _3, false)
	local _0 = _1 <= 4.8

	if _0 then
		return _M._to_217_0(flow)
	end
end

function _M._to_217_0(flow)
	local _0 = _M._get_349_1(flow)

	if _0 then
		return _M._to_250_0(flow)
	end

	local _1 = _M._get_350_1(flow)

	if _1 then
		return _M._to_192_0(flow)
	end

	local _2 = _M._get_351_1(flow)

	if _2 then
		return _M._to_268_0(flow)
	end

	local _3 = _M._get_352_1(flow)

	if _3 then
		return _M._to_285_0(flow)
	end
end

function _M._to_249_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_353_5(flow)

	return _doBehaviourTail_0(flow, 249, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_250_0(flow)
	local _0 = _M._get_353_2(flow)

	if _0 then
		return _M._to_251_0(flow)
	end

	local _1 = _M._get_353_3(flow)

	if _1 then
		return _M._to_249_0(flow)
	end
end

function _M._to_251_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_353_4(flow)

	return _doBehaviourTail_0(flow, 251, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_267_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_355_5(flow)

	return _doBehaviourTail_0(flow, 267, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_268_0(flow)
	local _0 = _M._get_355_2(flow)

	if _0 then
		return _M._to_269_0(flow)
	end

	local _1 = _M._get_355_3(flow)

	if _1 then
		return _M._to_267_0(flow)
	end
end

function _M._to_269_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_355_4(flow)

	return _doBehaviourTail_0(flow, 269, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_284_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_356_5(flow)

	return _doBehaviourTail_0(flow, 284, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_285_0(flow)
	local _0 = _M._get_356_2(flow)

	if _0 then
		return _M._to_286_0(flow)
	end

	local _1 = _M._get_356_3(flow)

	if _1 then
		return _M._to_284_0(flow)
	end
end

function _M._to_286_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_356_4(flow)

	return _doBehaviourTail_0(flow, 286, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._get_349_1(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Check_Dis")

	_0:setContextValue("entityTag", "TE_Env_CE_Budclaw_A")

	local _1 = _0:getMacroValue("result")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_350_1(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Check_Dis")

	_0:setContextValue("entityTag", "TE_Env_CE_Budclaw_B")

	local _1 = _0:getMacroValue("result")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_351_1(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Check_Dis")

	_0:setContextValue("entityTag", "TE_Env_CE_Budclaw_C")

	local _1 = _0:getMacroValue("result")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_352_1(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Check_Dis")

	_0:setContextValue("entityTag", "TE_Env_CE_Budclaw_D")

	local _1 = _0:getMacroValue("result")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_353_3(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_D")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_B")

	local _1 = _0:getMacroValue("result2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_353_4(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_D")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_B")

	local _1 = _0:getMacroValue("entity1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_353_2(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_D")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_B")

	local _1 = _0:getMacroValue("result1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_353_5(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_D")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_B")

	local _1 = _0:getMacroValue("entity2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_354_3(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_A")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_C")

	local _1 = _0:getMacroValue("result2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_354_4(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_A")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_C")

	local _1 = _0:getMacroValue("entity1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_354_5(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_A")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_C")

	local _1 = _0:getMacroValue("entity2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_354_2(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_A")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_C")

	local _1 = _0:getMacroValue("result1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_355_4(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_B")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_D")

	local _1 = _0:getMacroValue("entity1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_355_3(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_B")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_D")

	local _1 = _0:getMacroValue("result2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_355_2(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_B")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_D")

	local _1 = _0:getMacroValue("result1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_355_5(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_B")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_D")

	local _1 = _0:getMacroValue("entity2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_356_3(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_C")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_A")

	local _1 = _0:getMacroValue("result2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_356_5(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_C")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_A")

	local _1 = _0:getMacroValue("entity2")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_356_2(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_C")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_A")

	local _1 = _0:getMacroValue("result1")

	flow:clearSubMacro(_0)

	return _1
end

function _M._get_356_4(flow)
	local _0 = flow:getSubMacro("BCM_Budclaw_Select_Target")

	_0:setContextValue("entityTag1", "TE_Env_CE_Budclaw_C")
	_0:setContextValue("entityTag2", "TE_Env_CE_Budclaw_A")

	local _1 = _0:getMacroValue("entity1")

	flow:clearSubMacro(_0)

	return _1
end

return _M
