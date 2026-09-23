-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_80541075.lua

return {
	dialogueId = 80541075,
	schema = 1,
	startNodeId = 2,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 1
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
				modeInfo = {
					blockEvent = false,
					modeType = 1,
					blockCameraZoom = false,
					hideTopLogo = true,
					hideMarkShare = false,
					hideInteractionSign = true,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = false,
					exitCatchMode = true,
					resetAllActions = true,
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
				Out = {
					{
						portId = "In",
						nodeId = 4
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
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				modeInfo = {
					blockEvent = false,
					modeType = 1,
					blockCameraZoom = false,
					hideTopLogo = true,
					hideMarkShare = false,
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = false,
					exitCatchMode = false,
					resetAllActions = false,
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
				Out = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					160.795,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 35
				}
			},
			fields = {
				reset = false
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityID",
					nodeId = 36
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 3,
				nodeMode = 0,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
					{
						portId = "In",
						nodeId = 8
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
					">",
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
						nodeId = 9
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202055
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202056
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202057
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6202058
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 2,
				skipTime = 0,
				duration = 9,
				disableCamera = false,
				chatType = 3
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 17
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6202059
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202335
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 5.62,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 15
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
				["1"] = 0,
				["0"] = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202337
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 7.62,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "End",
						nodeId = 1
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6202334
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202336
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 9.38,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "1",
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202065
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202066
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202067
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 2,
				disableCamera = false,
				chatType = 3
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
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6202068
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 2,
				skipTime = 0,
				duration = 11,
				disableCamera = false,
				chatType = 3
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
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6202069
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202339
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 4.38,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 25
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
				["1"] = 0,
				["0"] = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202341
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 3.62,
				disableCamera = false,
				chatType = 3
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
				dialogueIdVInput = 6202342
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 5.25,
				disableCamera = false,
				chatType = 3
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
				dialogueIdVInput = 6202343
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 5.75,
				disableCamera = false,
				chatType = 3
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
			kind = 7,
			fields = {
				dialogueId = 6202338
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202340
			},
			fields = {
				matchAudioDuration = true,
				blackScreenIntervalTime = 2,
				npcStaticId = 79229255,
				npcId = 400204,
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				duration = 11.75,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "1",
						nodeId = 25
					}
				}
			}
		},
		[35] = {
			kind = 17,
			fields = {
				entityType = 0
			}
		},
		[36] = {
			kind = 17,
			inputs = {
				staticIdVInput = 82747709
			},
			fields = {
				entityType = 2
			}
		}
	}
}
