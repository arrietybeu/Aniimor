-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_75194062.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 75194062,
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
						nodeId = 4
					}
				},
				["1"] = {
					{
						portId = "Play",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "BGM_ARK_01"
			},
			flowIn = {
				Stop = 1,
				Play = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 5702010
			},
			fields = {
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "End",
						nodeId = 0
					}
				},
				ShowFinOut = {
					{
						portId = "Stop",
						nodeId = 3
					}
				}
			}
		}
	}
}
