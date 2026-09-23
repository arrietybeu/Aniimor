-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_83579282.lua

return {
	dialogueId = 83579282,
	schema = 1,
	startNodeId = 3,
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
			kind = 25,
			fields = {
				condition = {
					"CONTROL_PET_RACE",
					1002600,
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
						nodeId = 5
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712161
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
						portId = "In",
						nodeId = 7
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712230
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = -1,
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
						nodeId = 8
					}
				},
				["1"] = {
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
				dialogueId = 3712231
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 89
					}
				},
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
				portCount = 5
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
				["1"] = {
					{
						portId = "In",
						nodeId = 162
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 158
					}
				},
				["3"] = {
					{
						portId = "Play",
						nodeId = 166
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 167
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
						nodeId = 14
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
						nodeId = 15
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3712233
			},
			fields = {
				skipTime = 4,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 16
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
						nodeId = 17
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 153
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712234
			},
			fields = {
				skipTime = 2,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 3,
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 150
					}
				},
				ShowFinOut = {
					{
						portId = "In",
						nodeId = 151
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712235
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
						nodeId = 148
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712237
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 21
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
						nodeId = 146
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712238
			},
			fields = {
				skipTime = 2,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 24
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 145
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712239
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 25
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 144
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712240
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
						nodeId = 27
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 142
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712242
			},
			fields = {
				skipTime = 2,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 29
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 136
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 138
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 140
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712243
			},
			fields = {
				skipTime = 3,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 30
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
						nodeId = 31
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 134
					}
				},
				["2"] = {
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
				dialogueIdVInput = 3712244
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712245
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
				portCount = 2
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
						portId = "In",
						nodeId = 132
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712246
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 7.62,
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 127
					}
				},
				ShowFinOut = {
					{
						portId = "In",
						nodeId = 128
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712247
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
						nodeId = 126
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712249,
				lookAtIdVInput = 500139
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 38
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
						nodeId = 39
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3712250,
				lookAtIdVInput = 500138
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
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
						nodeId = 124
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712251,
				lookAtIdVInput = 500139
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 43
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 123
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				lookAtIdVInput = 500139,
				dialogueIdVInput = 3712252
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 44
					}
				},
				["1"] = {
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
				dialogueId = 3712253
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
						nodeId = 118
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712255
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 47
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
						nodeId = 48
					}
				},
				["1"] = {
					{
						portId = "StopDof",
						nodeId = 118
					}
				},
				["2"] = {
					{
						portId = "StopDof",
						nodeId = 119
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 120
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712256
			},
			fields = {
				skipTime = 3,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 8.88,
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
				In = 0
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
						nodeId = 116
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712257
			},
			fields = {
				skipTime = 2,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 51
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
						nodeId = 52
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 115
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712258
			},
			fields = {
				skipTime = 2,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 17,
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
						nodeId = 53
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 112
					}
				},
				ShowFinOut = {
					{
						portId = "In",
						nodeId = 113
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712259
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
						nodeId = 55
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 110
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712261
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 56
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712262
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 57
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
			kind = 7,
			fields = {
				dialogueId = 3712263
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 58
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712265
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 59
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
						nodeId = 60
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 107
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712266
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712267
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 3,
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
						nodeId = 105
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712268
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 64
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 104
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712269
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 65
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
						nodeId = 66
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 102
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712271
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712272
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 68
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712273
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712274
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 70
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712275
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 71
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712276
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
						nodeId = 72
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3712277
			},
			fields = {
				skipTime = 0,
				portCount = 2,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 73
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 99
					}
				},
				ShowFinOut = {
					{
						portId = "In",
						nodeId = 100
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712278
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
						nodeId = 75
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 97
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712280
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 0,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712281
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 77
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
						nodeId = 78
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3712282
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 3,
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
						nodeId = 79
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
						nodeId = 80
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 94
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712283,
				lookAtIdVInput = 500139
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 81
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
						nodeId = 82
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 93
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712284,
				lookAtIdVInput = 500138
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
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
						nodeId = 83
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
						nodeId = 84
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712285,
				lookAtIdVInput = 500139
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
				matchAudioDuration = true,
				duration = 3,
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
						nodeId = 85
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
						nodeId = 86
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3712286,
				lookAtIdVInput = 500138
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
				matchAudioDuration = true,
				duration = 3,
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
						nodeId = 87
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712287,
				lookAtIdVInput = 500139
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500138,
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
						nodeId = 88
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3712288,
				lookAtIdVInput = 500138
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 500139,
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
						nodeId = 89
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
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-684.715,
					27.175,
					1939.73
				},
				rotationVInput = {
					2.2,
					50.49,
					-0.002
				}
			},
			fields = {
				cameraId = 90871535,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 221,
				fStop = 32
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 91
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				fovVInput = 25,
				positionVInput = {
					-684.387,
					27.159,
					1940.001
				},
				rotationVInput = {
					2,
					50.16,
					-0.002
				}
			},
			fields = {
				cameraId = 90871536,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 221,
				fStop = 32
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
					-684.142,
					27.142,
					1936.452
				},
				rotationVInput = {
					362,
					105.843,
					0
				}
			},
			fields = {
				cameraId = 90871534,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 221,
				fStop = 15.2
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
					-684.715,
					27.175,
					1939.73
				},
				rotationVInput = {
					2.2,
					50.49,
					-0.002
				}
			},
			fields = {
				cameraId = 90871527,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 221,
				fStop = 15.2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871530,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-682.895,
					26.883,
					1938.686
				},
				rotationVInput = {
					358.941,
					348.1,
					0
				}
			},
			fields = {
				cameraId = 90871528,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 255,
				fStop = 14.78
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 96
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				fovVInput = 35,
				positionVInput = {
					-682.981,
					26.999,
					1939.159
				},
				rotationVInput = {
					358.941,
					348.1,
					0
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 255,
				fStop = 14.78
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871529,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 98
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 35,
				positionVInput = {
					-684.624,
					26.972,
					1935.719
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712279
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-687.313,
					26.613,
					1937.19
				},
				rotationVInput = {
					355.616,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 228,
				fStop = 16.97
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 101
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				fovVInput = 25,
				positionVInput = {
					-687.474,
					26.645,
					1937.579
				},
				rotationVInput = {
					354.929,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 23.23
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					-693.201,
					26.79,
					1933.786
				},
				rotationVInput = {
					355.7,
					62.527,
					0
				}
			},
			fields = {
				cameraId = 90871522,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 503,
				fStop = 4.84
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				blendTimeVInput = 60,
				fovVInput = 38,
				positionVInput = {
					-690.63,
					26.79,
					1930.887
				},
				rotationVInput = {
					356.5,
					42.073,
					0
				}
			},
			fields = {
				cameraId = 90871523,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 503,
				fStop = 4.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712270
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 106
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 35,
				positionVInput = {
					-684.624,
					26.972,
					1935.719
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-682.895,
					26.883,
					1938.686
				},
				rotationVInput = {
					358.941,
					348.1,
					0
				}
			},
			fields = {
				cameraId = 90871516,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 255,
				fStop = 14.78
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 108
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				fovVInput = 35,
				positionVInput = {
					-682.981,
					26.999,
					1939.159
				},
				rotationVInput = {
					358.941,
					348.1,
					0
				}
			},
			fields = {
				cameraId = 90871519,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 255,
				fStop = 14.78
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712264
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 58
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871515,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
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
				blendTimeVInput = 15,
				fovVInput = 35,
				positionVInput = {
					-684.624,
					26.972,
					1935.719
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712260
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-687.313,
					26.613,
					1937.19
				},
				rotationVInput = {
					355.616,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 91104417,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 228,
				fStop = 16.97
			},
			flowIn = {
				In = 0
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
				blendTimeVInput = 8,
				fovVInput = 25,
				positionVInput = {
					-687.474,
					26.645,
					1937.579
				},
				rotationVInput = {
					354.929,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 23.23
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 40,
				positionVInput = {
					-643.779,
					28.415,
					2009.857
				},
				rotationVInput = {
					0.788,
					233.769,
					0
				}
			},
			fields = {
				cameraId = 91104445,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 40,
				positionVInput = {
					-640.412,
					28.43,
					2005.643
				},
				rotationVInput = {
					1.991,
					236.863,
					0
				}
			},
			fields = {
				cameraId = 91104441,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 117
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 40,
				positionVInput = {
					-641.985,
					28.43,
					2008.053
				},
				rotationVInput = {
					1.991,
					236.863,
					0
				}
			},
			fields = {
				cameraId = 91104442,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					-687.088,
					26.399,
					1937.227
				},
				rotationVInput = {
					358.5,
					94.7,
					-0.002
				}
			},
			fields = {
				cameraId = 91104424,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 497,
				fStop = 7.02
			},
			flowIn = {
				StopDof = 1,
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 119
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 38,
				positionVInput = {
					-686.693,
					26.41,
					1937.195
				},
				rotationVInput = {
					358.5,
					94.7,
					-0.002
				}
			},
			fields = {
				cameraId = 91104425,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 497,
				fStop = 7.02
			},
			flowIn = {
				StopDof = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-637.943,
					28.43,
					2001.861
				},
				rotationVInput = {
					1.991,
					236.863,
					0
				}
			},
			fields = {
				cameraId = 91104422,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
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
				blendTimeVInput = 10,
				fovVInput = 40,
				positionVInput = {
					-639.133,
					28.43,
					2003.684
				},
				rotationVInput = {
					1.991,
					236.863,
					0
				}
			},
			fields = {
				cameraId = 91104428,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712254
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				positionVInput = {
					-683.102,
					26.67,
					1930.479
				},
				rotationVInput = {
					358.7,
					3.62,
					-0.002
				}
			},
			fields = {
				cameraId = 90871398,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 607,
				fStop = 6.76
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
					-683.644,
					27.376,
					1935.998
				},
				rotationVInput = {
					6.58,
					95.57,
					-0.002
				}
			},
			fields = {
				cameraId = 90871397,
				sensorWidth = 226,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 138,
				fStop = 24.56
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
					-684.715,
					27.175,
					1939.73
				},
				rotationVInput = {
					2.2,
					50.49,
					-0.002
				}
			},
			fields = {
				cameraId = 90871383,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 221,
				fStop = 15.2
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
					-683.102,
					26.67,
					1930.479
				},
				rotationVInput = {
					358.7,
					3.62,
					-0.002
				}
			},
			fields = {
				cameraId = 90871381,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 607,
				fStop = 6.76
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712248
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
						portId = "Stop",
						nodeId = 129
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 130
					}
				}
			}
		},
		{
			kind = 46,
			fields = {
				volumeComponentCount = 3,
				volumeComponents = {
					{
						typeName = "VignetteComponent",
						active = true,
						parameters = {
							m_VignetteColor = {
								valueType = "color",
								overrideState = true,
								value = {
									b = 0,
									r = 0,
									g = 0,
									a = 1
								}
							},
							m_EdgeWidth = {
								valueType = "float",
								value = 0.401,
								overrideState = true
							},
							m_EdgeSoftness = {
								valueType = "float",
								value = 0.329,
								overrideState = true
							},
							m_VignetteAlpha = {
								valueType = "float",
								value = 1,
								overrideState = true
							},
							m_FisheyeFovDeg = {
								valueType = "float",
								value = 0,
								overrideState = true
							},
							m_FollowAspect = {
								valueType = "bool",
								value = true,
								overrideState = true
							}
						}
					},
					{
						typeName = "ColorFilterComponent",
						active = true,
						parameters = {
							m_FilterColor = {
								valueType = "color",
								overrideState = true,
								value = {
									b = 0.06087574,
									r = 0.6792453,
									g = 0.3002446,
									a = 1
								}
							},
							m_Brightness = {
								valueType = "float",
								value = 1.5,
								overrideState = true
							},
							m_Saturation = {
								valueType = "float",
								value = 0.77,
								overrideState = true
							},
							m_Contrast = {
								valueType = "float",
								value = 1,
								overrideState = true
							},
							m_CullCharacter = {
								valueType = "bool",
								value = false,
								overrideState = true
							},
							m_ColorFilterAlpha = {
								valueType = "float",
								value = 1,
								overrideState = true
							}
						}
					},
					{
						typeName = "DiaphragmDepthOfFieldComponent",
						active = true,
						parameters = {
							m_FocalDistance = {
								valueType = "float",
								value = 5000,
								overrideState = true
							},
							m_FStop = {
								valueType = "float",
								value = 16,
								overrideState = true
							},
							m_SensorWidth = {
								valueType = "float",
								value = 24.576,
								overrideState = true
							},
							m_SqueezeFactor = {
								valueType = "float",
								value = 1,
								overrideState = true
							},
							m_DepthBlurAmount = {
								valueType = "float",
								value = 1,
								overrideState = true
							},
							m_DepthBlurRadius = {
								valueType = "float",
								value = 0,
								overrideState = true
							},
							m_RecombineQuality = {
								valueType = "int",
								value = 0,
								overrideState = true
							},
							m_SmoothGather = {
								valueType = "bool",
								value = false,
								overrideState = true
							},
							m_VisualizeDOF = {
								valueType = "bool",
								value = false,
								overrideState = true
							}
						}
					}
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
				fovVInput = 25,
				positionVInput = {
					-687.313,
					26.613,
					1937.19
				},
				rotationVInput = {
					355.616,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 90871513,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 228,
				fStop = 16.97
			},
			flowIn = {
				In = 0
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
				blendTimeVInput = 8,
				fovVInput = 25,
				positionVInput = {
					-687.474,
					26.645,
					1937.579
				},
				rotationVInput = {
					354.929,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 23.23
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-729.409,
					26.08,
					1969.271
				},
				rotationVInput = {
					8.851,
					299.441,
					-0.002
				}
			},
			fields = {
				cameraId = 90871379,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 387,
				fStop = 8.26
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 133
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 35,
				positionVInput = {
					-729.409,
					26.08,
					1969.271
				},
				rotationVInput = {
					8.851,
					299.441,
					-0.002
				}
			},
			fields = {
				cameraId = 90871377,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 387,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-383.572,
					78.646,
					1966.649
				},
				rotationVInput = {
					344.827,
					142.294,
					-0.002
				}
			},
			fields = {
				cameraId = 90871282,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 10000,
				fStop = 32
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
				blendTimeVInput = 60,
				fovVInput = 40,
				positionVInput = {
					-384.547,
					80.878,
					1955.174
				},
				rotationVInput = {
					344.827,
					140.059,
					-0.002
				}
			},
			fields = {
				cameraId = 90871277,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 10000,
				fStop = 32
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
					-683.277,
					26.081,
					1936.091
				},
				rotationVInput = {
					354.7,
					304.9,
					-0.002
				}
			},
			fields = {
				cameraId = 90871307,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 531,
				fStop = 11.94
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 137
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 25,
				positionVInput = {
					-683.729,
					26.133,
					1936.407
				},
				rotationVInput = {
					354.7,
					305.072,
					-0.002
				}
			},
			fields = {
				cameraId = 90871304,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 531,
				fStop = 11.94
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 500137,
				positionVInput = {
					-732.475,
					24.86,
					1970.407
				},
				rotationVInput = {
					0,
					337.699,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -2140269168
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 139
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				speedVInput = 0.8,
				playableStateVInput = "Behav_Angry",
				playStartLoopEndVInput = true,
				loopDurationVInput = 99999
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 138
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 500137,
				processingTime = 0,
				aniStateList = {
					"Behav_Angry",
					"Behav_Angry",
					"Behav_Angry"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 500141,
				positionVInput = {
					-733.151,
					24.66,
					1972.598
				},
				rotationVInput = {
					0,
					161.012,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -488129701
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 141
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_CryLoop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999999
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 140
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 500141,
				processingTime = 0,
				aniStateList = {
					"Behav_CryLoop",
					"Behav_CryLoop",
					"Behav_CryLoop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					-687.088,
					26.399,
					1937.227
				},
				rotationVInput = {
					358.5,
					94.7,
					-0.002
				}
			},
			fields = {
				cameraId = 90871268,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 497,
				fStop = 7.02
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 143
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 38,
				positionVInput = {
					-686.693,
					26.41,
					1937.195
				},
				rotationVInput = {
					358.5,
					94.7,
					-0.002
				}
			},
			fields = {
				cameraId = 90871404,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 497,
				fStop = 7.02
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712241
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-684.063,
					27.067,
					1935.808
				},
				rotationVInput = {
					358.1,
					89.7,
					-0.001
				}
			},
			fields = {
				cameraId = 90871260,
				sensorWidth = 324,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 194,
				fStop = 16.12
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
					-687.313,
					26.613,
					1937.19
				},
				rotationVInput = {
					355.616,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 228,
				fStop = 16.97
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
				blendTimeVInput = 8,
				fovVInput = 25,
				positionVInput = {
					-687.474,
					26.645,
					1937.579
				},
				rotationVInput = {
					354.929,
					337.6,
					-0.002
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 23.23
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871255,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 149
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 35,
				positionVInput = {
					-684.624,
					26.972,
					1935.719
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871256,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712236
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
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.962,
					26.532,
					1938.391
				},
				rotationVInput = {
					356,
					285.2,
					-0.001
				}
			},
			fields = {
				cameraId = 90871325,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 152
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 18,
				fovVInput = 35,
				positionVInput = {
					-686.533,
					26.577,
					1938.548
				},
				rotationVInput = {
					355.313,
					285.544,
					-0.001
				}
			},
			fields = {
				cameraId = 90871246,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-689.152,
					26.647,
					1937.498
				},
				rotationVInput = {
					1.774,
					49.165,
					-0.001
				}
			},
			fields = {
				cameraId = 90871205,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 190,
				fStop = 13.28
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 154
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				positionVInput = {
					-688.814,
					26.633,
					1937.791
				},
				rotationVInput = {
					1.774,
					49.165,
					-0.001
				}
			},
			fields = {
				cameraId = 90871229,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 190,
				fStop = 13.28
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
						nodeId = 156
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-685.194,
					26.998,
					1935.703
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 0,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 157
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 35,
				positionVInput = {
					-684.624,
					26.972,
					1935.719
				},
				rotationVInput = {
					2.633,
					88.4,
					-0.001
				}
			},
			fields = {
				cameraId = 90871438,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 338,
				fStop = 7.84
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 159
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 177
				}
			},
			fields = {
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 2,
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
					{
						portId = "In",
						nodeId = 160
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-692.638,
					27.394,
					1932.527
				},
				rotationVInput = {
					1.258,
					54.665,
					-0.001
				}
			},
			fields = {
				cameraId = 88797143,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 161
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				positionVInput = {
					-691.343,
					27.359,
					1933.446
				},
				rotationVInput = {
					1.258,
					54.665,
					-0.001
				}
			},
			fields = {
				cameraId = 90871191,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 163
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					111.04,
					0
				},
				targetPositionVInput = {
					-688.234,
					26.168,
					1939.076
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 179
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 164
					}
				}
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
						nodeId = 165
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Sit",
				playStartLoopEndVInput = true,
				loopDurationVInput = 99999
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 179
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 0,
				processingTime = 5,
				aniStateList = {
					"Behav_Sit",
					"Behav_Sit",
					"Behav_Sit"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "BGM_Story_Highlands_Nighttalk"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 180
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3712232
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
		[176] = {
			kind = 9,
			inputs = {
				staticIdVInput = 83572425
			},
			fields = {
				entityType = 2
			}
		},
		[177] = {
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 176
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 178
				}
			},
			fields = {
				portCount = 2
			}
		},
		[178] = {
			kind = 9,
			inputs = {
				staticIdVInput = 83572421
			},
			fields = {
				entityType = 2
			}
		},
		[179] = {
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		[180] = {
			kind = 9,
			inputs = {
				staticIdVInput = 83574158
			},
			fields = {
				entityType = 2
			}
		}
	}
}
