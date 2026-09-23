-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91222716.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91222716,
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
					showHud = true,
					hideAllUI = true,
					toplogoComList = {
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
						battleRoom = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = true,
						photo = true
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
						nodeId = 3
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 5
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
						portId = "In",
						nodeId = 4
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 91320966,
				isResetValueInput = true,
				durationVInput = 0
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
						nodeId = 7
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 238
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 243
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 248
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 269
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107010
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5,
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
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 242
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1,
				enableGroupLookAt = false,
				enableDefaultLookAt = true,
				cameraPreset = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
					{
						portId = "In",
						nodeId = 9
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
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91248148,
				blendFuctionVInput = 3,
				cameraMovementTypeVInput = 1
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
			kind = 53,
			inputs = {
				cameraIdVInput = 91248158,
				blendInTimeVInput = 5,
				cameraMovementTypeVInput = 1
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
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107055,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 5.75,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107056,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 3.5,
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
						nodeId = 16
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 237
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107057,
				dialogsetCameraIdVInput = 91248276
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4.62,
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
						nodeId = 17
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
						nodeId = 19
					}
				},
				["1"] = {
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
				playableStateVInput = "Daily_Thanks",
				staticIdVInput = -2131311940
			},
			fields = {
				templateId = 5200027,
				processingTime = 1.767,
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
				dialogueIdVInput = 9107058,
				dialogsetCameraIdVInput = 91248279
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4.38,
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
						nodeId = 20
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
						nodeId = 22
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
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial03",
				staticIdVInput = -849169900
			},
			fields = {
				templateId = 5200022,
				processingTime = 5.733,
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
				dialogueIdVInput = 9107059,
				dialogsetCameraIdVInput = 91248282
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 5.12,
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
						nodeId = 23
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
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Hello",
				staticIdVInput = -1490126528
			},
			fields = {
				templateId = 401,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107060,
				dialogsetCameraIdVInput = 91248309
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4.19,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107061,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 7,
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
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107062,
				dialogsetCameraIdVInput = 91248321
			},
			fields = {
				portCount = 1,
				skipTime = 1,
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
						nodeId = 28
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
						nodeId = 33
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 30
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
						nodeId = 32
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 230
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -346013045
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 275
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 275
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -2131311940
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 274
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 274
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -849169900
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 273
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 273
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1490126528
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 276
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 276
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 91248071,
				isFadeInVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 238
				}
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107011,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Amazed",
				animCfg = {
					[1] = "Emotion_Amazed",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
			kind = 53,
			inputs = {
				cameraIdVInput = 91247738
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
						nodeId = 37
					}
				},
				["1"] = {
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
				dialogueIdVInput = 9107012
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				entityIdVInput = -312948930,
				staticIdVInput = -312948930
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 271
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 271
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
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
			kind = 19,
			inputs = {
				staticIdVInput = -312948930
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 272
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 272
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "In",
						nodeId = 40
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
						nodeId = 229
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107013
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -341274847,
				npcId = 5000038,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Behav_Love",
				animCfg = {
					[1] = "Behav_Love",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 42
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
						nodeId = 43
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Cheer_Start",
				staticIdVInput = -346013045,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200028,
				processingTime = 5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Cheer_Start",
					"Emotion_Cheer_Loop",
					"Emotion_Cheer_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogsetCameraIdVInput = 91254696,
				dialogueIdVInput = 9107014,
				lookAtIdVInput = 5000038
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -346013045,
				npcId = 5200028,
				matchAudioDuration = true,
				duration = 4.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Cheer_Loop",
				animCfg = {
					[1] = "Emotion_Cheer_Loop",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 46
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 228
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107015,
				lookAtIdVInput = 5000038
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -849169900,
				npcId = 5200026,
				matchAudioDuration = true,
				duration = 6.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Applaud",
				animCfg = {
					[1] = "TalkUpper_Applaud",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 47
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
						nodeId = 49
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
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Cheeksupport_Start",
				staticIdVInput = -2131311940,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200027,
				processingTime = 4.9,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Talk_Cheeksupport_Start",
					"Talk_Cheeksupport_Loop",
					"Talk_Cheeksupport_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107016,
				lookAtIdVInput = 5000038
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -2131311940,
				npcId = 5200027,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Cheeksupport",
				animCfg = {
					[1] = "TalkUpper_Cheeksupport",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 9107017,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 5.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Amazed",
				animCfg = {
					[1] = "Emotion_Amazed",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -312948930
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = -1867953040
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 281
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 281
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
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
			kind = 20,
			inputs = {
				staticIdVInput = -1867953040,
				isFadeInVInput = true
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
			kind = 53,
			inputs = {
				cameraIdVInput = 91247744
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 55
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
						nodeId = 56
					}
				},
				["1"] = {
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
				dialogueIdVInput = 9107018
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3.88,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1867953040,
				maxLimitTimeVInput = 2
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 282
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 282
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "In",
						nodeId = 58
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
						nodeId = 59
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 227
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107019
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -1,
				npcId = 5200029,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Behav_Love",
				animCfg = {
					[1] = "Behav_Love",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 60
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
						nodeId = 61
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 226
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogsetCameraIdVInput = 91254696,
				dialogueIdVInput = 9107020,
				lookAtIdVInput = 5200029
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -2131311940,
				npcId = 5200027,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Applaud",
				animCfg = {
					[1] = "TalkUpper_Applaud",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 62
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
						nodeId = 63
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 225
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107021,
				lookAtIdVInput = 5200029
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -346013045,
				npcId = 5200028,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Cheer_Loop",
				animCfg = {
					[1] = "Emotion_Cheer_Loop",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 64
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
						nodeId = 65
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 224
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107022,
				lookAtIdVInput = 5200029
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -849169900,
				npcId = 5200026,
				matchAudioDuration = true,
				duration = 9.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Confused",
				animCfg = {
					[1] = "TalkUpper_Confused",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 9107023,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 2.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Amazed",
				animCfg = {
					[1] = "Emotion_Amazed",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1867953040
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
			kind = 20,
			inputs = {
				staticIdVInput = -1049775534,
				isFadeInVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1049775534
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 283
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 283
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
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
			kind = 53,
			inputs = {
				cameraIdVInput = 91247750
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
						nodeId = 72
					}
				},
				["1"] = {
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
				dialogueIdVInput = 9107024
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3.38,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1049775534
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 284
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 284
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						nodeId = 75
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 223
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107025
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = 0,
				npcId = 5200025,
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
						nodeId = 76
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
						nodeId = 222
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogsetCameraIdVInput = 91254696,
				dialogueIdVInput = 9107026,
				lookAtIdVInput = 5200025
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -849169900,
				npcId = 5200026,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Cheer_Loop",
				animCfg = {
					[1] = "Emotion_Cheer_Loop",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 78
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
						nodeId = 79
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 221
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107027,
				lookAtIdVInput = 5200025
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -2131311940,
				npcId = 5200027,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Applaud",
				animCfg = {
					[1] = "TalkUpper_Applaud",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 81
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 220
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107028,
				lookAtIdVInput = 5200025
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -346013045,
				npcId = 5200028,
				matchAudioDuration = true,
				duration = 5.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial04",
				animCfg = {
					[1] = "IdleSpecial04",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				dialogueIdVInput = 9107029,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 9.5,
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
						nodeId = 83
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1049775534
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 84
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
						nodeId = 85
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 216
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -518094810,
				isFadeInVInput = true
			},
			flowIn = {
				In = 0
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
						nodeId = 87
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 212
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -518094810
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 277
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 277
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 88
					}
				}
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91179500,
				cameraMovementTypeVInput = 1,
				cameraMovementTimeVInput = 1.5,
				cameraMovementFuncVInput = 0,
				cameraMovementExpVInput = 0.1,
				cameraMovementAngleVInput = 30,
				cameraMovementVectorVInput = {
					0,
					0,
					-1
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 90
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 208
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 1000,
				playableStateVInput = "Behav_Alert",
				staticIdVInput = -518094810
			},
			fields = {
				templateId = 1003305,
				processingTime = 4.517,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_AlertStart",
					"Behav_AlertLoop",
					"Behav_AlertEnd"
				}
			},
			flowIn = {
				In = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107052
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.38,
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
						nodeId = 92
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 207
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107053
			},
			flowIn = {
				In = 0
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
				portCount = 2
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
						nodeId = 203
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyLoop",
				loopDurationVInput = 5,
				defaultTransStateVInput = "Idle",
				staticIdVInput = -518094810,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 1003305,
				processingTime = 9.367,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 95
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 96
					}
				}
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91254696
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 97
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
						nodeId = 98
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 202
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107031
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -346013045,
				npcId = 5200028,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Shock",
				animCfg = {
					[1] = "Emotion_Shock",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 101
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 100
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Shock",
				staticIdVInput = -849169900
			},
			fields = {
				templateId = 5200026,
				processingTime = 6.233,
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
				dialogueIdVInput = 9107032
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -849169900,
				npcId = 5200026,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Shock",
				animCfg = {
					[1] = "Emotion_Shock",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 102
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
						nodeId = 103
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 201
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107033
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -2131311940,
				npcId = 5200027,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Shock",
				animCfg = {
					[1] = "Emotion_Shock",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 105
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 200
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107034,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Shock",
				animCfg = {
					[1] = "Emotion_Shock",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107035,
				dialogsetCameraIdVInput = 91248321
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 5.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Applaud",
				animCfg = {
					[1] = "TalkUpper_Applaud",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 124
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 108
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
			kind = 14,
			inputs = {
				staticIdVInput = -346013045
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 291
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 291
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 109
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -2131311940
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 292
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 292
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
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
			kind = 14,
			inputs = {
				staticIdVInput = -849169900
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 293
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 293
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
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
			kind = 14,
			inputs = {
				staticIdVInput = -1490126528
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 294
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 294
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -312948930,
				isFadeInVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 113
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1867953040,
				isFadeInVInput = true
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
			kind = 20,
			inputs = {
				staticIdVInput = -1049775534,
				isFadeInVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 115
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -518094810,
				isFadeInVInput = true
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = -312948930
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 295
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 295
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
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
			kind = 14,
			inputs = {
				staticIdVInput = -1867953040
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 296
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 296
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = -1049775534
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 297
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 297
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 119
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -518094810
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 298
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 298
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 120
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1256340114
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 307
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 307
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 121
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -582139008
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 307
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 307
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 122
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -931972559
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 307
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 307
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 123
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -525904627
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 307
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 307
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107051,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -1,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5,
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
						nodeId = 125
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107064,
				dialogsetCameraIdVInput = 91222844
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 3.75,
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
						nodeId = 126
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107065,
				dialogsetCameraIdVInput = 91248276
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 127
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
						nodeId = 128
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 199
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107066,
				dialogsetCameraIdVInput = 91248276
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -346013045,
				npcId = 5200028,
				matchAudioDuration = true,
				duration = 5.62,
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
						nodeId = 129
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107067,
				dialogsetCameraIdVInput = 91248279
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 130
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
						nodeId = 132
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 131
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Helpless",
				staticIdVInput = -2131311940
			},
			fields = {
				templateId = 5200027,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107068,
				dialogsetCameraIdVInput = 91248279
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -2131311940,
				npcId = 5200027,
				matchAudioDuration = true,
				duration = 5.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Helpless",
				animCfg = {
					[1] = "Emotion_Helpless",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 9107069,
				dialogsetCameraIdVInput = 91248282
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 134
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
						nodeId = 135
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 198
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107070,
				dialogsetCameraIdVInput = 91248282
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -849169900,
				npcId = 5200026,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Emotion_Helpless",
				animCfg = {
					[1] = "Emotion_Helpless",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 136
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107071,
				dialogsetCameraIdVInput = 91248309
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 2.25,
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
						nodeId = 137
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
						nodeId = 138
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 197
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107072,
				dialogsetCameraIdVInput = 91248309
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 5200023,
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
						nodeId = 139
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107073,
				dialogsetCameraIdVInput = 91248309
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 3.75,
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
						nodeId = 140
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
						nodeId = 141
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 147
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 154
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -312948930
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 142
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1867953040
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 143
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1049775534
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 144
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -346013045
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
			kind = 20,
			inputs = {
				staticIdVInput = -2131311940
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 146
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -849169900
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1490126528
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 299
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 299
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 148
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -518094810
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 300
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 300
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 149
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -341274847
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 301
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 301
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 150
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1256340114
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 308
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 308
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 151
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -582139008
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 308
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 308
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 152
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -931972559
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 308
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 308
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 153
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -525904627
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 308
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 308
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91248321
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 155
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107048
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 5200023,
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
						nodeId = 156
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
						nodeId = 157
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
						nodeId = 158
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
						nodeId = 160
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 159
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 195
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 196
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1490126528,
				lookAtEntityStaticIdVInput = -341274847
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91256185,
				cameraMovementTypeVInput = 1,
				cameraMovementTimeVInput = 5,
				cameraMovementVectorVInput = {
					0,
					1,
					0
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 161
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
						nodeId = 162
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107074,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 6.5,
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
						nodeId = 163
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107036,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 0,
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
						nodeId = 164
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107037,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 0,
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
						nodeId = 165
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 194
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107038
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 166
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107040,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 3,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false,
				chatType = 0,
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
						nodeId = 167
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 193
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107041
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 168
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107043,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 3,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 7.88,
				disableCamera = false,
				chatType = 0,
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
						nodeId = 169
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 192
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107044
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 170
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107046,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 7.5,
				disableCamera = false,
				chatType = 0,
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
						nodeId = 171
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107093,
				dialogsetCameraIdVInput = 91254963
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 172
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
						nodeId = 173
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 176
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 186
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 187
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 188
					}
				}
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1490126528
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 174
					}
				}
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -341274847
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 175
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogsetCameraBlendInTimeVInput = 1,
				dialogsetCameraIdVInput = 91254968,
				dialogueIdVInput = 9107075
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -341274847,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1490126528
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 302
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 302
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						nodeId = 177
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 6,
				maxAwaitTime = -1
			},
			flowIn = {
				["5"] = 0,
				["4"] = 0,
				["3"] = 0,
				["2"] = 0,
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 178
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					178.203,
					0
				},
				targetPositionVInput = {
					52.034,
					40.013,
					460.94
				}
			},
			fields = {
				setRotation = false,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 179
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 7,
				param = {
					snapshot = false,
					photoMode = "dialogue"
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						portId = "In",
						nodeId = 181
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 180
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 20
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "closeUIFInput",
						nodeId = 179
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
						nodeId = 182
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 185
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107077,
				dialogsetCameraIdVInput = 91254968
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 183
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107047,
				dialogsetCameraIdVInput = 91254968
			},
			fields = {
				portCount = 1,
				skipTime = 2,
				npcStaticId = -341274847,
				npcId = 5200023,
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
						nodeId = 184
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9107076,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 6,
				npcStaticId = -1,
				npcId = 5200023,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				staticIdVInput = -341274847,
				playableStateVInput = "Emotion_Applaud02_Start",
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5200023,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud02_Start",
					"Emotion_Applaud02_Loop",
					"Emotion_Applaud02_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -518094810,
				maxLimitTimeVInput = 3,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 303
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 303
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						nodeId = 177
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -341274847,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 304
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 304
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1256340114,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 303
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 303
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "2",
						nodeId = 177
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 189
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -582139008,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 303
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 303
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "3",
						nodeId = 177
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 190
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -931972559,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 303
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 303
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "4",
						nodeId = 177
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 191
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -525904627,
				autoPathfindingVInput = true
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 303
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 303
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
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
							value = 1,
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
						portId = "5",
						nodeId = 177
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107045
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 170
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107042
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 168
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 9107039
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 166
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -341274847,
				lookAtEntityStaticIdVInput = -1490126528
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 309
				},
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 310
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 310
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Thankful",
				staticIdVInput = -1490126528
			},
			fields = {
				templateId = 401,
				processingTime = 7.967,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Sigh",
				animationLayerVInput = 4,
				staticIdVInput = -849169900
			},
			fields = {
				templateId = 5200022,
				processingTime = 5.5,
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
				playStartLoopEndVInput = true,
				staticIdVInput = -346013045,
				playableStateVInput = "Emotion_Cry_Start",
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5200028,
				processingTime = 3.433,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Cry_Start",
					"Emotion_Cry_Loop",
					"Emotion_Cry_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -341274847,
				facialEmotionVInput = "Excited"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Shock",
				staticIdVInput = -2131311940
			},
			fields = {
				templateId = 5200027,
				processingTime = 4.333,
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
				playableStateVInput = "Emotion_Shock",
				staticIdVInput = -346013045
			},
			fields = {
				templateId = 5200028,
				processingTime = 6.233,
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
				playableStateVInput = "Behav_HappyLoop",
				loopDurationVInput = 5,
				defaultTransStateVInput = "Idle",
				staticIdVInput = -1256340114,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 1003305,
				processingTime = 9.367,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 204
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyLoop",
				loopDurationVInput = 5,
				defaultTransStateVInput = "Idle",
				staticIdVInput = -582139008,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 1003305,
				processingTime = 9.367,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 205
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyLoop",
				loopDurationVInput = 5,
				defaultTransStateVInput = "Idle",
				staticIdVInput = -931972559,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 1003305,
				processingTime = 9.367,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 206
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyLoop",
				loopDurationVInput = 5,
				defaultTransStateVInput = "Idle",
				staticIdVInput = -525904627,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 1003305,
				processingTime = 9.367,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
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
			kind = 7,
			fields = {
				dialogueId = 9107054
			},
			flowIn = {
				In = 0
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
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 1000,
				playableStateVInput = "Behav_Alert",
				staticIdVInput = -1256340114
			},
			fields = {
				templateId = 1003305,
				processingTime = 4.517,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_AlertStart",
					"Behav_AlertLoop",
					"Behav_AlertEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 209
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 1000,
				playableStateVInput = "Behav_Alert",
				staticIdVInput = -582139008
			},
			fields = {
				templateId = 1003305,
				processingTime = 4.517,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_AlertStart",
					"Behav_AlertLoop",
					"Behav_AlertEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 210
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 1000,
				playableStateVInput = "Behav_Alert",
				staticIdVInput = -931972559
			},
			fields = {
				templateId = 1003305,
				processingTime = 4.517,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_AlertStart",
					"Behav_AlertLoop",
					"Behav_AlertEnd"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 211
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 1000,
				playableStateVInput = "Behav_Alert",
				staticIdVInput = -525904627
			},
			fields = {
				templateId = 1003305,
				processingTime = 4.517,
				playAniType = 1,
				isLooping = true,
				entityType = 1,
				aniStateList = {
					"Behav_AlertStart",
					"Behav_AlertLoop",
					"Behav_AlertEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1256340114
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 277
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 277
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 213
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -582139008
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 277
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 277
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 214
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -931972559
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 277
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 277
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 215
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -525904627
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 277
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 277
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				staticIdVInput = -1256340114,
				durationVInput = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 217
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				staticIdVInput = -582139008,
				durationVInput = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 218
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				staticIdVInput = -931972559,
				durationVInput = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 219
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				staticIdVInput = -525904627,
				durationVInput = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Applaud02_Start",
				staticIdVInput = -346013045,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200028,
				processingTime = 3.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud02_Start",
					"Emotion_Applaud02_Loop",
					"Emotion_Applaud02_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Applaud_Start",
				staticIdVInput = -2131311940,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200027,
				processingTime = 4.9,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud_Start",
					"Emotion_Applaud_Loop",
					"Emotion_Applaud_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Cheer_End",
				staticIdVInput = -849169900,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200022,
				processingTime = 5.5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Cheer_Start",
					"Emotion_Cheer_Loop",
					"Emotion_Cheer_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial",
				staticIdVInput = -1049775534,
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5200025,
				processingTime = 6.917,
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
				playableStateVInput = "Talk_Cheeksupport",
				staticIdVInput = -849169900
			},
			fields = {
				templateId = 5200022,
				processingTime = 5.5,
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
				playStartLoopEndVInput = true,
				staticIdVInput = -346013045,
				playableStateVInput = "Emotion_Applaud02_Start",
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5200028,
				processingTime = 5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud02_Start",
					"Emotion_Applaud02_Loop",
					"Emotion_Applaud02_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Cheer_Start",
				staticIdVInput = -2131311940,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200027,
				processingTime = 4.9,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Cheer_Start",
					"Emotion_Cheer_Loop",
					"Emotion_Cheer_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Love",
				staticIdVInput = -1867953040,
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5200029,
				processingTime = 5,
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
				playableStateVInput = "Emotion_Applaud_Start",
				staticIdVInput = -849169900,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5200022,
				processingTime = 3.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud_Start",
					"Emotion_Applaud_Loop",
					"Emotion_Applaud_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial",
				staticIdVInput = -312948930,
				defaultTransStateVInput = "Idle"
			},
			fields = {
				templateId = 5000038,
				processingTime = 3.967,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1867953040
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 231
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1049775534
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 232
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -518094810
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 233
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1256340114
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 234
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -582139008
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 235
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -931972559
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 236
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -525904627
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Amazed",
				staticIdVInput = -346013045
			},
			fields = {
				templateId = 5200028,
				processingTime = 5,
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
				slotParamVInput = 5000038,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 278
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 278
				}
			},
			fields = {
				entityId = -312948930,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 239
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200029,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 279
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 279
				}
			},
			fields = {
				entityId = -1867953040,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 240
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200025,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 280
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 280
				}
			},
			fields = {
				entityId = -1049775534,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 241
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					178.203,
					0
				},
				targetPositionVInput = {
					52.034,
					40.013,
					460.94
				}
			},
			fields = {
				setRotation = false,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 238
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 239
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 240
				},
				["4EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 243
				},
				["5EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 244
				},
				["6EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 245
				},
				["7EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 246
				},
				["8EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 247
				}
			},
			fields = {
				portCount = 8
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200028,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 285
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 285
				}
			},
			fields = {
				entityId = -346013045,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 244
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200027,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 286
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 286
				}
			},
			fields = {
				entityId = -2131311940,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 245
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200022,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 287
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 287
				}
			},
			fields = {
				entityId = -849169900,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 246
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200023,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 288
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 288
				}
			},
			fields = {
				entityId = -341274847,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 247
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 1
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 290
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 290
				}
			},
			fields = {
				entityId = -1490126528,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
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
						nodeId = 249
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 267
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 268
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PET_BATTLE_TAG",
					nil,
					{
						[1] = 1
					},
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "0",
						nodeId = 250
					}
				},
				True = {
					{
						portId = "0",
						nodeId = 266
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 3,
				maxAwaitTime = -1
			},
			flowIn = {
				["2"] = 0,
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 251
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
						nodeId = 252
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 265
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PET_BATTLE_TAG",
					nil,
					{
						[1] = 1
					},
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "0",
						nodeId = 253
					}
				},
				True = {
					{
						portId = "0",
						nodeId = 263
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
						nodeId = 254
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
						nodeId = 255
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 257
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 259
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 261
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1036100,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				True = {
					{
						portId = "In",
						nodeId = 256
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200050,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 289
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 289
				}
			},
			fields = {
				entityId = -1256340114,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1036300,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				True = {
					{
						portId = "In",
						nodeId = 258
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200052,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 289
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 289
				}
			},
			fields = {
				entityId = -931972559,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1037100,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				True = {
					{
						portId = "In",
						nodeId = 260
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200051,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 289
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 289
				}
			},
			fields = {
				entityId = -582139008,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1037300,
					nil,
					"=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				True = {
					{
						portId = "In",
						nodeId = 262
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200053,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 289
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 289
				}
			},
			fields = {
				entityId = -525904627,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 30,
			fields = {
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
						nodeId = 264
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 3
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 289
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 289
				}
			},
			fields = {
				entityId = -518094810,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PET_BATTLE_TAG",
					nil,
					{
						[1] = 1
					},
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "1",
						nodeId = 253
					}
				},
				True = {
					{
						portId = "1",
						nodeId = 263
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 3
			},
			flowIn = {
				["2"] = 0,
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 264
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PET_BATTLE_TAG",
					nil,
					{
						[1] = 1
					},
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "1",
						nodeId = 250
					}
				},
				True = {
					{
						portId = "1",
						nodeId = 266
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PET_BATTLE_TAG",
					nil,
					{
						[1] = 1
					},
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "2",
						nodeId = 250
					}
				},
				True = {
					{
						portId = "2",
						nodeId = 266
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
						nodeId = 270
					}
				}
			}
		},
		{
			kind = 53,
			inputs = {
				cameraMovementTypeVInput = 1,
				blendInTimeVInput = 0,
				cameraMovementTimeVInput = 4,
				cameraIdVInput = 91254176,
				cameraMovementVectorVInput = {
					0,
					1,
					0
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247721,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179395,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247762,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247763,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247764,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247765,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179395,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244132,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244137,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244146,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247721,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179395,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247721,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179395,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179745,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179679,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179675,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179760,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247646,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179672,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179745,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179679,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179675,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91179672,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244132,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244137,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91244146,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91247646,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91254878,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91255451,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91254904,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91255379,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91254902,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91257127,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		[307] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91247646,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		[308] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91255451,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		},
		[309] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[310] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91254878,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91179394
			}
		}
	}
}
