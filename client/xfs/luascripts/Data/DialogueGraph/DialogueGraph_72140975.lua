-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72140975.lua

return {
	startNodeId = 2,
	dialogueId = 72140975,
	schema = 1,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 1
			},
			flowIn = {
				End = 0
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 2
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
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 22,
			flowIn = {
				In = 0
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
				portCount = 2
			},
			flowIn = {
				In = 0
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
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					355.794,
					0
				},
				targetPositionVInput = {
					45.796,
					58.355,
					1084.063
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 13,
					portId = "EntityIDs"
				}
			},
			fields = {
				reactPreset = 0,
				nodeMode = 1,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0,
				resetOrientation = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
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
						nodeId = 10,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 15,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.3
			},
			flowIn = {
				In = 0
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
			kind = 25,
			fields = {
				condition = {
					"TWIN_PET_CHOICE",
					nil,
					nil,
					"=",
					1
				}
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
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 500029,
				positionVInput = {
					44.87,
					58.355,
					1083.855
				},
				rotationVInput = {
					0,
					23.652,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -583789651
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					nodeId = 133,
					portId = "EntityID"
				},
				["2EntityIDVInput"] = {
					nodeId = 135,
					portId = "EntityID"
				},
				["3EntityIDVInput"] = {
					nodeId = 134,
					portId = "EntityID"
				},
				["4EntityIDVInput"] = {
					nodeId = 149,
					portId = "EntityID"
				},
				["6EntityIDVInput"] = {
					nodeId = 12,
					portId = "EntityID"
				},
				["7EntityIDVInput"] = {
					nodeId = 14,
					portId = "EntityID"
				}
			},
			fields = {
				portCount = 7
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 500030,
				positionVInput = {
					44.87,
					58.355,
					1083.855
				},
				rotationVInput = {
					0,
					23.652,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1384334087
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 36.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				positionVInput = {
					44.8,
					60.3,
					1082.72
				},
				rotationVInput = {
					9.21,
					6.3,
					-0.001
				}
			},
			fields = {
				cameraId = 73282003,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 25,
				positionVInput = {
					44.737,
					60.438,
					1078.607
				},
				rotationVInput = {
					9.21,
					5.526,
					-0.001
				}
			},
			fields = {
				cameraId = 73281984,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72140969,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 23,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				dialogueIdVInput = 20610487
			},
			fields = {
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
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
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 22,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 123,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 124,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610488
			},
			fields = {
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 24,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 121,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 122,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610489
			},
			fields = {
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 25,
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
						nodeId = 26,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 120,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610490
			},
			fields = {
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 28,
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
						nodeId = 29,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 119,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206104901
			},
			fields = {
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 31,
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
						nodeId = 32,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206104902
			},
			fields = {
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610491,
				lookAtIdVInput = 400129
			},
			fields = {
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
						portId = "closeUIFInput"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 70,
				param = {
					url = "$UI_Img_ItemView_Explorer.png"
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 37,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 117,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 118,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610492
			},
			fields = {
				matchAudioDuration = true,
				duration = 13,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 4,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 97,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 103,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 109,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				},
				ShowFinOut = {
					{
						nodeId = 115,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610496,
				animCfg = {
					[1] = "Emotion_Confused",
					[2] = {
						[1] = false,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 39,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 40,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 96,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73309209,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Smile_Start",
				staticIdVInput = 72140915,
				playStartLoopEndVInput = true
			},
			fields = {
				entityType = 2,
				templateId = 400129,
				processingTime = 7.967,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Emotion_Smile_Start",
					"Emotion_Smile_Loop",
					"Emotion_Smile_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610500
			},
			fields = {
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 43,
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
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 45,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 95,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610501
			},
			fields = {
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 46,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 88,
						portId = "In"
					}
				},
				ShowFinOut = {
					{
						nodeId = 94,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610502
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 48,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 85,
						portId = "StopDof"
					}
				},
				["2"] = {
					{
						nodeId = 84,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 86,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105031
			},
			fields = {
				matchAudioDuration = true,
				duration = 14,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 49,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 50,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 80,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 82,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 73,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 81,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105032
			},
			fields = {
				matchAudioDuration = true,
				duration = 13,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 52,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 73,
						portId = "Stop"
					}
				},
				["2"] = {
					{
						nodeId = 74,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 75,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 79,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 76,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 2061050321
			},
			fields = {
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 53,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 71,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 70,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 72,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105033,
				lookAtIdVInput = 400129
			},
			fields = {
				matchAudioDuration = true,
				duration = 14,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 55,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 56,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 69,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 66,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 70,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105034
			},
			fields = {
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 57,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 58,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 60,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 66,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 67,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 68,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105035
			},
			fields = {
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 59,
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					45.33,
					60.282,
					1081.489
				},
				rotationVInput = {
					10.2,
					-0.77,
					-0.001
				}
			},
			fields = {
				cameraId = 73310772,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 227,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 196,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 62,
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
				["1"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 72138731,
				moveTypeVInput = 2,
				targetPositionVInput = {
					49.282,
					58.355,
					1089.478
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							time = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 64,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 65,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				staticIdVInput = 72138731
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 59,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Talk_Start",
				staticIdVInput = 72140969,
				playStartLoopEndVInput = true
			},
			fields = {
				entityType = 2,
				templateId = 400162,
				processingTime = 22,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Story_Talk_Start",
					"Story_Talk_Loop",
					"Story_Talk_End"
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72140969,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 72138731
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					44.796,
					60.04,
					1084.515
				},
				rotationVInput = {
					7.96,
					0.3,
					-0.001
				}
			},
			fields = {
				cameraId = 73310434,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk",
				staticIdVInput = 72138731
			},
			fields = {
				templateId = 400406,
				processingTime = 18.5,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72138731,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				positionVInput = {
					44.4,
					59.8,
					1083.8
				},
				rotationVInput = {
					7.6,
					70.1,
					0
				}
			},
			fields = {
				cameraId = 73310128,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 117,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 223,
				fStop = 7.89
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Righthand",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 2.5,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72140969,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72140915,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 72140915,
				targetPositionVInput = {
					49.411,
					58.41,
					1091.022
				}
			},
			fields = {
				finishToSteer = true,
				reset = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							time = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 77,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 78,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				staticIdVInput = 72140915
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 72140915
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 23,
				positionVInput = {
					44.072,
					60.121,
					1083.705
				},
				rotationVInput = {
					6.4,
					28.8,
					0
				}
			},
			fields = {
				cameraId = 73310031,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 145,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 195,
				fStop = 15.29
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 72140969,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 72138731,
				targetEulerAngleVInput = {
					0,
					236.497,
					0
				},
				targetPositionVInput = {
					46.334,
					58.355,
					1084.738
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Smile01",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 5.4,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 13.033,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.196,
					59.844,
					1084.99
				},
				rotationVInput = {
					13.4,
					137.9,
					-0.001
				}
			},
			fields = {
				cameraId = 73309201,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0,
				StopDof = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					45.21,
					60.282,
					1081.489
				},
				rotationVInput = {
					10.2,
					359.23,
					-0.001
				}
			},
			fields = {
				cameraId = 73311145,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 227,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 196,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 87,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				fovVInput = 35,
				blendFuncVInput = "Linear",
				positionVInput = {
					45.5,
					60.282,
					1081.489
				},
				rotationVInput = {
					10.2,
					359.23,
					-0.001
				}
			},
			fields = {
				cameraId = 73311146,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 227,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 196,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610503
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 89,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 92,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 90,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 91,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73309210,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Smile_Start",
				staticIdVInput = 72140915,
				playStartLoopEndVInput = true
			},
			fields = {
				entityType = 2,
				templateId = 400129,
				processingTime = 7.967,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Emotion_Smile_Start",
					"Emotion_Smile_Loop",
					"Emotion_Smile_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 206105036
			},
			fields = {
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 93,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 1,
						portId = "End"
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
						nodeId = 85,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 84,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Normal",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 3,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 13.033,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610494,
				animCfg = {
					[1] = "Emotion_Excited",
					[2] = {
						[1] = false,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 98,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 99,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 101,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 102,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 96,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610498
			},
			fields = {
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 100,
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
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73309095,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Normal",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 3,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610495,
				animCfg = {
					[1] = "Emotion_Excited",
					[2] = {
						[1] = false,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 107,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 105,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 106,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 96,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73309110,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_FoldArms",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 7.967,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610499
			},
			fields = {
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 108,
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
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 20610493,
				animCfg = {
					"Emotion_Firm_Start",
					"Emotion_Firm_Loop",
					"Emotion_Firm_End",
					{
						[1] = false,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 110,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 113,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 111,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 112,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 96,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73320966,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Smile_Start",
				staticIdVInput = 72140915,
				playStartLoopEndVInput = true
			},
			fields = {
				entityType = 2,
				templateId = 400129,
				processingTime = 3.067,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Emotion_Smile_Start",
					"Emotion_Smile_Loop",
					"Emotion_Smile_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 20610497
			},
			fields = {
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = -1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 114,
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
						nodeId = 44,
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
						nodeId = 116,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.196,
					59.844,
					1084.99
				},
				rotationVInput = {
					13.4,
					137.9,
					-0.001
				}
			},
			fields = {
				cameraId = 73307735,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 36.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73309092,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 27,
			fields = {
				uid = 70,
				param = {
					url = "$UI_Img_ItemView_Stronger.png"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 27,
			fields = {
				uid = 70,
				param = {
					url = "$UI_Img_ItemView_Scholar.png"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.378,
					60.057,
					1085.096
				},
				rotationVInput = {
					8.7,
					33.2,
					-0.001
				}
			},
			fields = {
				cameraId = 73306385,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod",
				staticIdVInput = 72140915
			},
			fields = {
				templateId = 400129,
				processingTime = 3.017,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				positionVInput = {
					45.196,
					59.844,
					1084.99
				},
				rotationVInput = {
					13.4,
					137.9,
					-0.001
				}
			},
			fields = {
				cameraId = 73305799,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 238,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 13.12
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Cheeksupport",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 5.5,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		[133] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72140915
			},
			fields = {
				entityType = 2
			}
		},
		[134] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[135] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72138731
			},
			fields = {
				entityType = 2
			}
		},
		[149] = {
			kind = 9,
			inputs = {
				staticIdVInput = 72140969
			},
			fields = {
				entityType = 2
			}
		}
	}
}
