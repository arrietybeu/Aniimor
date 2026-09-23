-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_55088129.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 55088129,
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
						nodeId = 2,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			valueIn = {
				entityIdVInput = {
					nodeId = 4,
					portId = "EntityID"
				},
				targetEulerAngleVInput = {
					nodeId = 6,
					portId = "Value"
				},
				targetPositionVInput = {
					nodeId = 5,
					portId = "Value"
				}
			},
			fields = {
				setRotation = false,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "StaticId"
			}
		},
		{
			kind = 9,
			valueIn = {
				staticIdVInput = {
					nodeId = 3,
					portId = "Value"
				}
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "Pos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "Dir"
			}
		}
	},
	blackboard = {
		StaticId = 0,
		Dir = {
			0,
			0,
			0
		},
		Pos = {
			0,
			0,
			0
		}
	}
}
