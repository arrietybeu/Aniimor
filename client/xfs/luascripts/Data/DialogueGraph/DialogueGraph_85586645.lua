-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_85586645.lua

return {
	startNodeId = 1,
	dialogueId = 85586645,
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
						portId = "Play"
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "SFX_ACT_10431Rhythm_Jump"
			},
			valueIn = {
				audioTransformVInput = {
					nodeId = 4,
					portId = "BoneTransform"
				}
			},
			flowIn = {
				Play = 0
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
			kind = 5,
			inputs = {
				playableStateVInput = "JumpSpray"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 4,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 0.75,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 401056
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 86116438
			},
			fields = {
				entityType = 2
			}
		}
	}
}
