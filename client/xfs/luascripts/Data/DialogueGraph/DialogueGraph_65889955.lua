-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_65889955.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 65889955,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 70004005
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 4,
					portId = "EntityID"
				}
			},
			fields = {
				npcStaticId = -1,
				npcId = 401026,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Behav_Happy",
				skipTime = 0,
				portCount = 1,
				animCfg = {
					[1] = "Behav_Happy",
					[2] = {
						[1] = false,
						[2] = 10
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		[4] = {
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
		}
	},
	blackboard = {
		isFound = false,
		staticID = 0
	}
}
