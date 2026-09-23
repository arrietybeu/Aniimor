-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_47768894.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 47768894,
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 14
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				lookAtIdVInput = 400228,
				dialogueIdVInput = 20000220
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Attack01",
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Attack01",
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
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400226,
				dialogueIdVInput = 20000221
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Attack01",
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Attack01",
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
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400227,
				dialogueIdVInput = 20000222
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Attack01",
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Attack01",
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
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400228,
				dialogueIdVInput = 20000223
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Attack04",
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Attack04",
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
		[13] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72240089
			},
			fields = {
				entityType = 2
			}
		},
		[14] = {
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 13
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 15
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 16
				},
				["4EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 17
				}
			},
			fields = {
				portCount = 4
			}
		},
		[15] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72241103
			},
			fields = {
				entityType = 2
			}
		},
		[16] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72241105
			},
			fields = {
				entityType = 2
			}
		},
		[17] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72241105
			},
			fields = {
				entityType = 0
			}
		}
	}
}
