-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91046736.lua

return {
	dialogueId = 91046736,
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
				onSkipStartConnected = true,
				modeInfo = {
					blockEvent = true,
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
					toplogoComList = {
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
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true
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
						nodeId = 3
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
				portCount = 8
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
						nodeId = 8
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 86
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 9
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
						nodeId = 85
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-707.473,
					114.583,
					1658.613
				},
				rotationVInput = {
					354.796,
					90.797,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91058973,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 60,
				positionVInput = {
					-654.003,
					119.752,
					1655.957
				},
				rotationVInput = {
					354.109,
					85.812,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91058975,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
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
					101.075,
					0
				},
				targetPositionVInput = {
					-699.438,
					113.321,
					1659.303
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 89
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
			kind = 16,
			inputs = {
				slotParamVInput = 400180,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-701.044,
					113.091,
					1659.579
				},
				rotationVInput = {
					0,
					90.015,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1512638818
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400066,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-701.459,
					113.105,
					1657.708
				},
				rotationVInput = {
					0,
					15.41,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1405605314
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
						nodeId = 12
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
						nodeId = 14
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 84
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
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"TWIN_PET_CHOICE",
					nil,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "In",
						nodeId = 82
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201506
			},
			fields = {
				duration = 3.38,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201507
			},
			fields = {
				duration = 3.75,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 100,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
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
			kind = 2,
			fields = {
				portCount = 8
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
						nodeId = 20
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 76
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
						nodeId = 77
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 78
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 79
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 81
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-699.929,
					114.595,
					1659.144
				},
				rotationVInput = {
					9.922,
					290.53,
					0.001
				}
			},
			fields = {
				openDof = true,
				focalDistance = 59,
				fStop = 12.37,
				cameraId = 91364694,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 44,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201510
			},
			fields = {
				duration = 10.38,
				disableCamera = false,
				npcStaticId = -1512638818,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400180,
				matchAudioDuration = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201511
			},
			fields = {
				duration = 10.25,
				disableCamera = false,
				npcStaticId = -1512638818,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400180,
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 74
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 75
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201458
			},
			fields = {
				duration = 12,
				disableCamera = false,
				npcStaticId = -198394094,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
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
				["3"] = {
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
				staticIdVInput = -198394094,
				playableStateVInput = "Talk_Lefthand"
			},
			fields = {
				templateId = 400204,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201459
			},
			fields = {
				duration = 3.88,
				disableCamera = false,
				npcStaticId = -198394094,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
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
						nodeId = 29
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 73
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201460
			},
			fields = {
				duration = 2,
				disableCamera = false,
				npcStaticId = -1405605314,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400066,
				matchAudioDuration = true
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
						nodeId = 31
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 68
					}
				},
				["3"] = {
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
						nodeId = 72
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201461
			},
			fields = {
				duration = 8.62,
				disableCamera = false,
				npcStaticId = -1512638818,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400180,
				matchAudioDuration = true
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
						nodeId = 33
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
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 65
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201462
			},
			fields = {
				duration = 2,
				disableCamera = false,
				npcStaticId = -1405605314,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400066,
				matchAudioDuration = true
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201463
			},
			fields = {
				duration = 4.5,
				disableCamera = false,
				npcStaticId = -198394094,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
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
				portCount = 4
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
				["2"] = {
					{
						portId = "In",
						nodeId = 60
					}
				},
				["3"] = {
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
				dialogueIdVInput = 6201464
			},
			fields = {
				duration = 9.38,
				disableCamera = false,
				npcStaticId = -198394094,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
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
						nodeId = 38
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 57
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 56
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
						nodeId = 59
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"TWIN_PET_CHOICE",
					nil,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "In",
						nodeId = 52
					}
				},
				True = {
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
						nodeId = 40
					}
				},
				["1"] = {
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
				dialogueIdVInput = 6201465
			},
			fields = {
				duration = 6.88,
				disableCamera = false,
				npcStaticId = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
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
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201466
			},
			fields = {
				duration = 2.5,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
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
						nodeId = 44
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 48
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
						nodeId = 50
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201469
			},
			fields = {
				duration = 5.75,
				disableCamera = false,
				npcStaticId = -1512638818,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400180,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 45
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
						nodeId = 46
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
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				endSkipVInput = true
			},
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
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-698.526,
					115.201,
					1661.453
				},
				rotationVInput = {
					17.486,
					220.228,
					0.001
				}
			},
			fields = {
				openDof = true,
				focalDistance = 310,
				fStop = 15.11,
				cameraId = 91364627,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1512638818,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -1512638818
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1140168099,
				playableStateVInput = "Emotion_Complacent"
			},
			fields = {
				templateId = 400109,
				processingTime = 4.117,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
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
						nodeId = 54
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 53
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Surprise_Start",
				staticIdVInput = -1140168099,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 400109,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				processingTime = 0.5,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201467
			},
			fields = {
				duration = 7.38,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 100,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 6201468
			},
			fields = {
				duration = 2.25,
				disableCamera = false,
				npcStaticId = -1140168099,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "1",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -1140168099
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-700.939,
					114.353,
					1658.935
				},
				rotationVInput = {
					25.908,
					48.685,
					0.002
				}
			},
			fields = {
				openDof = true,
				focalDistance = 114,
				fStop = 25,
				cameraId = 91364828,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 196,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -198394094,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1405605314,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -198394094,
				targetEulerAngleVInput = {
					0,
					-19.15,
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
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -198394094,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -198394094,
				playableStateVInput = "Talk_Introduce"
			},
			fields = {
				templateId = 400204,
				processingTime = 0.5,
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
				fovVInput = 30,
				positionVInput = {
					-699.896,
					115.269,
					1660.208
				},
				rotationVInput = {
					28.486,
					206.306,
					0.002
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91063068,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -198394094,
				targetEulerAngleVInput = {
					0,
					-109,
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
			kind = 15,
			inputs = {
				staticIdVInput = -1405605314,
				lookAtEntityStaticIdVInput = -198394094
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 66
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1405605314,
				playableStateVInput = "Talk_Crossingarms"
			},
			fields = {
				templateId = 400066,
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
				staticIdVInput = -198394094,
				lookAtEntityStaticIdVInput = -1405605314
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -1512638818,
				targetEulerAngleVInput = {
					0,
					143.35,
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
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1512638818,
				playableStateVInput = "Talk_Crossingarms"
			},
			fields = {
				templateId = 400180,
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
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-698.526,
					115.201,
					1661.453
				},
				rotationVInput = {
					17.486,
					220.228,
					0.001
				}
			},
			fields = {
				openDof = true,
				focalDistance = 310,
				fStop = 15.11,
				cameraId = 91062965,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -198394094,
				lookAtEntityStaticIdVInput = -1512638818
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1512638818,
				lookAtEntityStaticIdVInput = -1405605314
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_LoveStart",
				staticIdVInput = -1405605314,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 400066,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				processingTime = 1,
				aniStateList = {
					"Behav_LoveStart",
					"Behav_LoveLoop",
					"Behav_LoveEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-699.912,
					114.877,
					1659.699
				},
				rotationVInput = {
					19.204,
					208.884,
					0.001
				}
			},
			fields = {
				openDof = true,
				focalDistance = 172,
				fStop = 4,
				cameraId = 91364696,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 71,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -198394094
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1512638818,
				lookAtEntityStaticIdVInput = -198394094
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -198394094,
				lookAtEntityStaticIdVInput = -1512638818
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1140168099,
				targetEulerAngleVInput = {
					0,
					209.912,
					0
				},
				targetPositionVInput = {
					-699.852,
					113.244,
					1659.991
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
			kind = 26,
			inputs = {
				staticIdVInput = -198394094,
				targetEulerAngleVInput = {
					90,
					0,
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
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					264.071,
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
			kind = 14,
			inputs = {
				staticIdVInput = -198394094,
				targetEulerAngleVInput = {
					0,
					333.61,
					0
				},
				targetPositionVInput = {
					-700.484,
					113.236,
					1658.251
				}
			},
			fields = {
				reset = false,
				setRotation = false,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201508
			},
			fields = {
				duration = 4.25,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 400204,
				matchAudioDuration = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201509
			},
			fields = {
				duration = 4.25,
				disableCamera = false,
				npcStaticId = 79229255,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcId = 100,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "1",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1140168099,
				lookAtEntityStaticIdVInput = -198394094
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 200001,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-699.935,
					113.252,
					1659.778
				},
				rotationVInput = {
					358.664,
					64.95,
					1.674
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1140168099
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-700.411,
					113.25,
					1658.212
				},
				rotationVInput = {
					0,
					104.248,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -198394094
			},
			flowIn = {
				In = 0
			}
		},
		[89] = {
			kind = 17,
			fields = {
				entityType = 0
			}
		}
	}
}
