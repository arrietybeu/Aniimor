-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_52159976.lua

return {
	startNodeId = 1,
	dialogueId = 52159976,
	schema = 1,
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
			kind = 4,
			fields = {
				delayTime = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				},
				targetPositionVInput = {
					nodeId = 5,
					portId = "OutPosition"
				}
			},
			fields = {
				finishToSteer = false,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0,
							time = 0,
							outWeight = 0
						},
						{
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							weightedMode = 0,
							time = 1,
							outWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
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
				variableName = "SceneID"
			}
		},
		{
			kind = 43,
			valueIn = {
				dialogsetIDVInput = {
					nodeId = 6,
					portId = "Value"
				},
				sceneIDVinput = {
					nodeId = 4,
					portId = "Value"
				},
				slotIDVInput = {
					nodeId = 7,
					portId = "Value"
				}
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "DialogSetID"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "SlotID"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "StaticID"
			}
		},
		{
			kind = 9,
			valueIn = {
				staticIdVInput = {
					nodeId = 8,
					portId = "Value"
				}
			},
			fields = {
				entityType = 2
			}
		}
	},
	blackboard = {
		StaticID = 0,
		SlotID = 0,
		DialogSetID = 0,
		SceneID = 3000
	}
}
