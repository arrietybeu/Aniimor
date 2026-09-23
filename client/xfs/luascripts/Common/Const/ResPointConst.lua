-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\ResPointConst.lua

local ResPointConst = {}

ResPointConst.PointType = {
	Dynamic = 1,
	Static = 0,
	Formation = 2
}
ResPointConst.DirRefType = {
	PointForward = 1,
	NoLimit = 0,
	EntToPort = 4,
	WorldNorth = 3,
	PortToPoint = 2
}
ResPointConst.DirDescType = {
	Range = 1,
	FixAngle = 0
}
ResPointConst.FollowRotateType = {
	All = 0,
	FormationFollow = 10,
	OnlyYaw = 2,
	None = 1
}
ResPointConst.PortInteractState = {
	Join = 1,
	PreJoin = 0
}
ResPointConst.DefaultDirDescConfig = {
	dirInteractMaxNum = -1,
	towardsYawType = 0,
	limitYawRangeType = 0
}
ResPointConst.DefaultPortConfig = {
	interactMaxNum = -1,
	interactMaxHeight = -1,
	interactDist = -1,
	bodySize = 0,
	interactDirDescs = {
		ResPointConst.DefaultDirDescConfig
	},
	portPosition = {
		0,
		0,
		0
	}
}
ResPointConst.ActiveType = {
	None = 1,
	PlayerRange = 0
}
ResPointConst.ActiveRange = {
	[0] = 30,
	50,
	70,
	100
}
ResPointConst.SearchFailReason = {
	HEIGHT_EXCEED = 2,
	CAN_NOT_BE_SEARCH = 1,
	NONE = 0,
	PORT_TAG_NOT_MATCH = 6,
	PORT_FULL = 5,
	POINT_TAG_NOT_MATCH = 4,
	RANGE_EXCEED = 3
}
ResPointConst.InactiveRangeDelta = 5
ResPointConst.DynamicPointRepathCd = 0.7
ResPointConst.DefaultInteractCheckSqrDist = 1
ResPointConst.StaticPointIndex = 1
ResPointConst.FormationPointIndex = 2
ResPointConst.OpenLog = false
ResPointConst.DebugLogEntActorId = 0
ResPointConst.OpenDebugDraw = false
ResPointConst.DebugDrawRate = 0.2
ResPointConst.DebugDrawEntActorId = 0
ResPointConst.FormationRotationLerpParam = 0.1
ResPointConst.FormationSpeedPropParam = 1.1
ResPointConst.FormationSpeedInteParam = 0.015
ResPointConst.FormationSpeedInteRelativeDist = 0.8
ResPointConst.FormationSpeedInteMax = 100
ResPointConst.FormationSpeedDiffParam = 0.01
ResPointConst.FormationSpeedRateTypeTolerance = 0.6
ResPointConst.FormationMaxSprintSpeedRatio = 1.3
ResPointConst.FormationConfig = {
	{
		num = 4,
		posArrays = {
			{
				{
					0,
					0,
					-1.2
				}
			},
			{
				{
					0,
					0,
					-1.2
				},
				{
					0,
					0,
					-2.4
				}
			},
			{
				{
					0,
					0,
					-1.2
				},
				{
					0,
					0,
					-2.4
				},
				{
					0,
					0,
					-3.6
				}
			},
			{
				{
					0,
					0,
					-1.2
				},
				{
					0,
					0,
					-2.4
				},
				{
					0,
					0,
					-3.6
				},
				{
					0,
					0,
					-4.8
				}
			}
		}
	},
	{
		num = 4,
		posArrays = {
			{
				{
					0,
					0,
					-1.2
				}
			},
			{
				{
					-0.6,
					0,
					-1.2
				},
				{
					0.6,
					0,
					-1.2
				}
			},
			{
				{
					-1.2,
					0,
					-1.2
				},
				{
					0,
					0,
					-1.2
				},
				{
					1.2,
					0,
					-1.2
				}
			},
			{
				{
					-1.8,
					0,
					-1.2
				},
				{
					-0.6,
					0,
					-1.2
				},
				{
					0.6,
					0,
					-1.2
				},
				{
					1.8,
					0,
					-1.2
				}
			}
		}
	},
	{
		num = 4,
		posArrays = {
			{
				{
					0,
					0,
					-1.6
				}
			},
			{
				{
					0,
					0,
					-1.6
				},
				{
					0,
					0,
					-3.2
				}
			},
			{
				{
					0,
					0,
					-1.6
				},
				{
					0,
					0,
					-3.2
				},
				{
					0,
					0,
					-4.8
				}
			},
			{
				{
					0,
					0,
					-1.6
				},
				{
					0,
					0,
					-3.2
				},
				{
					0,
					0,
					-4.8
				},
				{
					0,
					0,
					-6.4
				}
			}
		}
	},
	{
		num = 4,
		posArrays = {
			{
				{
					0,
					0,
					-1.6
				}
			},
			{
				{
					-0.8,
					0,
					-1.6
				},
				{
					0.8,
					0,
					-1.6
				}
			},
			{
				{
					-1.6,
					0,
					-1.6
				},
				{
					0,
					0,
					-1.6
				},
				{
					1.6,
					0,
					-1.6
				}
			},
			{
				{
					-2.4,
					0,
					-1.6
				},
				{
					-0.8,
					0,
					-1.6
				},
				{
					0.8,
					0,
					-1.6
				},
				{
					2.4,
					0,
					-1.6
				}
			}
		}
	}
}

return ResPointConst
