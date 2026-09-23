-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_45244285.lua

return {
	schema = 1,
	startNodeId = 68,
	dialogueId = 45244285,
	nodes = {
		[68] = {
			kind = 8,
			flowOut = {
				Start = {
					{
						nodeId = 69,
						portId = "In"
					}
				}
			}
		},
		[69] = {
			kind = 45,
			inputs = {
				timelineResIdVInput = "$P_TL_.prefab"
			},
			flowIn = {
				In = 0
			}
		}
	},
	blackboard = {
		A = 1,
		choice2 = 0,
		choice1 = 0,
		B = 2
	}
}
