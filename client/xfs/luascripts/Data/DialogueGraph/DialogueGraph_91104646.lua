-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91104646.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91104646,
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
			kind = 11,
			fields = {
				modeInfo = {
					disableSpaceFollow = true,
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					modeType = 2,
					enhanceAmbientIntensity = true,
					hideAllUI = false,
					showHud = true,
					blockCameraZoom = true,
					hideTopLogo = false,
					hideMarkShare = true,
					hideInteractionSign = false,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true
				}
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
			kind = 32,
			fields = {
				eventName = "openUISuper",
				eventParam = {
					[1] = 89,
					[2] = {
						{
							[1] = "templateId",
							[2] = 1005100
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 40,
			inputs = {
				guideIdVInput = 1000
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
		}
	}
}
