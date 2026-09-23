-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_52087526.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 52087526,
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
			kind = 5,
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "Value"
				}
			},
			fields = {
				templateId = 0,
				processingTime = 0,
				playAniType = 2,
				isLooping = false,
				entityType = 0
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
			kind = 19,
			inputs = {
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 8,
					portId = "Value"
				},
				targetPositionVInput = {
					nodeId = 10,
					portId = "OutPosition"
				}
			},
			fields = {
				reset = false,
				finishToSteer = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							weightedMode = 0,
							value = 0
						},
						{
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							weightedMode = 0,
							value = 1
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
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			valueIn = {
				entityIdVInput = {
					nodeId = 8,
					portId = "Value"
				}
			},
			fields = {
				templateId = 0,
				processingTime = 0,
				playAniType = 2,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "Value"
				}
			},
			fields = {
				templateId = 0,
				processingTime = 0,
				playAniType = 2,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		[10] = {
			kind = 43,
			valueIn = {
				dialogsetIDVInput = {
					nodeId = 11,
					portId = "Value"
				},
				sceneIDVinput = {
					nodeId = 9,
					portId = "Value"
				},
				slotIDVInput = {
					nodeId = 12,
					portId = "Value"
				}
			}
		}
	},
	blackboard = {
		DialogSetID = 0,
		BestuckSlotID = 0,
		BestuckID = 0,
		AskhelpID = 0
	}
}
