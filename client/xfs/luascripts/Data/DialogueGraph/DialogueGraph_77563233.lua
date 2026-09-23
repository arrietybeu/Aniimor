-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_77563233.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 77563233,
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
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
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
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					toplogoComList = {
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						portId = "In",
						nodeId = 148
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
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
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
			kind = 2,
			fields = {
				portCount = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 146
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					14.74,
					0
				},
				targetPositionVInput = {
					-515.659,
					53.014,
					846.803
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 175
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
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod",
				staticIdVInput = 79412478
			},
			fields = {
				templateId = 400063,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400077,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-514.761,
					53.058,
					846.673
				},
				rotationVInput = {
					0,
					342.963,
					0
				}
			},
			fields = {
				entityId = -755785473,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				playableStateVInput = "Talk_Lefthand"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 8
				}
			},
			fields = {
				templateId = 400077,
				processingTime = 2,
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
				staticIdVInput = 79412478
			},
			valueIn = {
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 8
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 175
				},
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 8
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 8
				},
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 175
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 8
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304205
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400063,
				matchAudioDuration = true,
				duration = 3.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
				portCount = 5
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
						nodeId = 143
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 12
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 144
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304206
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
				portCount = 7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 19
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 9
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 140
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 141
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304207
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400077,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
						nodeId = 21
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 137
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 13
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 138
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304208
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 10.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				portCount = 2
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
						nodeId = 23
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 50,
				positionVInput = {
					-514.73,
					54.183,
					847.012
				},
				rotationVInput = {
					355.855,
					333.14,
					0.687
				}
			},
			fields = {
				fStop = 16,
				cameraId = 89405949,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 925
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 50,
				blendTimeVInput = 10,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-514.406,
					54.232,
					846.479
				},
				rotationVInput = {
					349.805,
					332.757,
					2.376
				}
			},
			fields = {
				fStop = 16,
				cameraId = 89405950,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 705
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304209
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 10.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
						nodeId = 30
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
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 64,
			fields = {
				weather = 0,
				timePeriod = 2,
				changeType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						portId = "In",
						nodeId = 31
					}
				}
			}
		},
		{
			kind = 45,
			inputs = {
				timelineResIdVInput = "$P_TL_Grass_P8_ZhaoHuaXianLi.prefab"
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				PreFinish = {
					{
						portId = "In",
						nodeId = 33
					}
				},
				Start = {
					{
						portId = "In",
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					toplogoComList = {
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						portId = "In",
						nodeId = 136
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 22,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				portCount = 20
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "Play",
						nodeId = 72
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 36
					}
				},
				["10"] = {
					{
						portId = "In",
						nodeId = 50
					}
				},
				["11"] = {
					{
						portId = "In",
						nodeId = 52
					}
				},
				["12"] = {
					{
						portId = "In",
						nodeId = 56
					}
				},
				["13"] = {
					{
						portId = "In",
						nodeId = 58
					}
				},
				["14"] = {
					{
						portId = "In",
						nodeId = 60
					}
				},
				["15"] = {
					{
						portId = "In",
						nodeId = 62
					}
				},
				["16"] = {
					{
						portId = "In",
						nodeId = 64
					}
				},
				["17"] = {
					{
						portId = "In",
						nodeId = 66
					}
				},
				["18"] = {
					{
						portId = "In",
						nodeId = 68
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 70
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 71
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 37
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 40
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 42
					}
				},
				["8"] = {
					{
						portId = "In",
						nodeId = 44
					}
				},
				["9"] = {
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
				playableStateVInput = "Emotion_Anxious"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 177
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 18.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400554,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-511.81,
					52.955,
					843.539
				},
				rotationVInput = {
					0,
					322.273,
					0
				}
			},
			fields = {
				entityId = -492761629,
				ignoreGravity = false
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
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 37
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400554,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 37
				}
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
			kind = 16,
			inputs = {
				slotParamVInput = 400557,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.23,
					52.815,
					843.112
				},
				rotationVInput = {
					0,
					23.624,
					0
				}
			},
			fields = {
				entityId = -1104310218,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 40
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400557,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Akimbo01_Start",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400550,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-516.162,
					52.848,
					843.95
				},
				rotationVInput = {
					0,
					19.175,
					0
				}
			},
			fields = {
				entityId = -954269658,
				ignoreGravity = false
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
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 42
				}
			},
			fields = {
				playAniType = 1,
				templateId = 401069,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400558,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-519.401,
					52.848,
					844.421
				},
				rotationVInput = {
					0,
					36.123,
					0
				}
			},
			fields = {
				entityId = -890413900,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 45
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_AngrySigh",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 44
				}
			},
			fields = {
				playAniType = 1,
				templateId = 401070,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_AngrySigh",
					"Emotion_AngrySigh",
					"Emotion_AngrySigh"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400557,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-513.323,
					52.848,
					843.635
				},
				rotationVInput = {
					0,
					339.343,
					0
				}
			},
			fields = {
				entityId = -331824419,
				ignoreGravity = false
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
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Story_FoldArms_Loop",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 46
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400147,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_FoldArms_Loop",
					"Story_FoldArms_Loop",
					"Story_FoldArms_Loop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 46
				}
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
				delayTime = 0.1
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
			kind = 16,
			inputs = {
				slotParamVInput = 400556,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-512.88,
					52.848,
					843.912
				},
				rotationVInput = {
					0,
					323.167,
					0
				}
			},
			fields = {
				entityId = -340610525,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 51
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Daily_Pray_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 50
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400556,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Daily_Pray_Start",
					"Daily_Pray_Loop",
					"Daily_Pray_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-514.446,
					52.848,
					842.95
				},
				rotationVInput = {
					0,
					359.41,
					0
				}
			},
			fields = {
				entityId = -1437125028,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 55
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Story_Thankful_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 52
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400576,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Thankful_Start",
					"Story_Thankful_Loop",
					"Story_Thankful_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 52
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 53
					}
				}
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
						nodeId = 54
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.278,
					52.848,
					842.489
				},
				rotationVInput = {
					0,
					1.078,
					0
				}
			},
			fields = {
				entityId = -1496783819,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 57
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_Helpless",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 56
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400295,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Helpless",
					"Emotion_Helpless",
					"Emotion_Helpless"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400555,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-519.495,
					52.848,
					844.959
				},
				rotationVInput = {
					0,
					24.763,
					0
				}
			},
			fields = {
				entityId = -1204928747,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 59
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Daily_Pray_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 58
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400297,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Daily_Pray_Start",
					"Daily_Pray_Loop",
					"Daily_Pray_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400556,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-515.516,
					52.848,
					842.793
				},
				rotationVInput = {
					0,
					357.51,
					0
				}
			},
			fields = {
				entityId = -1705345280,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_Anger_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 60
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400556,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Anger_Start",
					"Emotion_Anger_Loop",
					"Emotion_Anger_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400554,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-518.049,
					52.848,
					843.642
				},
				rotationVInput = {
					0,
					20.574,
					0
				}
			},
			fields = {
				entityId = -1801443834,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 63
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 62
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400554,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400555,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-515.449,
					52.848,
					843.47
				},
				rotationVInput = {
					0,
					4.736,
					0
				}
			},
			fields = {
				entityId = -1529848584,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 65
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Talk",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 64
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400147,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Talk",
					"Talk",
					"Talk"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400558,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-514.531,
					52.848,
					843.63
				},
				rotationVInput = {
					0,
					349.287,
					0
				}
			},
			fields = {
				entityId = -616296598,
				ignoreGravity = false
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
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Story_Discuss_Start_02",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 66
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400147,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Discuss_Start_02",
					"Story_Discuss_Loop_02",
					"Story_Discuss_End_02"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.435,
					52.848,
					844.263
				},
				rotationVInput = {
					0,
					20.521,
					0
				}
			},
			fields = {
				entityId = -882173410,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 68
				}
			},
			fields = {
				playAniType = 1,
				templateId = 400147,
				processingTime = 0,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					302.763,
					0
				},
				targetPositionVInput = {
					-513.224,
					52.857,
					844.658
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
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
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					356.001,
					0
				},
				targetPositionVInput = {
					-513.944,
					52.97,
					844.399
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
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
			kind = 31,
			inputs = {
				isBGMVInput = true,
				audioEventVInput = "BGM_Scene_FestivalAccident"
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 73
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
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
				portCount = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 77
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 75
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 50,
				positionVInput = {
					-511.881,
					55.395,
					839.965
				},
				rotationVInput = {
					4.296,
					332.723,
					359.052
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91291393,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 925
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 50,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-511.881,
					55.395,
					839.965
				},
				rotationVInput = {
					4.296,
					332.723,
					359.052
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91291394,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 705
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 78
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304210
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400063,
				matchAudioDuration = true,
				duration = 4.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 79
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
						nodeId = 80
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 134
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 131
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 132
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 133
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304211
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 7.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 81
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
						nodeId = 82
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304212
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 83
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
						nodeId = 87
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 84
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 86
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					8,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
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
						nodeId = 85
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Helpless"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				}
			},
			fields = {
				templateId = 4,
				processingTime = 2,
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
			kind = 15,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				},
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 178
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304213
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 88
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
						nodeId = 89
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 129
					}
				},
				["2"] = {
					{
						portId = "Stop",
						nodeId = 85
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304214
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 3304215
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 4,
				matchAudioDuration = true,
				duration = 3.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				In = 0
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
						nodeId = 92
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				positionVInput = {
					-514.806,
					54.535,
					846.502
				},
				rotationVInput = {
					11.117,
					336.739,
					0
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91336694,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 93
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 5,
				fovVInput = 60,
				positionVInput = {
					-514.865,
					54.507,
					846.638
				},
				rotationVInput = {
					10.773,
					336.739,
					0
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91336696,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304216
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
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
						nodeId = 96
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					328.695,
					0
				},
				targetPositionVInput = {
					-513.352,
					53.055,
					844.763
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
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
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					328.695,
					0
				},
				targetPositionVInput = {
					-512.36,
					53.228,
					844.732
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
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
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
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
						nodeId = 101
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 121
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 124
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 120
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 126
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 123
					}
				},
				["7"] = {
					{
						portId = "Play",
						nodeId = 128
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.791,
				maxLimitTimeVInput = 8,
				targetPositionVInput = {
					-514.892,
					53.023,
					846.615
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
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
							outWeight = 0,
							inWeight = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							time = 1,
							weightedMode = 0
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
						portId = "0",
						nodeId = 102
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				maxAwaitTime = -1,
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 103
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
						nodeId = 104
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-516.996,
					55.087,
					845.849
				},
				rotationVInput = {
					26.313,
					46.463,
					359.323
				}
			},
			fields = {
				fStop = 12,
				cameraId = 91336707,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 130
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 105
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
						nodeId = 106
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 118
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 119
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304217
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 10.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 107
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
						nodeId = 109
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 108
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				}
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
						nodeId = 110
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
						nodeId = 111
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 112
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
						nodeId = 113
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 116
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
						nodeId = 114
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
						nodeId = 115
					}
				},
				["1"] = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 117
					}
				}
			}
		},
		{
			kind = 21,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 177
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 2.417,
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
				blendTimeVInput = 10,
				positionVInput = {
					-516.855,
					55.085,
					845.715
				},
				rotationVInput = {
					24.422,
					44.597,
					359.333
				}
			},
			fields = {
				fStop = 12,
				cameraId = 91336712,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 130
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-518.408,
					55.603,
					844.836
				},
				rotationVInput = {
					15.836,
					40.975,
					2.873
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91336705,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 122
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 5,
				positionVInput = {
					-518.227,
					55.386,
					844.729
				},
				rotationVInput = {
					15.981,
					37.345,
					1.877
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91336706,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead",
				staticIdVInput = 79412478
			},
			fields = {
				templateId = 400063,
				processingTime = 8.767,
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
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 125
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -755785473,
				speedVInput = 0.788,
				maxLimitTimeVInput = 8,
				targetEulerAngleVInput = {
					0,
					13,
					0
				},
				targetPositionVInput = {
					-515.755,
					53.017,
					846.633
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							inWeight = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							time = 1,
							weightedMode = 0
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
						portId = "1",
						nodeId = 102
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
						nodeId = 127
					}
				}
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 31,
			inputs = {
				isBGMVInput = true,
				audioEventVInput = "BGM_Scene_FestivalAccident"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				positionVInput = {
					-514.911,
					54.594,
					841.116
				},
				rotationVInput = {
					13.29,
					348.131,
					359.026
				}
			},
			fields = {
				fStop = 16,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 100
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 130
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				fovVInput = 50,
				positionVInput = {
					-514.989,
					53.735,
					842.758
				},
				rotationVInput = {
					344.719,
					355.49,
					0
				}
			},
			fields = {
				fStop = 10,
				cameraId = 91292009,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 300
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				},
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 178
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Righthand"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				}
			},
			fields = {
				templateId = 4,
				processingTime = 2.5,
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
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
				},
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 176
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 40,
				positionVInput = {
					-513.86,
					54.683,
					846.072
				},
				rotationVInput = {
					16.526,
					163.424,
					354.358
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91291391,
				visualizeDOF = false,
				squeezeFactor = 1.078,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 135
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-514.347,
					54.349,
					845.837
				},
				rotationVInput = {
					5.774,
					150.256,
					0
				}
			},
			fields = {
				fStop = 16,
				cameraId = 91291938,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 102
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 22,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 112
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk",
				staticIdVInput = 79412478
			},
			fields = {
				templateId = 400063,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 139
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79412478
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 175
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-513.726,
					54.855,
					848.536
				},
				rotationVInput = {
					17.587,
					225.7,
					0
				}
			},
			fields = {
				fStop = 16,
				cameraId = 89405943,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 142
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				positionVInput = {
					-513.789,
					54.44,
					848.657
				},
				rotationVInput = {
					9.757,
					223.033,
					359.187
				}
			},
			fields = {
				fStop = 16,
				cameraId = 89406731,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 175
				}
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
			kind = 4,
			fields = {
				delayTime = 0.4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 145
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 79412478
			},
			valueIn = {
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 175
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-515.329,
					54.827,
					844.785
				},
				rotationVInput = {
					8.639,
					1.611,
					359.346
				}
			},
			fields = {
				fStop = 16,
				cameraId = 77584471,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 145
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 147
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 10,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-515.308,
					54.774,
					845.134
				},
				rotationVInput = {
					8.811,
					2.812,
					359.346
				}
			},
			fields = {
				fStop = 16,
				cameraId = 80951595,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 145
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 22,
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
		[175] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[176] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[177] = {
			kind = 17,
			inputs = {
				staticIdVInput = 79412478
			},
			fields = {
				entityType = 2
			}
		},
		[178] = {
			kind = 17,
			inputs = {
				staticIdVInput = -755785473
			},
			fields = {
				entityType = 4
			}
		}
	}
}
