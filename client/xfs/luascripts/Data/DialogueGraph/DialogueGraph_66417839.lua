-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_66417839.lua

return {
	schema = 1,
	startNodeId = 2,
	dialogueId = 66417839,
	nodes = {
		[2] = {
			kind = 8,
			flowOut = {
				Start = {
					{
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		[3] = {
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 20,
					portId = "EntityID"
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 0,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0
			},
			flowIn = {
				In = 0
			}
		},
		[20] = {
			kind = 9,
			inputs = {
				staticIdVInput = 66416680
			},
			fields = {
				entityType = 2
			}
		}
	}
}
