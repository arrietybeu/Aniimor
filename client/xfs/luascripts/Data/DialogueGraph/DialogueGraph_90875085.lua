-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90875085.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 90875085,
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
						nodeId = 2,
						portId = "In"
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
						nodeId = 3,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 38,
			inputs = {
				autoPathfindingVInput = true,
				targetEulerAngleVInput = {
					0,
					251.209,
					0
				},
				targetPositionVInput = {
					-1236.331,
					69.512,
					1677.499
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 20,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 4,
						portId = "0"
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				maxAwaitTime = -1,
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 51,
			inputs = {
				triggerIdVInput = 690
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 51,
			inputs = {
				triggerIdVInput = 691
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 7,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 51,
			inputs = {
				triggerIdVInput = 692
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 14,
						portId = "In"
					}
				},
				True = {
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
				dialogueIdVInput = 70005079
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 19,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				portCount = 1,
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
				dialogueIdVInput = 70005080
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 19,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial02",
				portCount = 1,
				animCfg = {
					[1] = "IdleSpecial02",
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
						nodeId = 10,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005081
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 18,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				portCount = 1,
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
				["0"] = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005082
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 18,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial02",
				portCount = 1,
				animCfg = {
					[1] = "IdleSpecial02",
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
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005083
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 18,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Attack04",
				portCount = 1,
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
						nodeId = 13,
						portId = "In"
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005907
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 19,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				portCount = 1,
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
				["0"] = {
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
				dialogueIdVInput = 70005908
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 18,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				portCount = 1,
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
				["0"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70005908
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 18,
					portId = "EntityID"
				}
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 11020101,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 9,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "IdleSpecial",
				portCount = 1,
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
				["0"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 38,
			inputs = {
				autoPathfindingVInput = true,
				targetEulerAngleVInput = {
					0,
					89.793,
					0
				},
				targetPositionVInput = {
					-1238.044,
					69.096,
					1676.503
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 21,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 4,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90639214
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90639216
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90639214
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90639216
			},
			fields = {
				entityType = 2
			}
		}
	}
}
