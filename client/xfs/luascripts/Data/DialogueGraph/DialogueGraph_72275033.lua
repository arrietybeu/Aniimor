-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72275033.lua

return {
	schema = "v4",
	startNodeId = 3,
	dialogueId = 72275033,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 3
			},
			flowIn = {
				End = true
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 1
			},
			flowIn = {
				End = true
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 2
			},
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
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 18,
			inputs = {
				hideAllUIVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				hideTopLogoVInput = true
			},
			fields = {
				topLogoComs = {
					multiPlayer = true,
					combat = true,
					chat = true,
					callFriends = true,
					bubble = true,
					alert = true,
					vlog = true,
					teamSpeech = true,
					quest = true,
					photo = true,
					petFertility = true,
					petExchange = true,
					petChat = true,
					npc = true
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 138
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					167.503,
					0
				},
				targetPositionVInput = {
					-487.947,
					56.897,
					773.596
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 141
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 11
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 135
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 137
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityID",
					nodeId = 140
				}
			},
			fields = {
				enableGroupLookAt = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 13
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 14
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 134
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904176
			},
			fields = {
				chatType = 3,
				portCount = 3,
				duration = 6
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 15
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 126
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 133
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904177
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
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
						nodeId = 19
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 123
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 125
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Talk"
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904180
			},
			fields = {
				duration = 7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904181
			},
			fields = {
				portCount = 3,
				duration = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 21
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 115
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 122
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904182
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 22
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 23
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 25
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 113
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = true
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
				playableStateVInput = "Talk_Righthand",
				playStartLoopEndVInput = true,
				staticIdVInput = 72326352
			},
			fields = {
				processingTime = 2,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904187
			},
			fields = {
				duration = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 26
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 27
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 110
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 112
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904190
			},
			fields = {
				portCount = 3,
				duration = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 28
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 43
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 36
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 31
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400230,
				positionVInput = {
					-486.544,
					57.793,
					773.718
				},
				rotationVInput = {
					0,
					277.221,
					0
				}
			},
			fields = {
				entityId = -941792415
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_LoveLoop",
				loopDurationVInput = 10
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			fields = {
				processingTime = 2.417,
				playAniType = 1,
				entityType = 2,
				templateId = 400210
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 201402,
				positionVInput = {
					-488.345,
					58.09,
					771.763
				},
				rotationVInput = {
					0,
					17.93,
					0
				}
			},
			fields = {
				entityId = -1102685918
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_LoveLoop",
				loopDurationVInput = 10
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 36
				}
			},
			fields = {
				processingTime = 2.417,
				playAniType = 1,
				entityType = 2,
				templateId = 400210
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 36
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 36
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 36
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 30,
				positionVInput = {
					-489.825,
					58.992,
					775.737
				},
				rotationVInput = {
					11.483,
					138.37,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72475601
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 27,
				positionVInput = {
					-489.825,
					59.392,
					775.737
				},
				rotationVInput = {
					11.483,
					138.37,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72879635
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400068,
				positionVInput = {
					-486.95,
					57.83,
					771.516
				},
				rotationVInput = {
					0,
					347.32,
					0
				}
			},
			fields = {
				entityId = -498530705
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_LoveLoop",
				loopDurationVInput = 10
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 43
				}
			},
			fields = {
				processingTime = 2.417,
				playAniType = 1,
				entityType = 2,
				templateId = 400210
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 43
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 43
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 20,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 43
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904323
			},
			fields = {
				chatType = 5,
				skipTime = 1,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				portCount = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 50
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 109
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904324
			},
			fields = {
				chatType = 3,
				portCount = 3,
				duration = 3
			},
			flowIn = {
				In = true
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
						nodeId = 71
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 90
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904191
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 52
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 53
					}
				},
				["1"] = {
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
				delayTime = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 54
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 55
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 66
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 68
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904325
			},
			fields = {
				chatType = 5,
				skipTime = 1,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 56
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904201
			},
			fields = {
				duration = 9
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 57
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 58
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 63
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 64
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 65
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904204
			},
			fields = {
				chatType = 3,
				duration = 10
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 59
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 60
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 62
					}
				}
			}
		},
		{
			kind = 10,
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
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 30,
				positionVInput = {
					-489.489,
					58.548,
					774.399
				},
				rotationVInput = {
					14.851,
					110.933,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466403
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Talk"
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					67.461,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 147
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.691,
					58.286,
					773.777
				},
				rotationVInput = {
					20.764,
					136.235,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466402
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 45
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 38
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 33
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 70
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 600034,
				positionVInput = {
					-487.463,
					57.788,
					772.996
				}
			},
			fields = {
				entityId = -1584247083
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904200
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 72
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 73
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 74
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 75
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 85
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 87
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904327
			},
			fields = {
				chatType = 5,
				skipTime = 1,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 76
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904203
			},
			fields = {
				chatType = 3,
				duration = 11
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 77
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 79
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 78
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 84
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 30,
				positionVInput = {
					-489.489,
					58.548,
					774.399
				},
				rotationVInput = {
					14.851,
					110.933,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466513
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904204
			},
			fields = {
				chatType = 3,
				duration = 10
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 80
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 81
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 82
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 83
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "End",
						nodeId = 1
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Talk"
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 86
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.691,
					58.286,
					773.777
				},
				rotationVInput = {
					20.764,
					136.235,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466514
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 47
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 40
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 35
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 88
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 89
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 600034,
				positionVInput = {
					-487.463,
					57.788,
					772.996
				}
			},
			fields = {
				entityId = -1440011300
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904192
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 91
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 92
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 93
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 94
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 104
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 106
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904326
			},
			fields = {
				chatType = 5,
				skipTime = 1,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 95
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904202
			},
			fields = {
				chatType = 3,
				duration = 8
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 96
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 98
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 97
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 103
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 30,
				positionVInput = {
					-489.489,
					58.548,
					774.399
				},
				rotationVInput = {
					14.851,
					110.933,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466646
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904204
			},
			fields = {
				chatType = 3,
				duration = 10
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 99
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 100
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 101
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 102
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "End",
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 146
				}
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 105
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.691,
					58.286,
					773.777
				},
				rotationVInput = {
					20.764,
					136.235,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 72466515
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 46
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 39
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 34
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 107
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 108
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 600034,
				positionVInput = {
					-487.463,
					57.788,
					772.996
				}
			},
			fields = {
				entityId = -1653170535
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					146.558,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 145
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 50,
				positionVInput = {
					-487.893,
					58.196,
					773.578
				},
				rotationVInput = {
					9.216,
					64.263,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 111
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.805,
					58.23,
					773.62
				},
				rotationVInput = {
					9.354,
					64.401,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				cameraId = 72883486,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Firm_Start",
				playStartLoopEndVInput = true,
				staticIdVInput = 72326352
			},
			fields = {
				processingTime = 0.933,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 35,
				positionVInput = {
					-488.728,
					58.288,
					772.183
				},
				rotationVInput = {
					5.916,
					33.874,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 168,
				fStop = 18,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 114
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 35,
				positionVInput = {
					-488.905,
					58.288,
					772.307
				},
				rotationVInput = {
					6.466,
					38.961,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 168,
				fStop = 18,
				cameraId = 72879634,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904183
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 116
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 117
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 119
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 120
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 118
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Talk_Lefthand"
			},
			fields = {
				processingTime = 2,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904186
			},
			fields = {
				duration = 7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 35,
				positionVInput = {
					-488.728,
					58.288,
					772.183
				},
				rotationVInput = {
					5.916,
					33.874,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 168,
				fStop = 18,
				cameraId = 72476543,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 121
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 35,
				positionVInput = {
					-488.905,
					58.288,
					772.307
				},
				rotationVInput = {
					6.466,
					38.961,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 168,
				fStop = 18,
				cameraId = 72879133,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904185
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 116
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.849,
					58.218,
					773.062
				},
				rotationVInput = {
					8.116,
					36.349,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				cameraId = 72475764,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 124
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.706,
					58.184,
					773.252
				},
				rotationVInput = {
					8.254,
					37.724,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				cameraId = 72879074,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					67.009,
					0
				},
				targetPositionVInput = {
					-488.106,
					56.897,
					773.577
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 143
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904178
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 127
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
				In = true
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
						nodeId = 132
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 128
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 130
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 129
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Emotion_Confused",
				playStartLoopEndVInput = true,
				loopDurationVInput = 60
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 142
				}
			},
			fields = {
				processingTime = 6.433,
				playAniType = 1,
				templateId = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.849,
					58.218,
					773.062
				},
				rotationVInput = {
					8.116,
					36.349,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 131
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 45,
				positionVInput = {
					-487.796,
					58.205,
					773.134
				},
				rotationVInput = {
					8.116,
					36.349,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 114,
				fStop = 22,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					67.009,
					0
				},
				targetPositionVInput = {
					-488.106,
					56.897,
					773.577
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 144
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904179
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
				staticIdVInput = 72326352,
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 7
			},
			fields = {
				processingTime = 1.667,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 30,
				positionVInput = {
					-488.822,
					58.637,
					771.387
				},
				rotationVInput = {
					13.546,
					34.275,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 222,
				fStop = 17,
				cameraId = 72475497,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 136
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				blendExponentVInput = 2,
				blendFuncVInput = "Cubic",
				fovVInput = 27,
				positionVInput = {
					-488.822,
					58.637,
					771.387
				},
				rotationVInput = {
					13.546,
					34.275,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 222,
				fStop = 17,
				cameraId = 72879630,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72326352,
				playableStateVInput = "Emotion_Confused"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 141
				}
			},
			fields = {
				processingTime = 6.433,
				playAniType = 1,
				templateId = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					249.641,
					0
				},
				targetPositionVInput = {
					-487.172,
					56.897,
					773.998
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 140
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					150.408,
					0
				},
				targetPositionVInput = {
					-488.038,
					56.897,
					773.552
				}
			},
			fields = {
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							value = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							outWeight = 0,
							weightedMode = 0
						},
						{
							value = 1,
							time = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0
						}
					}
				}
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 72326352
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 17
		},
		{
			kind = 17
		},
		{
			kind = 17
		},
		{
			kind = 17
		},
		{
			kind = 17
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 72326352
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 17
		}
	}
}
