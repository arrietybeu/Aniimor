-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIStartAppointedAreaData.lua

local AIStartAreaData = {
	PetStartArea = {
		relativeList = {
			1,
			2,
			2,
			2,
			2,
			2,
			5
		},
		areaDataList = {
			{
				funcName = "ignoreCharacterStateList",
				params = {
					"AIRING",
					"CLIMBING",
					"GLIDING",
					"SWIMMING",
					"MOUNT"
				}
			},
			{
				funcName = "targetSpeedCompare",
				params = {
					0.5,
					100
				}
			},
			{
				funcName = "me2TargetDegreeAbs",
				params = {
					150,
					999
				}
			},
			{
				funcName = "me2TargetDistance2d",
				params = {
					4.5,
					9999
				}
			},
			{
				funcName = "me2TargetDistance2d",
				params = {
					0,
					0.5
				}
			},
			{
				funcName = "me2TargetHeightDistance",
				params = {
					3,
					9999
				}
			},
			{
				funcName = "targetEntPropertyCheck",
				params = {
					"canBeFollowed",
					true
				}
			}
		}
	},
	NPCNoviceStartArea = {
		relativeList = {
			1,
			2,
			2,
			2,
			2,
			2,
			5
		},
		areaDataList = {
			{
				funcName = "ignoreCharacterStateList",
				params = {
					"AIRING",
					"CLIMBING",
					"GLIDING",
					"SWIMMING",
					"MOUNT"
				}
			},
			{
				funcName = "targetSpeedCompare",
				params = {
					0.5,
					100
				}
			},
			{
				funcName = "me2TargetDegreeAbs",
				params = {
					150,
					999
				}
			},
			{
				funcName = "me2TargetDistance2d",
				params = {
					2,
					9999
				}
			},
			{
				funcName = "me2TargetDistance2d",
				params = {
					0,
					0.5
				}
			},
			{
				funcName = "me2TargetHeightDistance",
				params = {
					3,
					9999
				}
			},
			{
				funcName = "targetEntPropertyCheck",
				params = {
					"canBeFollowed",
					true
				}
			}
		}
	},
	PetCanFollowArea = {
		relativeList = {
			1,
			2
		},
		areaDataList = {
			{
				funcName = "targetEntPropertyCheck",
				params = {
					"canBeFollowed",
					true
				}
			},
			{
				funcName = "ignoreCharacterStateList",
				params = {
					"AIRING",
					"CLIMBING",
					"GLIDING",
					"SWIMMING",
					"MOUNT"
				}
			}
		}
	}
}

return AIStartAreaData
