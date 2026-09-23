-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_84822532.lua

return {
	dialogueId = 84822532,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005331
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005332
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005333
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005334
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005335
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005336
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 9
				}
			},
			fields = {
				disableCamera = false,
				portCount = 1,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0.5,
				anim = "EnvBehav_ScreenShowStart",
				npcStaticId = -1,
				npcId = 401050,
				matchAudioDuration = true,
				duration = 2,
				animCfg = {
					[1] = "EnvBehav_ScreenShowStart",
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 84786699,
				boneNameVInput = "Bip001 Head"
			},
			fields = {
				entityType = 2
			}
		}
	}
}
