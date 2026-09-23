-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_50957666.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 50957666,
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
						portId = "In",
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 34,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 11
				}
			},
			flowIn = {
				In = true
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityID",
					nodeId = 12
				}
			},
			fields = {
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				resetOrientation = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 29,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 11
				}
			},
			fields = {
				duration = 4,
				emojiName = "Cry"
			},
			flowIn = {
				In = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 270108
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 12
				}
			},
			fields = {
				npcId = 401002,
				chatType = 3,
				duration = 5,
				anim = "Behav_Cry"
			},
			flowIn = {
				In = true
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
				dialogueIdVInput = 270109
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 12
				}
			},
			fields = {
				npcId = 401002,
				chatType = 3,
				duration = 3
			},
			flowIn = {
				In = true
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
			kind = 68
		},
		{
			kind = 17
		},
		{
			kind = 26,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 12
				},
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 8
				}
			},
			flowOut = {
				FinishOut = {
					{
						portId = "In",
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 73,
			inputs = {
				presetNameVInput = "FocusToTarget"
			},
			valueIn = {
				targetEntityVInput = {
					portId = "EntityID",
					nodeId = 12
				}
			},
			flowIn = {
				In = true
			}
		},
		[12] = {
			kind = 9,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 11
				}
			},
			fields = {
				entityType = 2
			}
		}
	},
	blackboard = {}
}
