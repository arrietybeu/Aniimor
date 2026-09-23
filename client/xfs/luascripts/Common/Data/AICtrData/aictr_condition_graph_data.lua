-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\aictr_condition_graph_data.lua

local data = {
	BCM_Budclaw_Check_Dis = {
		inPorts = {
			entityTag = ""
		},
		outPorts = {
			result = false
		}
	},
	BCM_Budclaw_Select_Target = {
		inPorts = {
			entityTag2 = "",
			entityTag1 = ""
		},
		outPorts = {
			result2 = false,
			result1 = false,
			entity2 = 0,
			entity1 = 0
		}
	},
	BCM_Common_CheckPER = {
		inPorts = {
			tActorId = 0
		},
		outPorts = {
			tIsPlayerInterrupt = false,
			tIsPlayer = false,
			tPetNotCurrPet = false,
			tIsPuppet = false
		}
	},
	BCM_Common_CheckVisionNormal = {
		inPorts = {
			targetActorId = 0
		},
		outPorts = {
			result = false
		}
	},
	BCM_Npc_GetRunningStatus = {
		inPorts = {
			staticId = 0,
			behavName = "",
			status = 1
		},
		outPorts = {
			resList = {}
		}
	},
	BCM_SelectEnvObjinDisbyEntityTag = {
		inPorts = {
			TargetId = 0,
			EntityTag = "",
			Distance = 0
		},
		outPorts = {
			HasEntity = false,
			Actorid = 0
		}
	}
}

return data
