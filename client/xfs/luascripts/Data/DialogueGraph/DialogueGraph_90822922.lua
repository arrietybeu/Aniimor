-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90822922.lua

return {
	startNodeId = 2,
	dialogueId = 90822922,
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
					modeType = 2,
					toplogoComList = {
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
						chat = true,
						callFriends = true
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
			kind = 22,
			inputs = {
				blendVInput = 1
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
				portCount = 6
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 73
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 67
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 72
					}
				}
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						portId = "In",
						nodeId = 7
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
						nodeId = 8
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 66
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513002
			},
			fields = {
				duration = 6.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 9
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
						nodeId = 10
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 64
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 63
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513003
			},
			fields = {
				duration = 11.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349140,
				npcId = 990010,
				matchAudioDuration = true
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
				portCount = 5
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
						nodeId = 59
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 49
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 58
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513004
			},
			fields = {
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990026,
				matchAudioDuration = true
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
						nodeId = 14
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
						portId = "In",
						nodeId = 48
					}
				},
				["4"] = {
					{
						portId = "Play",
						nodeId = 57
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513005
			},
			fields = {
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990021,
				matchAudioDuration = true
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
						nodeId = 16
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 52
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 50
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 53
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
				dialogueIdVInput = 6513006
			},
			fields = {
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349154,
				npcId = 990018,
				matchAudioDuration = true
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
						nodeId = 18
					}
				},
				["1"] = {
					{
						portId = "Stop",
						nodeId = 50
					}
				},
				["2"] = {
					{
						portId = "Stop",
						nodeId = 48
					}
				},
				["3"] = {
					{
						portId = "Stop",
						nodeId = 49
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 51
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513007
			},
			fields = {
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349154,
				npcId = 990018,
				matchAudioDuration = true
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
						nodeId = 20
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 43
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 44
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 46
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513008
			},
			fields = {
				duration = 10.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349508,
				npcId = 990016,
				matchAudioDuration = true
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
						nodeId = 22
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
						nodeId = 40
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513009
			},
			fields = {
				duration = 7.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349140,
				npcId = 990010,
				matchAudioDuration = true
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
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513010
			},
			fields = {
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349140,
				npcId = 990010,
				matchAudioDuration = true
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
						nodeId = 26
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 37
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6513011
			},
			fields = {
				duration = 3.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = 91349140,
				npcId = 990010,
				matchAudioDuration = true
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
						nodeId = 28
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 31
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
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				enableFadeOutVInput = true,
				dialogueIdVInput = 6513012,
				enableFadeInVInput = true,
				disablePresetLookAtVInput = true
			},
			fields = {
				duration = 4,
				disableCamera = false,
				chatType = 5,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 1,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true
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
			kind = 12,
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
						nodeId = 32
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
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 2,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Sit_End"
			},
			fields = {
				templateId = 990010,
				processingTime = 1.9,
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
				delayTime = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				loopDurationVInput = 999,
				staticIdVInput = 91349154,
				playableStateVInput = "Home_HandworkLoop"
			},
			fields = {
				templateId = 990010,
				processingTime = 5.533,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349140,
				defaultTransStateVInput = "Sit_Idle",
				playableStateVInput = "Sit_Start"
			},
			fields = {
				templateId = 990010,
				processingTime = 1.933,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 91349140
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349140,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Emotion_Helpless"
			},
			fields = {
				templateId = 990010,
				processingTime = 3.233,
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
				fovVInput = 25,
				positionVInput = {
					27.991,
					102.304,
					-53.398
				},
				rotationVInput = {
					3.923,
					240.79,
					0
				}
			},
			fields = {
				cameraId = 91393518,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 388,
				fStop = 11.74
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 20,
				positionVInput = {
					27.068,
					102.231,
					-53.035
				},
				rotationVInput = {
					4.954,
					232.711,
					0
				}
			},
			fields = {
				cameraId = 91393552,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 360,
				fStop = 20
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 91349154
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 91349508
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					23.063,
					102.165,
					-55.342
				},
				rotationVInput = {
					15.267,
					174.442,
					0
				}
			},
			fields = {
				cameraId = 91393498,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 245,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 193,
				fStop = 23.66
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 10,
				positionVInput = {
					23.063,
					102.165,
					-55.342
				},
				rotationVInput = {
					17.33,
					174.442,
					0
				}
			},
			fields = {
				cameraId = 91393550,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 360,
				fStop = 20
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 2,
				playableStateVInput = "Sit_Idle"
			},
			fields = {
				templateId = 990010,
				processingTime = 3,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91349510,
				playStartLoopEndVInput = true,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Behav_CryStart"
			},
			fields = {
				templateId = 990024,
				processingTime = 2,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Behav_CryStart",
					"Behav_CryLoop",
					"Behav_CryEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349154,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Idle"
			},
			fields = {
				templateId = 303,
				processingTime = 1.967,
				playAniType = 1,
				isLooping = true,
				entityType = 0
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349158,
				defaultTransStateVInput = "Idle",
				playStartLoopEndVInput = true,
				playableStateVInput = "Behav_CryStart"
			},
			fields = {
				templateId = 990028,
				processingTime = 2,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Behav_CryStart",
					"Behav_CryLoop",
					"Behav_CryEnd"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349154,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Idle"
			},
			fields = {
				templateId = 303,
				processingTime = 1.967,
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
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349154,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Emotion_ShakeHead"
			},
			fields = {
				templateId = 303,
				processingTime = 1.967,
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
				staticIdVInput = 91349154
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					22.019,
					102.496,
					-55.385
				},
				rotationVInput = {
					11.486,
					99.842,
					0
				}
			},
			fields = {
				cameraId = 91393517,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 177,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 193,
				fStop = 31.88
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 54
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
					22.011,
					102.429,
					-55.366
				},
				rotationVInput = {
					9.079,
					100.186,
					0
				}
			},
			fields = {
				cameraId = 91393691,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 177,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 193,
				fStop = 31.88
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = 91349158,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Idle"
			},
			fields = {
				templateId = 990028,
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
			kind = 5,
			inputs = {
				loopDurationVInput = 5,
				staticIdVInput = 91349156,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Lying02_Loop"
			},
			fields = {
				templateId = 990021,
				processingTime = 2,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Emotion_Parmon_10291_Cry"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91349158,
				staticIdVInput = 91349140
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
					24.906,
					103.323,
					-56.377
				},
				rotationVInput = {
					26.537,
					280.499,
					0
				}
			},
			fields = {
				cameraId = 91393516,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 249,
				fStop = 13.68
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 60
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
					25.268,
					103.507,
					-56.444
				},
				rotationVInput = {
					26.537,
					281.702,
					0
				}
			},
			fields = {
				cameraId = 91393548,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 360,
				fStop = 20
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
						portId = "Play",
						nodeId = 62
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Emotion_Parmon_10261_Cry"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91349140,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Sit_End"
			},
			fields = {
				templateId = 303,
				processingTime = 1.967,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 20,
				positionVInput = {
					24.762,
					102.5,
					-54.275
				},
				rotationVInput = {
					11.195,
					223.389,
					0
				}
			},
			fields = {
				cameraId = 91393497,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 305,
				fStop = 14.61
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
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendTimeVInput = 2,
				positionVInput = {
					24.762,
					102.5,
					-54.275
				},
				rotationVInput = {
					8.101,
					223.905,
					0
				}
			},
			fields = {
				cameraId = 91393496,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 360,
				fStop = 20
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91349158,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Float_End"
			},
			fields = {
				templateId = 990028,
				processingTime = 4.2,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					273.892,
					0
				},
				targetPositionVInput = {
					26.168,
					100.974,
					-55.117
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
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
			kind = 19,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					168.579,
					0
				},
				targetPositionVInput = {
					23.152,
					100.97,
					-55.333
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
							inTangent = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							value = 1,
							inWeight = 0,
							outTangent = 0
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
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91349154,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
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
						nodeId = 71
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 91349140,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 1,
				targetEulerAngleVInput = {
					0,
					252.246,
					0
				},
				targetPositionVInput = {
					27.54,
					100.993,
					-56.106
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					28.367,
					102.947,
					-52.593
				},
				rotationVInput = {
					11.658,
					237.352,
					0
				}
			},
			fields = {
				cameraId = 90858911,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 360,
				fStop = 13.01
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 74
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
					25.975,
					103.891,
					-52.557
				},
				rotationVInput = {
					25.752,
					218.617,
					0
				}
			},
			fields = {
				cameraId = 90858920,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 250,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 360,
				fStop = 20
			},
			flowIn = {
				In = 0
			}
		}
	}
}
