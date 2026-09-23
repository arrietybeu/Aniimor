-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_80541066.lua

return {
	startNodeId = 1,
	dialogueId = 80541066,
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
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true
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
						portId = "In",
						nodeId = 4
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
						portId = "In",
						nodeId = 5
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 20
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 15
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 16
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-910.409,
					102.954,
					1243.386
				},
				rotationVInput = {
					0,
					25.617,
					0
				}
			},
			fields = {
				entityId = -1827017896
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Shrug"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			fields = {
				entityType = 2,
				templateId = 400180,
				processingTime = 2.4,
				playAniType = 1
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
					portId = "EntityID",
					nodeId = 6
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Talk"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			fields = {
				entityType = 2,
				templateId = 400180,
				processingTime = 2.4,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Smile01",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			fields = {
				entityType = 2,
				playAniType = 1,
				templateId = 400180,
				processingTime = 2.4,
				aniStateList = {
					"Emotion_Smile01",
					"Emotion_Smile01",
					"Emotion_Smile01"
				}
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
					portId = "EntityID",
					nodeId = 6
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				animationLayerVInput = 4,
				playableStateVInput = "TalkUpper_Talk"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			fields = {
				templateId = 301,
				processingTime = 5.2,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.025,
				targetEulerAngleVInput = {
					0,
					120,
					0
				},
				targetPositionVInput = {
					-908.777,
					103.163,
					1245.183
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 6
				}
			},
			fields = {
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							weightedMode = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							outWeight = 0,
							time = 0
						},
						{
							weightedMode = 0,
							value = 1,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							outWeight = 0,
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
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					301.242,
					0
				},
				targetPositionVInput = {
					-907.881,
					103.043,
					1244.821
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 62
				}
			},
			fields = {
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-908.927,
					102.912,
					1243.993
				},
				rotationVInput = {
					0,
					16.102,
					0
				}
			},
			fields = {
				entityId = -1456847143
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
					portId = "EntityID",
					nodeId = 16
				}
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
					portId = "EntityID",
					nodeId = 16
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-906.62,
					104.401,
					1241.582
				},
				rotationVInput = {
					357.954,
					332.145,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881290,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
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
						portId = "In",
						nodeId = 21
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
						portId = "In",
						nodeId = 22
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 14
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201132
			},
			fields = {
				npcId = 400180,
				duration = 7,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 23
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 25
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 24
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-907.529,
					104.323,
					1245.708
				},
				rotationVInput = {
					23.566,
					219.73,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881667,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
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
				In = true
			},
			flowOut = {
				False = {
					{
						portId = "In",
						nodeId = 54
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201133
			},
			fields = {
				npcId = 100,
				duration = 5,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "0",
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = true,
				["1"] = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 28
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
						portId = "In",
						nodeId = 31
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 9
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
					-906.881,
					104.557,
					1243.147
				},
				rotationVInput = {
					7.408,
					325.613,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881637,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 14.7,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-907.639,
					104.557,
					1242.782
				},
				rotationVInput = {
					7.236,
					341.255,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881640,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201135
			},
			fields = {
				npcId = 400180,
				duration = 9,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 32
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
						nodeId = 34
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 33
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				animationLayerVInput = 4,
				playableStateVInput = "TalkUpper_Lefthand"
			},
			fields = {
				templateId = 301,
				processingTime = 2,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201011
			},
			fields = {
				npcId = 0,
				duration = 6,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 35
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
						nodeId = 36
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201136
			},
			fields = {
				npcId = 400180,
				duration = 9,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201022
			},
			fields = {
				npcId = 400180,
				duration = 14,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 40
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 39
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 17
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-907.388,
					104.211,
					1244.602
				},
				rotationVInput = {
					29.582,
					253.936,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881720,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
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
				In = true
			},
			flowOut = {
				False = {
					{
						portId = "In",
						nodeId = 53
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201023
			},
			fields = {
				npcId = 100,
				duration = 11,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 42
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
						portId = "In",
						nodeId = 43
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 51
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6201025
			},
			fields = {
				npcId = 400180,
				duration = 2,
				chatType = 3,
				portCount = 2,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 44
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201026
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 45
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201028
			},
			fields = {
				npcId = 400180,
				duration = 9,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 46
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
						nodeId = 47
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201031
			},
			fields = {
				npcId = 400180,
				duration = 6,
				chatType = 3,
				npcStaticId = 1
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
			kind = 7,
			fields = {
				dialogueId = 6201027
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 49
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201029
			},
			fields = {
				npcId = 400180,
				duration = 8,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 50
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201030
			},
			fields = {
				npcId = 400180,
				duration = 10,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 46
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
					-907.367,
					104.694,
					1242.862
				},
				rotationVInput = {
					11.705,
					341.427,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90881721,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 52
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 18.7,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-907.688,
					104.527,
					1243.807
				},
				rotationVInput = {
					8.955,
					340.567,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90882658,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201024
			},
			fields = {
				npcId = 100,
				duration = 5,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201134
			},
			fields = {
				npcId = 100,
				duration = 6,
				chatType = 3,
				npcStaticId = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "1",
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-908.777,
					103.163,
					1245.183
				},
				rotationVInput = {
					0,
					120,
					0
				}
			},
			fields = {
				entityId = -204105353
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-905.526,
					103.233,
					1245.529
				},
				rotationVInput = {
					0,
					330,
					0
				}
			},
			fields = {
				entityId = -1219427633
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-905.526,
					103.233,
					1245.529
				},
				rotationVInput = {
					0,
					320,
					0
				}
			},
			fields = {
				entityId = -69827221
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-905.65,
					103.233,
					1245.108
				},
				rotationVInput = {
					0,
					320,
					0
				}
			},
			fields = {
				entityId = -1646323285
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-905.442,
					103.233,
					1245.283
				},
				rotationVInput = {
					0,
					320,
					0
				}
			},
			fields = {
				entityId = -493581648
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-905.122,
					103.004,
					1245.838
				},
				rotationVInput = {
					0,
					300,
					0
				}
			},
			fields = {
				entityId = -1233646822
			}
		},
		{
			kind = 13,
			fields = {
				reactPreset = 3,
				enableGroupLookAt = true,
				resetOrientation = true
			}
		},
		{
			kind = 17
		},
		{
			kind = 26
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-909.604,
					103.202,
					1244.909
				},
				rotationVInput = {
					0,
					180,
					0
				}
			},
			fields = {
				entityId = -1816043819
			}
		}
	}
}
