-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_56919162.lua

return {
	dialogueId = 56919162,
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
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 20,
				speedVInput = 1.05,
				targetEulerAngleVInput = {
					0,
					154.9,
					0
				},
				targetPositionVInput = {
					-1761.601,
					94.5,
					629.438
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 16
				}
			},
			fields = {
				reset = false,
				finishToSteer = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0
						},
						{
							time = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 20,
				speedVInput = 1.05,
				targetEulerAngleVInput = {
					0,
					92.01,
					0
				},
				targetPositionVInput = {
					-1761.816,
					94.475,
					626.65
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 16
				}
			},
			fields = {
				reset = false,
				finishToSteer = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0
						},
						{
							time = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 20,
				speedVInput = 1.05,
				targetEulerAngleVInput = {
					0,
					92.01,
					0
				},
				targetPositionVInput = {
					-1758.654,
					94.475,
					622.649
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 16
				}
			},
			fields = {
				reset = false,
				finishToSteer = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0
						},
						{
							time = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				speedVInput = 1.05,
				targetEulerAngleVInput = {
					0,
					295.5,
					0
				},
				targetPositionVInput = {
					-1733.401,
					94.561,
					616.442
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 16
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0
						},
						{
							time = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		[16] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72084386
			},
			fields = {
				entityType = 2
			}
		}
	}
}
