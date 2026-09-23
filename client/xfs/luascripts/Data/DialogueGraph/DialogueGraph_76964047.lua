-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_76964047.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 76964047,
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
						nodeId = 9
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 3
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 38,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 5,
				entityIdVInput = 76707208,
				targetEulerAngleVInput = {
					0,
					192.13,
					0
				},
				targetPositionVInput = {
					50.85,
					58.405,
					1079.38
				}
			},
			fields = {
				finishToSteer = true
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
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "Eff_Switch_Hit"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 14
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 38,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 5,
				entityIdVInput = 76707249,
				targetEulerAngleVInput = {
					0,
					187.964,
					0
				},
				targetPositionVInput = {
					49.71,
					58.395,
					1080.76
				}
			},
			fields = {
				finishToSteer = true
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
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "Eff_Switch_Hit"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 15
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5
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
		[14] = {
			kind = 9,
			inputs = {
				staticIdVInput = 76707208
			},
			fields = {
				entityType = 2
			}
		},
		[15] = {
			kind = 9,
			inputs = {
				staticIdVInput = 76707249
			},
			fields = {
				entityType = 2
			}
		}
	}
}
