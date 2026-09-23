-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_73500619.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 73500619,
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
			kind = 19,
			inputs = {
				staticIdVInput = 72084386,
				speedVInput = 1.25,
				moveTypeVInput = 2,
				targetEulerAngleVInput = {
					0,
					44.6,
					0
				},
				targetPositionVInput = {
					-1752.252,
					94.47,
					639.532
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							value = 0,
							inWeight = 0,
							weightedMode = 0,
							time = 0,
							inTangent = 0,
							outTangent = 1,
							outWeight = 0
						},
						{
							value = 1,
							inWeight = 0,
							weightedMode = 0,
							time = 1,
							inTangent = 1,
							outTangent = 0,
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		}
	}
}
