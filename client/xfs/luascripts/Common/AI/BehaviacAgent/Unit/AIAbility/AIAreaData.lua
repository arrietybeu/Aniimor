-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIAreaData.lua

local AIAreaData = {
	PetFollowSpeedUpArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "SpeedUp",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 20,
				maxDist = 4.5,
				minDist = 2
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -20,
				maxDist = 4.5,
				minDist = 2
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	PetFollowSlowDownArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "SlowDown",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 20,
				maxDist = 4.5,
				minDist = 0.5
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -20,
				maxDist = 4.5,
				minDist = 0.5
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	PetFollowCameraNormalArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "FaceCameraSameMove",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 30,
				maxDist = 4.5,
				minDist = 0.5
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -30,
				maxDist = 4.5,
				minDist = 0.5
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	PetFollowCameraChangeSpeedArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "FaceCameraChangeSpeedMove",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 30,
				maxDist = 4.5,
				minDist = 2
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -30,
				maxDist = 4.5,
				minDist = 2
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	PetFollowNormalArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "Normal",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 20,
				maxDist = 4.5,
				minDist = 0.5
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -20,
				maxDist = 4.5,
				minDist = 0.5
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	PetFollowMoveAwayArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "MoveAway",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 20,
				maxDist = 4,
				minDist = 1.5
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -20,
				maxDist = 4,
				minDist = 1.5
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	},
	NPCFollowNormalArea = {
		areaSelectStrategyType = "FollowSelect",
		movementStrategyType = "Normal",
		areaDataList = {
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = 50,
				maxDist = 2.5,
				minDist = 1
			},
			{
				simpleNum = 4,
				areaDataType = "RelativeFocusPos",
				targetAngle = -50,
				maxDist = 2.5,
				minDist = 1
			}
		},
		backupPosDataList = {
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = 0,
				maxDist = 1.5,
				minDist = 0.5
			},
			{
				simpleNum = 1,
				areaDataType = "RelativeFocusPos",
				targetAngle = -180,
				maxDist = 1.5,
				minDist = 0.5
			}
		}
	}
}

return AIAreaData
