-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79357904.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 79357904,
	nodes = {
		[0] = {
			kind = 6,
			flowIn = {
				End = true
			}
		},
		{
			kind = 8,
			flowOut = {
				Start = {
					{
						nodeId = 2,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 18,
			inputs = {
				hideAllUIVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				blockCameraZoomVInput = true,
				hideTopLogoVInput = true
			},
			fields = {
				topLogoComs = {
					combat = true,
					chat = true,
					callFriends = true,
					bubble = true,
					alert = true,
					petExchange = true,
					vlog = true,
					teamSpeech = true,
					quest = true,
					photo = true,
					petFertility = true,
					petChat = true,
					npc = true,
					multiPlayer = true
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 60,
			inputs = {
				blendFuctionVInput = 3,
				cameraMovementTimeVInput = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 43502019,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraMovementTimeVInput = 1.5,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-1,
					0,
					0
				}
			},
			fields = {
				npcStaticId = 79274972,
				duration = 4,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 43502014,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraIdVInput = 79358706,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementTimeVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				npcStaticId = 79274972,
				duration = 2,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 43502015,
				dialogsetCameraMovementModeVInput = 1,
				dialogsetCameraIdVInput = 79358706,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraMovementTimeVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				npcStaticId = 79274972,
				npcId = 0,
				duration = 2,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 43502016,
				dialogsetCameraMovementModeVInput = 2,
				dialogsetCameraIdVInput = 79358706,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraMovementTimeVInput = 2,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				npcStaticId = 79274972,
				duration = 3,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		}
	}
}
