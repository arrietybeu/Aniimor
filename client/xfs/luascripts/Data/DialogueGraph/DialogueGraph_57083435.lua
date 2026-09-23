-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_57083435.lua

return {
	startNodeId = 1,
	dialogueId = 57083435,
	schema = "v4",
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
			kind = 18,
			inputs = {
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				blockEventVInput = true
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
				portCount = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["1"] = {
					{
						portId = "In",
						nodeId = 5
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 15
				}
			},
			fields = {
				templateId = 500009,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3801123
			},
			fields = {
				chatType = 3,
				duration = 10
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
				dialogueIdVInput = 3801124
			},
			fields = {
				chatType = 3,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 7
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-632.349,
					82.303,
					1593.089
				},
				rotationVInput = {
					0,
					195.198,
					0
				}
			},
			fields = {
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				squeezeFactor = 1
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 2
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendExponentVInput = 2,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-634.874,
					81.366,
					1596.878
				},
				rotationVInput = {
					0,
					189.134,
					0
				}
			},
			fields = {
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				squeezeFactor = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					-201.44,
					0
				},
				targetPositionVInput = {
					-633.254,
					81.389,
					1591.436
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 11
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = true
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 57080701
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					-31.632,
					0
				},
				targetPositionVInput = {
					-632.68,
					81.586,
					1589.84
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 13
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = true
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 57080701
			},
			fields = {
				entityType = 2
			}
		}
	}
}
