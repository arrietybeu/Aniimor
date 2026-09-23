-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_76138576.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 76138576,
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
				portCount = 6
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
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 3
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Angry"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 17
				}
			},
			fields = {
				activePlayEmotion = true,
				noBlink = true,
				activePlayLip = false
			},
			flowIn = {
				StopEmotion = 1,
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
			kind = 4,
			fields = {
				delayTime = 50
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "StopEmotion",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-525.422,
					54.187,
					846.872
				},
				rotationVInput = {
					359.481,
					170.125,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 76678679,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 20
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
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_PointTo01_Start",
				playStartLoopEndVInput = true,
				animationLayerVInput = 4
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 12
				}
			},
			fields = {
				processingTime = 3,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400077,
				aniStateList = {
					"TalkUpper_PointTo01_Start",
					"TalkUpper_PointTo01_Loop",
					"TalkUpper_PointTo01_End"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		[12] = {
			kind = 9,
			inputs = {
				staticIdVInput = 88066246
			},
			fields = {
				entityType = 2
			}
		},
		[17] = {
			kind = 9,
			inputs = {
				staticIdVInput = 88064950
			},
			fields = {
				entityType = 2
			}
		}
	}
}
