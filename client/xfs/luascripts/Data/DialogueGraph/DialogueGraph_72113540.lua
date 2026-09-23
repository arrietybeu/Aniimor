-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72113540.lua

return {
	dialogueId = 72113540,
	schema = "v4",
	startNodeId = 1,
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
			kind = 34,
			inputs = {
				staticIdVInput = 72113531
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 72113527
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 34,
			inputs = {
				staticIdVInput = 72113529
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				staticIdVInput = 72113531
			},
			valueIn = {
				targetEulerAngleVInput = {
					nodeId = 10,
					portId = "OutEulerAngle"
				},
				targetPositionVInput = {
					nodeId = 10,
					portId = "OutPosition"
				}
			},
			fields = {
				finishToSteer = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 8,
						portId = "0"
					}
				},
				Out = {
					{
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				staticIdVInput = 72113527
			},
			valueIn = {
				targetEulerAngleVInput = {
					nodeId = 11,
					portId = "OutEulerAngle"
				},
				targetPositionVInput = {
					nodeId = 11,
					portId = "OutPosition"
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 8,
						portId = "1"
					}
				},
				Out = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				staticIdVInput = 72113529
			},
			valueIn = {
				targetEulerAngleVInput = {
					nodeId = 12,
					portId = "OutEulerAngle"
				},
				targetPositionVInput = {
					nodeId = 12,
					portId = "OutPosition"
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 8,
						portId = "2"
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 3,
				maxAwaitTime = -1
			},
			flowIn = {
				["2"] = true,
				["1"] = true,
				["0"] = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 100240114
			},
			fields = {
				chatType = 3,
				npcId = 91002201,
				duration = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 43,
			inputs = {
				sceneIDVinput = 412,
				dialogsetIDVInput = 72113510,
				slotIDVInput = 72113524
			}
		},
		{
			kind = 43,
			inputs = {
				sceneIDVinput = 412,
				dialogsetIDVInput = 72113510,
				slotIDVInput = 72113525
			}
		},
		{
			kind = 43,
			inputs = {
				sceneIDVinput = 412,
				dialogsetIDVInput = 72113510,
				slotIDVInput = 72113526
			}
		}
	}
}
