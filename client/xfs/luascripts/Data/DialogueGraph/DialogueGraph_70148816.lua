-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_70148816.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 70148816,
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
			kind = 24,
			inputs = {
				switchToWalkVInput = true
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
			kind = 18,
			inputs = {
				hideAllUIVInput = true
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
			kind = 2,
			fields = {
				portCount = 3
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
				},
				["1"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904111
			},
			fields = {
				chatType = 6,
				duration = 5
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
						nodeId = 7,
						portId = "In"
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3904112
			},
			fields = {
				chatType = 6,
				duration = 15
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
				dialogueIdVInput = 3904113
			},
			fields = {
				chatType = 6,
				duration = 10
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
			kind = 12,
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
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 66618647,
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					111.244,
					0
				},
				targetPositionVInput = {
					-458.467,
					62.692,
					819.125
				}
			},
			fields = {
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							outTangent = 1,
							value = 0,
							inTangent = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0
						},
						{
							inWeight = 0,
							outTangent = 0,
							value = 1,
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1
						}
					}
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 66618647,
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					114.23,
					0
				},
				targetPositionVInput = {
					-451.209,
					66.254,
					814.328
				}
			},
			fields = {
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							outTangent = 1,
							value = 0,
							inTangent = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0
						},
						{
							inWeight = 0,
							outTangent = 0,
							value = 1,
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1
						}
					}
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 66618647,
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					52.703,
					0
				},
				targetPositionVInput = {
					-450.278,
					66.254,
					816.68
				}
			},
			fields = {
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							outTangent = 1,
							value = 0,
							inTangent = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0
						},
						{
							inWeight = 0,
							outTangent = 0,
							value = 1,
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1
						}
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Normal"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 14,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 3,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 14,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 16,
					portId = "EntityID"
				}
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			}
		}
	}
}
