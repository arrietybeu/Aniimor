-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_57931666.lua

return {
	dialogueId = 57931666,
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
			kind = 11,
			fields = {
				modeInfo = {
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = true,
					toplogoComList = {
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true
					}
				}
			},
			flowIn = {
				In = 0
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 97
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 12
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 91
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 5
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 11
					}
				},
				["8"] = {
					{
						portId = "In",
						nodeId = 93
					}
				},
				["9"] = {
					{
						portId = "In",
						nodeId = 94
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					51.07,
					0
				},
				targetPositionVInput = {
					46.91,
					125,
					1143.58
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 102
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 72102274,
				durationVInput = 0.1,
				targetEulerAngleVInput = {
					0,
					43.461,
					0
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
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
				staticIdVInput = 72102274,
				playableStateVInput = "Emotion_Worried_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 400100,
				processingTime = 10.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Worried_Start",
					"Emotion_Worried_Loop",
					"Emotion_Worried_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					49.304,
					125.958,
					1144.9
				},
				rotationVInput = {
					8.079,
					298,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 109,
				fStop = 17.51,
				cameraId = 72339230,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 282,
				recombineQuality = 0
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
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				blendFuncVInput = "Linear",
				positionVInput = {
					49.304,
					125.958,
					1145.4
				},
				rotationVInput = {
					8.079,
					276.3,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 109,
				fStop = 17.51,
				cameraId = 72807120,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 282,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72102274,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102274
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610411
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 14
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
						nodeId = 15
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 87
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 89
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 86
					}
				},
				["4"] = {
					{
						portId = "Stop",
						nodeId = 7
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 90
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610412,
				lookAtIdVInput = 400265
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				portCount = 10
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
						nodeId = 77
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 79
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 80
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 81
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 82
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 84
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 85
					}
				},
				["8"] = {
					{
						portId = "Stop",
						nodeId = 86
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610413
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 18
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
				In = 0
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
						nodeId = 19
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 73
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 76
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 33,
				blendExponentVInput = 0,
				blendFuncVInput = "Cubic",
				positionVInput = {
					49.794,
					125.895,
					1143.673
				},
				rotationVInput = {
					350.814,
					201.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 10.18,
				cameraId = 72339468,
				visualizeDOF = false,
				squeezeFactor = 1.174,
				sensorWidth = 81,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				fovVInput = 30,
				blendExponentVInput = 0,
				blendFuncVInput = "Linear",
				positionVInput = {
					49.794,
					125.895,
					1143.673
				},
				rotationVInput = {
					350.814,
					201.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 10.18,
				cameraId = 73753017,
				visualizeDOF = false,
				squeezeFactor = 1.174,
				sensorWidth = 81,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "1",
						nodeId = 21
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
				["1"] = 0,
				["0"] = 0
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
				portCount = 6
			},
			flowIn = {
				In = 0
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
						nodeId = 70
					}
				},
				["2"] = {
					{
						portId = "closeUIFInput",
						nodeId = 73
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 74
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 72
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206104131
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 24
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 25
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 65
					}
				},
				["2"] = {
					{
						portId = "closeUIFInput",
						nodeId = 68
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610414
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
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
				portCount = 4
			},
			flowIn = {
				In = 0
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
						nodeId = 66
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 45
					}
				},
				["3"] = {
					{
						portId = "Stop",
						nodeId = 65
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610415
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 10,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610416,
				lookAtIdVInput = 400100
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 30
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
						nodeId = 59
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 61
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 60
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 58
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 62
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610417,
				lookAtIdVInput = 400100
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 31
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 32
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 56
					}
				},
				["2"] = {
					{
						portId = "Stop",
						nodeId = 58
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 57
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610418,
				lookAtIdVInput = 400100
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 33
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 34
					}
				},
				["1"] = {
					{
						portId = "Stop",
						nodeId = 56
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 53
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 54
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 55
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610419,
				lookAtIdVInput = 400100
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 35
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
						nodeId = 36
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 51
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 50
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610420,
				lookAtIdVInput = 400162
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 40
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
						nodeId = 47
					}
				},
				["3"] = {
					{
						portId = "Stop",
						nodeId = 45
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 46
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 48
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 49
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 39
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "Cubic",
				positionVInput = {
					49.426,
					126.213,
					1144.175
				},
				rotationVInput = {
					18.225,
					223.015,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 1618,
				fStop = 7.35,
				cameraId = 72339335,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 287,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610421,
				lookAtIdVInput = 400265
			},
			fields = {
				portCount = 1,
				skipTime = 1.5,
				npcStaticId = -1,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 21,
			inputs = {
				blendTimeVInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 43
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = 0
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
			kind = 5,
			inputs = {
				playableStateVInput = "SitOnChair_Talk_Loop",
				staticIdVInput = 72033183
			},
			fields = {
				templateId = 400265,
				processingTime = 5,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102272
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 93
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 93
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 94
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 94
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think",
				staticIdVInput = 72102272
			},
			fields = {
				templateId = 400162,
				processingTime = 9,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 33,
				blendFuncVInput = "Linear",
				positionVInput = {
					47.716,
					126.323,
					1144.179
				},
				rotationVInput = {
					345.142,
					233.56,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 90,
				fStop = 17.59,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1.005,
				sensorWidth = 307,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 52
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 8,
				blendFuncVInput = "Linear",
				positionVInput = {
					47.716,
					126.323,
					1144.179
				},
				rotationVInput = {
					345.142,
					233.56,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 90,
				fStop = 17.59,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1.005,
				sensorWidth = 307,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72102272,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Excited",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 3.017,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102274
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 72102274,
				playableStateVInput = "Emotion_Sorrow_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 400406,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Sorrow_Start",
					"Emotion_Sorrow_Loop",
					"Emotion_Sorrow_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72102274,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Confused",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 6.433,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 0.1,
				staticIdVInput = 2
			},
			valueIn = {
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 107
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72033183,
				staticIdVInput = 72102274
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102274
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					48.668,
					125.848,
					1144.126
				},
				rotationVInput = {
					5.5,
					334.85,
					0.003
				}
			},
			fields = {
				openDof = true,
				focalDistance = 168,
				fStop = 13.61,
				cameraId = 73594622,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 334,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 64
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				blendFuncVInput = "Linear",
				positionVInput = {
					48.668,
					125.848,
					1144.126
				},
				rotationVInput = {
					5.5,
					334.85,
					0.003
				}
			},
			fields = {
				openDof = true,
				focalDistance = 168,
				fStop = 13.61,
				cameraId = 73594624,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 334,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Talk_Loop",
				staticIdVInput = 72102272
			},
			fields = {
				templateId = 400162,
				processingTime = 22,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 33,
				blendExponentVInput = 0,
				blendFuncVInput = "Cubic",
				positionVInput = {
					49.794,
					125.895,
					1143.673
				},
				rotationVInput = {
					350.814,
					201.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 10.18,
				cameraId = 73753396,
				visualizeDOF = false,
				squeezeFactor = 1.174,
				sensorWidth = 81,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				blendTimeVInput = 8,
				fovVInput = 30,
				blendExponentVInput = 0,
				blendFuncVInput = "Linear",
				positionVInput = {
					49.794,
					125.895,
					1143.673
				},
				rotationVInput = {
					350.814,
					201.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 10.18,
				cameraId = 73753397,
				visualizeDOF = false,
				squeezeFactor = 1.174,
				sensorWidth = 81,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 27,
			fields = {
				uid = 306,
				param = {
					title = "CHARACTER_APPEARANCE_DESC_Levi",
					name = "CHARACTER_APPEARANCE_NAME_Levi",
					pos = {
						1044,
						-123,
						0
					}
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102272
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 33,
				blendFuncVInput = "Linear",
				positionVInput = {
					47.716,
					126.323,
					1144.179
				},
				rotationVInput = {
					345.142,
					233.56,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 90,
				fStop = 17.59,
				cameraId = 72339298,
				visualizeDOF = false,
				squeezeFactor = 1.005,
				sensorWidth = 307,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 71
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 8,
				blendFuncVInput = "Linear",
				positionVInput = {
					47.716,
					126.323,
					1144.179
				},
				rotationVInput = {
					345.142,
					233.56,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 90,
				fStop = 17.59,
				cameraId = 73739343,
				visualizeDOF = false,
				squeezeFactor = 1.005,
				sensorWidth = 307,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102272
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 27,
			fields = {
				uid = 306,
				param = {
					title = "CHARACTER_APPEARANCE_DESC_Oswin",
					name = "CHARACTER_APPEARANCE_NAME_Oswin",
					pos = {
						-2092,
						-391,
						0
					}
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				dialogueIdVInput = 206104132,
				lookAtIdVInput = 400265
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72033183
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					48.668,
					125.848,
					1144.126
				},
				rotationVInput = {
					5.5,
					334.85,
					0.003
				}
			},
			fields = {
				openDof = true,
				focalDistance = 168,
				fStop = 13.61,
				cameraId = 72339231,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 334,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 78
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 42,
				blendTimeVInput = 10,
				blendFuncVInput = "Linear",
				positionVInput = {
					48.668,
					125.848,
					1144.126
				},
				rotationVInput = {
					5.5,
					334.85,
					0.003
				}
			},
			fields = {
				openDof = true,
				focalDistance = 168,
				fStop = 13.61,
				cameraId = 73762534,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 334,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72033183,
				staticIdVInput = 72102274
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72033183,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 2,
				durationVInput = 0.2,
				targetEulerAngleVInput = {
					0,
					168.52,
					0
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 72102274,
				durationVInput = 0.1,
				targetEulerAngleVInput = {
					0,
					148.583,
					0
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						portId = "In",
						nodeId = 83
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Crossingarms",
				staticIdVInput = 72102274
			},
			fields = {
				templateId = 400100,
				processingTime = 5.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72102272
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 72033183
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Confused",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 6.433,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					47.541,
					125.938,
					1144.569
				},
				rotationVInput = {
					8.34,
					18.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 110,
				fStop = 13.43,
				cameraId = 72806903,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 217,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 88
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				blendFuncVInput = "Linear",
				positionVInput = {
					47.541,
					125.938,
					1144.569
				},
				rotationVInput = {
					8.34,
					18.6,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 110,
				fStop = 13.43,
				cameraId = 72807376,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 217,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 72102274,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 72102272
			},
			valueIn = {
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 106
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 2,
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					163.9,
					0
				},
				targetPositionVInput = {
					48.263,
					124.61,
					1145.684
				}
			},
			fields = {
				finishToSteer = false,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0
						},
						{
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
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
						portId = "In",
						nodeId = 92
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 0.1,
				staticIdVInput = 2
			},
			valueIn = {
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 104
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_NPC_Light01.prefab",
				postionVInput = {
					49.302,
					126.182,
					1142.791
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_NPC_Light.prefab",
				postionVInput = {
					47.203,
					126.646,
					1144.054
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
			}
		},
		[96] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72033183
			},
			fields = {
				entityType = 2
			}
		},
		[97] = {
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 96
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 98
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 99
				},
				["4EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 100
				}
			},
			fields = {
				portCount = 4
			}
		},
		[98] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72102272
			},
			fields = {
				entityType = 2
			}
		},
		[99] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72102274
			},
			fields = {
				entityType = 2
			}
		},
		[100] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[102] = {
			kind = 17,
			inputs = {
				staticIdVInput = 72102272
			},
			fields = {
				entityType = 2
			}
		},
		[104] = {
			kind = 17,
			inputs = {
				staticIdVInput = 72102274
			},
			fields = {
				entityType = 2
			}
		},
		[106] = {
			kind = 17,
			fields = {
				entityType = 0
			}
		},
		[107] = {
			kind = 17,
			inputs = {
				staticIdVInput = 72033183
			},
			fields = {
				entityType = 2
			}
		}
	}
}
