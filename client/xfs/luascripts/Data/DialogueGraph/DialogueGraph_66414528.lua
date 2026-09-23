-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_66414528.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 66414528,
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
			kind = 4,
			fields = {
				delayTime = 0.6
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
				portCount = 6
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
				},
				["1"] = {
					{
						nodeId = 10,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 64,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 66,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					156.014,
					0
				},
				targetPositionVInput = {
					-565.696,
					48.025,
					828.562
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 70,
					portId = "EntityID"
				}
			},
			fields = {
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
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
				speedVInput = 0.823,
				targetEulerAngleVInput = {
					0,
					156.013,
					0
				},
				targetPositionVInput = {
					-565.131,
					48.085,
					828.291
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 70,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-567.918,
					49.3,
					829.56
				},
				rotationVInput = {
					352.186,
					118.888,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 44,
				openDof = true,
				focalDistance = 223,
				fStop = 4,
				cameraId = 69365951
			},
			flowIn = {
				In = true
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
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendExponentVInput = 2,
				blendTimeVInput = 5,
				positionVInput = {
					-567.362,
					49.3,
					829.253
				},
				rotationVInput = {
					352.186,
					118.888,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 44,
				openDof = true,
				focalDistance = 223,
				fStop = 4,
				cameraId = 69435579
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904001
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904002
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
				portCount = 3
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
						nodeId = 60,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 64,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904003
			},
			fields = {
				skipTime = 3,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 14,
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
						nodeId = 15,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 57,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 58,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904004
			},
			fields = {
				skipTime = 1.5,
				duration = 2
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
						nodeId = 17,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-566.218,
					49.465,
					829.426
				},
				rotationVInput = {
					352.874,
					145.359,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 279,
				fStop = 13.75,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904005
			},
			fields = {
				duration = 2
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
						nodeId = 20,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-565.68,
					49.733,
					829.629
				},
				rotationVInput = {
					349.665,
					58.269,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 423,
				openDof = true,
				focalDistance = 243,
				fStop = 14.98,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904006
			},
			fields = {
				skipTime = 1.5,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 22,
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
						nodeId = 23,
						portId = "In"
					}
				},
				["1"] = {
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
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-566.218,
					49.465,
					829.426
				},
				rotationVInput = {
					352.874,
					145.359,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 279,
				fStop = 13.75,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904007
			},
			fields = {
				skipTime = 2,
				duration = 2
			},
			flowIn = {
				In = true
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
				portCount = 5
			},
			flowIn = {
				In = true
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
						nodeId = 30,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 56,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-565.342,
					49.787,
					826.748
				},
				rotationVInput = {
					0.322,
					28.361,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 423,
				openDof = true,
				focalDistance = 243,
				fStop = 14.98,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				blendTimeVInput = 5,
				positionVInput = {
					-566.012,
					49.767,
					826.139
				},
				rotationVInput = {
					356.426,
					34.893,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 301,
				openDof = true,
				focalDistance = 262,
				fStop = 32,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 26,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-567.368,
					50.707,
					828.225
				},
				rotationVInput = {
					20.261,
					93.564,
					0
				}
			},
			fields = {
				squeezeFactor = 1.5,
				sensorWidth = 317,
				openDof = true,
				focalDistance = 226,
				fStop = 29,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904008
			},
			fields = {
				portCount = 2,
				duration = 2,
				skipTime = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 31,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 53,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904009
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 32,
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
				["1"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 52,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904011
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
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
				dialogueIdVInput = 3904012
			},
			fields = {
				portCount = 2,
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904013
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
				portCount = 5
			},
			flowIn = {
				In = true
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
						nodeId = 37,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 49,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904015
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 38,
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
						nodeId = 48,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904016
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 40,
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
						nodeId = 41,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 26,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-567.368,
					50.707,
					828.225
				},
				rotationVInput = {
					20.261,
					93.564,
					0
				}
			},
			fields = {
				squeezeFactor = 1.5,
				sensorWidth = 317,
				openDof = true,
				focalDistance = 226,
				fStop = 29,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904017
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
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
				portCount = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 44,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904018
			},
			fields = {
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
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 75,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400207,
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Emotion_Think"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 7.333,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 34,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-565.016,
					49.512,
					827.577
				},
				rotationVInput = {
					346.571,
					39.247,
					0.001
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 172,
				fStop = 21,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 74,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400207,
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-565.136,
					49.665,
					829.352
				},
				rotationVInput = {
					355.967,
					172.517,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 171,
				fStop = 32,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904014
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 9.967,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904010
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 32,
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
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 55,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					200.792,
					0
				},
				targetPositionVInput = {
					-564.19,
					48.307,
					828.471
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			},
			fields = {
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.823,
				targetEulerAngleVInput = {
					0,
					59.957,
					0
				},
				targetPositionVInput = {
					-565.1,
					48.101,
					827.745
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 73,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 24,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-565.68,
					49.733,
					829.629
				},
				rotationVInput = {
					349.665,
					58.269,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 423,
				openDof = true,
				focalDistance = 243,
				fStop = 14.98,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Emotion_Confused"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 7.117,
				playAniType = 1,
				entityType = 2
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
					91.47,
					0
				},
				targetPositionVInput = {
					-566.153,
					48.025,
					828.254
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 76,
					portId = "EntityID"
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
			kind = 4,
			fields = {
				delayTime = 0.8
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 0.2,
				targetEulerAngleVInput = {
					0,
					30,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 72,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
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
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 63,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Daily_Yell_Start"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 72,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400207,
				processingTime = 1.083,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Plant_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 71,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400207,
				processingTime = 3.767,
				playAniType = 1,
				entityType = 2
			},
			flowIn = {
				In = true,
				Stop = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					350,
					0
				},
				targetPositionVInput = {
					-564.653,
					48.187,
					827.186
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 71,
					portId = "EntityID"
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
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					5.676,
					0
				},
				targetPositionVInput = {
					-563.411,
					48.722,
					830.914
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
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
			kind = 3,
			inputs = {
				fovVInput = 26,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-567.368,
					50.307,
					828.225
				},
				rotationVInput = {
					20.261,
					93.564,
					0
				}
			},
			fields = {
				squeezeFactor = 1.5,
				sensorWidth = 317,
				openDof = true,
				focalDistance = 226,
				fStop = 29,
				cameraId = 69365951
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 71926584
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 1,
				targetEulerAngleVInput = {
					0,
					120,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 68,
					portId = "EntityID"
				}
			}
		},
		{
			kind = 9
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 71775395
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 71775395
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = -3.538427668910713e+18
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 71775395
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 71775395
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9
		}
	}
}
