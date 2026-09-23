-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72275265.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 72275265,
	nodes = {
		[0] = {
			kind = 6,
			flowIn = {
				End = true
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
			kind = 34,
			inputs = {
				staticIdVInput = 72275263
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
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
				moveTypeVInput = 2,
				staticIdVInput = 72275263
			},
			valueIn = {
				targetEulerAngleVInput = {
					nodeId = 4,
					portId = "OutEulerAngle"
				},
				targetPositionVInput = {
					nodeId = 4,
					portId = "OutPosition"
				}
			},
			flowIn = {
				In = true
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
			kind = 43,
			inputs = {
				slotIDVInput = 72275274,
				sceneIDVinput = 412,
				dialogsetIDVInput = 72275272
			}
		}
	}
}
