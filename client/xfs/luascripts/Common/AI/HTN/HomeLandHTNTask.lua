-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HTN\\HomeLandHTNTask.lua

local HomeLandHTNState = require("Common.AI.HTN.HomeLandHTNState")
local HomeLandHTNStateName = HomeLandHTNState.StateName
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local AiConst = require("Common.Const.AiConst")
local Const = require("Common.Const.Const")
local HomeLandHTNTask = {}

HomeLandHTNTask.PrimitiveTask = {
	Work = {
		name = "work",
		type = AiConst.HTNTaskType.Primitive,
		conditionMap = {},
		effectMap = {},
		taskFunc = function(entity, worldState)
			HomeLandUtils.allocateHomePetWork(entity, worldState[HomeLandHTNStateName.TargetOrnamentId], worldState[HomeLandHTNStateName.TargetOperId])
		end
	},
	MoveToWork = {
		name = "moveToWork",
		type = AiConst.HTNTaskType.Primitive,
		conditionMap = {},
		effectMap = {},
		taskFunc = function(entity, worldState)
			HomeLandUtils.allocateHomePetWork(entity, worldState[HomeLandHTNStateName.TargetOrnamentId], Const.HOMELAND_FACILITY_OP_TYPE.MOVING)
		end
	},
	GoToTransport = {
		name = "goToTransport",
		type = AiConst.HTNTaskType.Primitive,
		conditionMap = {},
		effectMap = {},
		taskFunc = function(entity, worldState)
			HomeLandUtils.allocateHomePetWork(entity, worldState[HomeLandHTNStateName.TargetOrnamentId], Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT)
		end
	},
	TransportToStore = {
		name = "transportToStore",
		type = AiConst.HTNTaskType.Primitive,
		conditionMap = {},
		effectMap = {},
		taskFunc = function(entity, worldState)
			HomeLandUtils.allocateHomePetWork(entity, worldState[HomeLandHTNStateName.TargetOrnamentId], Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT)
		end
	}
}
HomeLandHTNTask.CompoundTask = {
	Live = {
		name = "C_Live",
		type = AiConst.HTNTaskType.Compound,
		methodList = {
			{
				conditionMap = {
					[HomeLandHTNStateName.HasWorkTarget] = true,
					[HomeLandHTNStateName.CloseToWorkPosition] = false
				},
				subTaskList = {
					HomeLandHTNTask.PrimitiveTask.MoveToWork
				}
			},
			{
				conditionMap = {
					[HomeLandHTNStateName.HasWorkTarget] = true,
					[HomeLandHTNStateName.CloseToWorkPosition] = true
				},
				subTaskList = {
					HomeLandHTNTask.PrimitiveTask.Work
				}
			},
			{
				conditionMap = {
					[HomeLandHTNStateName.HasTransportTarget] = true,
					[HomeLandHTNStateName.CloseToTransportTarget] = false
				},
				subTaskList = {
					HomeLandHTNTask.PrimitiveTask.GoToTransport
				}
			},
			{
				conditionMap = {
					[HomeLandHTNStateName.HasTransportTarget] = true,
					[HomeLandHTNStateName.CloseToTransportTarget] = true
				},
				subTaskList = {
					HomeLandHTNTask.PrimitiveTask.TransportToStore
				}
			}
		}
	}
}

return HomeLandHTNTask
