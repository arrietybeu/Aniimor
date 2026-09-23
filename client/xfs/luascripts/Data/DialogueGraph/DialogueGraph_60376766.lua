-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_60376766.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 60376766,
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
			kind = 2,
			fields = {
				portCount = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 3,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				targetEulerAngleVInput = {
					0,
					180,
					0
				},
				targetPositionVInput = {
					-375.47,
					0.93,
					-7.06
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 29,
					portId = "EntityID"
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							value = 0,
							inTangent = 0,
							weightedMode = 0,
							time = 0,
							outWeight = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							value = 1,
							inTangent = 1,
							weightedMode = 0,
							time = 1,
							outWeight = 0,
							inWeight = 0
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
						portId = "0"
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 2,
				maxAwaitTime = -1
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
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
			kind = 2,
			fields = {
				portCount = 9
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 10,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 22,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 30,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 33,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 34,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
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
				},
				Out = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70002703
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 35,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 38,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 39,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 41,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 14,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 44,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 15,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 45,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 46,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 49,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 50,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 51,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 54,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 55,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 59,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 60,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 64,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial02"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 65,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1021100,
				processingTime = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				targetEulerAngleVInput = {
					0,
					327.02,
					0
				},
				targetPositionVInput = {
					-374.21,
					0.05,
					-9.17
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 40,
					portId = "EntityID"
				}
			},
			fields = {
				reset = true,
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							value = 0,
							inTangent = 0,
							weightedMode = 0,
							time = 0,
							outWeight = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							value = 1,
							inTangent = 1,
							weightedMode = 0,
							time = 1,
							outWeight = 0,
							inWeight = 0
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
						portId = "1"
					}
				}
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		[33] = {
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		[34] = {
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		[35] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376686
			},
			fields = {
				entityType = 2
			}
		},
		[38] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376686
			},
			fields = {
				entityType = 2
			}
		},
		[39] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376686
			},
			fields = {
				entityType = 2
			}
		},
		[40] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376686
			},
			fields = {
				entityType = 2
			}
		},
		[41] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376510
			},
			fields = {
				entityType = 2
			}
		},
		[44] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376510
			},
			fields = {
				entityType = 2
			}
		},
		[45] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376510
			},
			fields = {
				entityType = 2
			}
		},
		[46] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376614
			},
			fields = {
				entityType = 2
			}
		},
		[49] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376614
			},
			fields = {
				entityType = 2
			}
		},
		[50] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376614
			},
			fields = {
				entityType = 2
			}
		},
		[51] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376586
			},
			fields = {
				entityType = 2
			}
		},
		[54] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376586
			},
			fields = {
				entityType = 2
			}
		},
		[55] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376586
			},
			fields = {
				entityType = 2
			}
		},
		[56] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376600
			},
			fields = {
				entityType = 2
			}
		},
		[59] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376600
			},
			fields = {
				entityType = 2
			}
		},
		[60] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376600
			},
			fields = {
				entityType = 2
			}
		},
		[61] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376572
			},
			fields = {
				entityType = 2
			}
		},
		[64] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376572
			},
			fields = {
				entityType = 2
			}
		},
		[65] = {
			kind = 9,
			inputs = {
				staticIdVInput = 60376572
			},
			fields = {
				entityType = 2
			}
		}
	}
}
