-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_65126282.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 65126282,
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
			kind = 73,
			inputs = {
				presetNameVInput = "FocusToTarget"
			},
			valueIn = {
				targetEntityVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 3
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "Eff_Avatar_Girl_Flute_Skill_Cure_sing"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 5
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
				In = true
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
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 4
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 4
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 10
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 10
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			fields = {
				emojiName = "Laugh",
				duration = 4
			},
			flowIn = {
				In = true
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
			kind = 26,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				},
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 11
				}
			},
			flowIn = {
				In = true
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
			kind = 37,
			inputs = {
				effectKeyVInput = "Eff_Avatar_Girl_CheerStick_Skill_Inspire_LinkTarget"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 17
		},
		[13] = {
			kind = 9,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 12
				}
			},
			fields = {
				entityType = 2
			}
		},
		[14] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 270115
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			fields = {
				npcId = 401002,
				chatType = 3,
				duration = 3,
				anim = "IdleSpecial"
			}
		}
	},
	blackboard = {
		BeSaveID = 0
	}
}
