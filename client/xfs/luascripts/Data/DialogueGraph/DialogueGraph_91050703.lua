-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91050703.lua

return {
	dialogueId = 91050703,
	schema = 1,
	startNodeId = 2,
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
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					hideAllUI = true,
					showHud = true,
					hideInteractionSign = false,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					resetAllActions = true,
					blockEvent = true,
					modeType = 2,
					disableSpaceFollow = true,
					applyStateConflict = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						portId = "End",
						nodeId = 0
					}
				},
				Out = {
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
				portCount = 6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 5
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 32
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 31
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6517120
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 5.25,
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
						nodeId = 6
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
						nodeId = 10
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
						nodeId = 27
					}
				},
				["3"] = {
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
				fovVInput = 25,
				positionVInput = {
					-1336.316,
					103.732,
					1185.452
				},
				rotationVInput = {
					14.713,
					107.864,
					0
				}
			},
			fields = {
				cameraId = 91074633,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 197,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 10.66
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 10,
				positionVInput = {
					-1336.316,
					103.732,
					1185.452
				},
				rotationVInput = {
					15.916,
					109.067,
					0
				}
			},
			fields = {
				cameraId = 91074970,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 197,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 10.66
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91051095,
				staticIdVInput = 91051106
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6517121
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 8.25,
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
						nodeId = 11
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
						nodeId = 12
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 15
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 20
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 17
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 22
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 24
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 25
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6517122
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 5.5,
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
						nodeId = 13
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
						nodeId = 14
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				endSkipVInput = true
			},
			flowIn = {
				In = 0
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-1334.471,
					103.851,
					1180.117
				},
				rotationVInput = {
					6.132,
					357.638,
					0
				}
			},
			fields = {
				cameraId = 91074639,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 480,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 10,
				positionVInput = {
					-1334.582,
					104.183,
					1180.149
				},
				rotationVInput = {
					9.741,
					359.013,
					0
				}
			},
			fields = {
				cameraId = 91074972,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 480,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91051106,
				staticIdVInput = 91051252
			},
			flowIn = {
				In = 0
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
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91051108,
				staticIdVInput = 91051252
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				staticIdVInput = 91051252,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 5.667,
				aniStateList = {
					"Squat_End",
					"Emotion_Firm_Start",
					"Emotion_Firm_Loop"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				loopDurationVInput = 999,
				staticIdVInput = 91051252,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 5.667,
				aniStateList = {
					"Emotion_Firm_End",
					"IdleRelax",
					"Squat_Start"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4
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
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart",
				loopDurationVInput = 5,
				staticIdVInput = 91051242,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 5120135,
				processingTime = 5.667,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91051252,
				staticIdVInput = 91051095
			},
			flowIn = {
				In = 0
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
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91051100,
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 5120131,
				processingTime = 1.9,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "SquatFall_Start",
				loopDurationVInput = 999,
				staticIdVInput = 91051106,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 5.667,
				aniStateList = {
					"SquatFall_Start",
					"SquatFall_Loop",
					"SquatFall_Loop"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 28
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91051106,
				playableStateVInput = "SquatFall_Loop"
			},
			fields = {
				playAniType = 1,
				isLooping = true,
				entityType = 0,
				templateId = 401,
				processingTime = 5.667
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
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Crossingarms_Start",
				loopDurationVInput = 10,
				staticIdVInput = 91051095,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 301,
				processingTime = 5.667,
				aniStateList = {
					"Talk_Crossingarms_Start",
					"Talk_Crossingarms_Loop",
					"Talk_Crossingarms_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91051108,
				staticIdVInput = 91051095
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 2,
				positionVInput = {
					-1336.111,
					104.215,
					1180.239
				},
				rotationVInput = {
					10.76,
					12.953,
					0
				}
			},
			fields = {
				cameraId = 91074193,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 352,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 450,
				fStop = 9.82
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 10,
				positionVInput = {
					-1336.001,
					104.122,
					1180.719
				},
				rotationVInput = {
					11.619,
					13.468,
					0
				}
			},
			fields = {
				cameraId = 91074968,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 352,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 450,
				fStop = 9.82
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 50,
			inputs = {
				fillLightIntensityVInput = 8000,
				enableFillLightVInput = true
			},
			flowIn = {
				In = 0
			}
		}
	}
}
