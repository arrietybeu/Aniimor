-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_70832768.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 70832768,
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
						portId = "In",
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 34,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 4
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 100240101
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 5
				}
			},
			fields = {
				anim = "Behav_Angry",
				duration = 2,
				chatType = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		[5] = {
			kind = 17,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 4
				}
			},
			fields = {
				entityType = 2
			}
		}
	},
	blackboard = {
		StaticID = 0
	}
}
