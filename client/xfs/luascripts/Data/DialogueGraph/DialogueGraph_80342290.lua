-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_80342290.lua

return {
	schema = 1,
	startNodeId = 5,
	dialogueId = 80342290,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 5
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 4
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 3
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 2
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 1
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
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 74978220
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 50,
					portId = "EntityID"
				}
			},
			fields = {
				enableDefaultLookAt = true,
				cameraPreset = 0,
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 0,
				enableGroupLookAt = true
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
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 51,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 9,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 52,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 10,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 53,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 11,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 31,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 54,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 55,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 54,
			valueIn = {
				conditionVInput = {
					nodeId = 56,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				True = {
					{
						nodeId = 14,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 0,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 15,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005243
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = -1,
				npcId = 202062,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 0,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005274
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005276
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 19,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005277
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005278
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005279
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 1,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005266
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005267
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005268
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005269
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005270
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005271
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005272
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005273
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 1,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 2,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005256
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005257
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005258
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005259
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005260
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005261
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 2,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 3,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 39,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005245
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005246
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005247
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005248
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005249
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005250
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005251
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = 83534872,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 3,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 4,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005241
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 50,
					portId = "EntityID"
				}
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = -1,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 48,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005242
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 50,
					portId = "EntityID"
				}
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Idle",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = -1,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "Idle",
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
				ShowFinOut = {
					{
						nodeId = 49,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005243
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 50,
					portId = "EntityID"
				}
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				skipTime = 0.5,
				portCount = 1,
				npcStaticId = -1,
				npcId = 202052,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				animCfg = {
					[1] = "IdleSpecial",
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
				ShowFinOut = {
					{
						nodeId = 4,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 17,
			inputs = {
				boneNameVInput = "Bip001 Head",
				staticIdVInput = 83534872
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "isOpen"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "isFirst"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "IsSecond"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "isThird"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "isForth"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "IsFined"
			}
		}
	},
	blackboard = {
		isOpen = true,
		IsFined = false,
		isForth = false,
		isThird = false,
		IsSecond = false,
		isFirst = false
	}
}
