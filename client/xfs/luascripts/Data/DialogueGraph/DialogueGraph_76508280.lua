-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_76508280.lua

return {
	dialogueId = 76508280,
	schema = 1,
	startNodeId = 1,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 0
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 8,
			flowOut = {
				Start = {
					{
						portId = "In",
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 3
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 61,
			inputs = {
				abilityIdVInput = 1300080
			},
			valueIn = {
				castEntityIdVInput = {
					portId = "EntityID",
					nodeId = 10
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "Stop",
						nodeId = 4
					}
				},
				["1"] = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 76407431,
				targetEulerAngleVInput = {
					0,
					262.596,
					0
				},
				targetPositionVInput = {
					-470.52,
					61.951,
					830.646
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 10
				}
			},
			fields = {
				setRotation = false,
				setPosition = true,
				reset = true
			},
			flowIn = {
				In = 0
			}
		},
		[10] = {
			kind = 9,
			inputs = {
				staticIdVInput = 74638841
			},
			fields = {
				entityType = 1
			}
		}
	}
}
