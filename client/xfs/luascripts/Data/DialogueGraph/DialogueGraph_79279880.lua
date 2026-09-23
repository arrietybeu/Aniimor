-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79279880.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 79279880,
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
				blockCameraZoomVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true
			},
			fields = {
				topLogoComs = {
					petExchange = true,
					petChat = true,
					npc = true,
					multiPlayer = true,
					combat = true,
					chat = true,
					callFriends = true,
					bubble = true,
					alert = true,
					vlog = true,
					teamSpeech = true,
					quest = true,
					photo = true,
					petFertility = true
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
				cameraMovementTimeVInput = 5,
				blendFuctionVInput = 3
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
				dialogueIdVInput = 43502018,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraMovementTimeVInput = 1.5,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementExpVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-1,
					0,
					0
				}
			},
			fields = {
				duration = 4,
				chatType = 3,
				npcStaticId = 79274972
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
				dialogsetCameraMovementTimeVInput = 2,
				dialogueIdVInput = 43502009,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraIdVInput = 79354831,
				dialogsetCameraMovementFuncVInput = 0,
				dialogsetCameraMovementExpVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				duration = 3,
				chatType = 3,
				npcStaticId = 79274972
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
				dialogsetCameraMovementTimeVInput = 2,
				dialogueIdVInput = 43502010,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraIdVInput = 79354831,
				dialogsetCameraMovementFuncVInput = 3,
				dialogsetCameraMovementExpVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				duration = 4,
				chatType = 3,
				npcId = 0,
				npcStaticId = 79274972
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
				dialogsetCameraMovementTimeVInput = 2,
				dialogueIdVInput = 43502011,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraIdVInput = 79354831,
				dialogsetCameraMovementFuncVInput = 1,
				dialogsetCameraMovementExpVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				duration = 3,
				chatType = 3,
				npcStaticId = 79274972
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
			kind = 1,
			inputs = {
				dialogsetCameraIdVInput = 79354831,
				dialogueIdVInput = 43502012,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraMovementTimeVInput = 2,
				dialogsetCameraMovementExpVInput = 3,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				duration = 3,
				chatType = 3,
				npcStaticId = 79274972
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogsetCameraMovementTimeVInput = 2,
				dialogueIdVInput = 43502013,
				dialogsetCameraBlendFuctionVInput = 0,
				dialogsetCameraMovementTypeVInput = 1,
				dialogsetCameraIdVInput = 79354831,
				dialogsetCameraMovementFuncVInput = 4,
				dialogsetCameraMovementVectorVInput = {
					-2,
					0,
					0
				}
			},
			fields = {
				duration = 3,
				chatType = 3,
				npcStaticId = 79274972
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 10,
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
						nodeId = 11,
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
