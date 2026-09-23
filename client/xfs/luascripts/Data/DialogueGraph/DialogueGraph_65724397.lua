-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_65724397.lua

return {
	dialogueId = 65724397,
	schema = 1,
	startNodeId = 1,
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
			kind = 19,
			inputs = {
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 52
				},
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 54
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 54
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0,
							time = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							weightedMode = 0,
							time = 1
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
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 6
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
						portId = "In",
						nodeId = 10
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 18
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 26
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 34
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 53
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 53
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 53
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 53
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70002711
			},
			fields = {
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
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
				}
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 65717517
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 55
				}
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 201410,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 55
				}
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 0,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 14
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 55
				}
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 0,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 15
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
						portId = "In",
						nodeId = 17
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 55
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141003
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 55
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 65717532
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 19
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
						portId = "In",
						nodeId = 20
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141002
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 22
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 23
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 25
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 65718063
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 27
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
						portId = "In",
						nodeId = 28
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141002
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 57
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 57
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 57
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 31
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 57
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 33
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 57
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 65718061
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 36
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 39
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
						portId = "In",
						nodeId = 41
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 40
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141004
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 65718072
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 43
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
						portId = "In",
						nodeId = 44
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 45
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141101
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyStart"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 46
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Behav_HappyEnd"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 49
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
						portId = "In",
						nodeId = 51
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 50
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				isLooping = false,
				entityType = 1,
				templateId = 1002400,
				processingTime = 0,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20141102
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 59
				}
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 1,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
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
		{
			kind = 43,
			inputs = {
				slotIDVInput = 65730304,
				sceneIDVinput = 415,
				dialogsetIDVInput = 65730302
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65717517
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65717532
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65718063
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65718061
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65718072
			},
			fields = {
				entityType = 2
			}
		}
	}
}
