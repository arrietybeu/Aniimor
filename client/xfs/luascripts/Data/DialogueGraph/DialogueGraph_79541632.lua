-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79541632.lua

return {
	dialogueId = 79541632,
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
			kind = 18,
			inputs = {
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true
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
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
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
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 9,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.49,
					58.194,
					776.079
				},
				rotationVInput = {
					9.074,
					56.55,
					0.002
				}
			},
			fields = {
				fStop = 9.52,
				cameraId = 83919380,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 135
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-497.306,
					56.848,
					776.997
				},
				rotationVInput = {
					0,
					210,
					0
				}
			},
			fields = {
				entityId = -310851593
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Fragrance",
				staticIdVInput = 80375309
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 9.333,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2
			},
			valueIn = {
				lookAtEntityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
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
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 12,
						portId = "In"
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
				["0"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 14,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201196
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 1,
				blackScreenIntervalTime = 4,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 2
			},
			flowIn = {
				In = true
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
						nodeId = 16,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201197
			},
			fields = {
				chatType = 7,
				blackScreenIntervalTime = 1,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 17,
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
						nodeId = 19,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Talk",
				staticIdVInput = 80375309
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 27,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 8.1,
				playAniType = 1,
				entityType = 2,
				templateId = 401059
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201201
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 1,
				blackScreenIntervalTime = 4,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201202
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 1,
				blackScreenIntervalTime = 4,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201203
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 1,
				blackScreenIntervalTime = 4,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 2
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
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.372,
					59.055,
					777.96
				},
				rotationVInput = {
					4.261,
					209.186,
					0.002
				}
			},
			fields = {
				fStop = 5.09,
				cameraId = 90858919,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 8.1,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.744,
					59.046,
					777.686
				},
				rotationVInput = {
					359.792,
					202.31,
					0.002
				}
			},
			fields = {
				fStop = 6.84,
				cameraId = 85417617,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.372,
					59.055,
					777.96
				},
				rotationVInput = {
					4.261,
					209.186,
					0.002
				}
			},
			fields = {
				fStop = 5.09,
				cameraId = 90858912,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 401059,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-499.12,
					56.884,
					776.37
				},
				rotationVInput = {
					0,
					24.431,
					0
				}
			},
			fields = {
				entityId = -1552416767
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 2
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-493.342,
					61.831,
					788.57
				},
				rotationVInput = {
					17.804,
					192.521,
					0.002
				}
			},
			fields = {
				fStop = 4,
				cameraId = 83919382,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			}
		},
		{
			kind = 17
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					107.752,
					0
				},
				targetPositionVInput = {
					-640.161,
					48.253,
					850.715
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 30,
					portId = "EntityID"
				}
			},
			fields = {
				setRotation = true,
				setPosition = true
			}
		},
		{
			kind = 46
		}
	}
}
