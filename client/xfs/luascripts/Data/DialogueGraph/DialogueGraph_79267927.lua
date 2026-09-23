-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79267927.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 79267927,
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
			kind = 18,
			inputs = {
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				enhanceAmbientIntensityVInput = true,
				clearEventInputVInput = true
			},
			fields = {
				topLogoComs = {
					quest = true,
					photo = true,
					vlog = true,
					teamSpeech = true,
					petFertility = true,
					petChat = true,
					petExchange = true,
					multiPlayer = true,
					callFriends = true,
					alert = true,
					combat = true
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 38
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		}
	}
}
