-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_66414659.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 66414659,
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
				hideAllUIVInput = true,
				exitCatchModeVInput = false,
				enhanceAmbientIntensityVInput = true,
				clearEventInputVInput = true,
				blockEventVInput = true,
				hideTopLogoVInput = true
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
				portCount = 4
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
						nodeId = 8,
						portId = "In"
					}
				},
				["3"] = {
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
				fovVInput = 32,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 2,
				positionVInput = {
					-721.909,
					47.367,
					839.776
				},
				rotationVInput = {
					6.51,
					200.936,
					0
				}
			},
			fields = {
				visualizeDOF = true,
				squeezeFactor = 1,
				sensorWidth = 440,
				openDof = true,
				focalDistance = 800,
				fStop = 11,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 32,
				blendExponentVInput = 2,
				blendTimeVInput = 10,
				positionVInput = {
					-721.062,
					47.451,
					839.442
				},
				rotationVInput = {
					6.51,
					200.936,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 440,
				openDof = true,
				focalDistance = 800,
				fStop = 11,
				cameraId = 69435579
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetPositionVInput = {
					-727.06,
					45.37,
					834.908
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 90,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
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
			kind = 19,
			inputs = {
				speedVInput = 1.1,
				targetEulerAngleVInput = {
					0,
					276.572,
					0
				},
				targetPositionVInput = {
					-722.315,
					45.423,
					832.462
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 90,
					portId = "EntityID"
				}
			},
			fields = {
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
						}
					}
				}
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
						nodeId = 36,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400061,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-726.98,
					45.37,
					835.789
				},
				rotationVInput = {
					0,
					102.145,
					0
				}
			},
			fields = {
				entityId = -4.575643826201552e+18
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 12,
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
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.75,
				targetEulerAngleVInput = {
					0,
					22.539,
					0
				},
				targetPositionVInput = {
					-726.98,
					45.347,
					833.7
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 11,
					portId = "EntityID"
				}
			},
			fields = {
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
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
						nodeId = 35,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 14,
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
						nodeId = 15,
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
						nodeId = 16,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 31,
						portId = "In"
					}
				},
				["3"] = {
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
				dialogueIdVInput = 3904043
			},
			fields = {
				duration = 2,
				skipTime = 2
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
			kind = 7,
			fields = {
				dialogueId = 3904044
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 18,
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
						nodeId = 27,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904046
			},
			fields = {
				duration = 2,
				skipTime = 0.5
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
			kind = 7,
			fields = {
				dialogueId = 3904047
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
				portCount = 3
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
				},
				["1"] = {
					{
						nodeId = 25,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904049
			},
			fields = {
				duration = 2,
				skipTime = 0.5
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
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904050
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904052
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 55,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 1,
				positionVInput = {
					-725.772,
					46.677,
					837.022
				},
				rotationVInput = {
					13.866,
					183.134,
					359.988
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 2,
				playableStateVInput = "Emotion_ShakeHead"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 92,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 3,
				processingTime = 3.083,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 1,
				positionVInput = {
					-724.614,
					46.084,
					836.185
				},
				rotationVInput = {
					7.907,
					254.117,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					316.61,
					0
				},
				targetPositionVInput = {
					-725.265,
					45.46,
					834.96
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 92,
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
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
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
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityIdVInput = -4.189635518242703e+18
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 92,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					310.489,
					0
				},
				targetPositionVInput = {
					-725.73,
					45.46,
					834.854
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 92,
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
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
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
				blendExponentVInput = 4,
				fovVInput = 10,
				positionVInput = {
					-727.709,
					45.68,
					830.633
				},
				rotationVInput = {
					353.103,
					13.12,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 1,
				fStop = 4,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
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
				delayTime = 2
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_SleepStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 11,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400061,
				entityType = 2,
				processingTime = 0.883,
				playAniType = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_SleepLoop"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 11,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400061,
				entityType = 2,
				processingTime = 1.933,
				playAniType = 1
			},
			flowIn = {
				In = true
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
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400089,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-727.052,
					45.37,
					834.246
				},
				rotationVInput = {
					0,
					102.145,
					0
				}
			},
			fields = {
				entityId = -4.189635518242703e+18
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 37,
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
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.976,
				targetPositionVInput = {
					-725.893,
					45.376,
					833.995
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 36,
					portId = "EntityID"
				}
			},
			fields = {
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = true
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
			kind = 4,
			fields = {
				delayTime = 1.9
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
				portCount = 5
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
						nodeId = 86,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 82,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904043
			},
			fields = {
				duration = 2,
				skipTime = 2,
				npcId = 400089
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904044
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
						nodeId = 79,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 77,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904046
			},
			fields = {
				duration = 2,
				skipTime = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904047
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 46,
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
						nodeId = 47,
						portId = "In"
					}
				},
				["1"] = {
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
				dialogueIdVInput = 3904049
			},
			fields = {
				duration = 2,
				skipTime = 2
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
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904050
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
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
				portCount = 3
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
						nodeId = 74,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 75,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904052
			},
			fields = {
				duration = 2,
				skipTime = 2
			},
			flowIn = {
				In = true
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
			kind = 7,
			fields = {
				dialogueId = 3904053
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 52,
						portId = "In"
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
						nodeId = 53,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 73,
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
						nodeId = 68,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904054
			},
			fields = {
				duration = 2,
				skipTime = 5.5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 54,
						portId = "In"
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
						nodeId = 55,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 62,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904055
			},
			fields = {
				duration = 2,
				portCount = 2
			},
			flowIn = {
				In = true
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
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3904056
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 57,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904058
			},
			fields = {
				duration = 2,
				portCount = 2
			},
			flowIn = {
				In = true
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
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
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
			kind = 7,
			fields = {
				dialogueId = 3904057
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 57,
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
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					170,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 95,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
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
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 94,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 75,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 4,
				fovVInput = 32,
				positionVInput = {
					-726.23,
					46.565,
					834.822
				},
				rotationVInput = {
					356.54,
					146.047,
					-0.001
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 225,
				openDof = true,
				focalDistance = 200,
				fStop = 17,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4.6
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_Futternym_10231_Skill_Sprinkle02.prefab",
				postionVInput = {
					-726.043,
					44.926,
					834.204
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 69,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 4,
				positionVInput = {
					-724.469,
					48.401,
					831.002
				},
				rotationVInput = {
					339.466,
					164.955,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 225,
				openDof = true,
				focalDistance = 270,
				fStop = 15,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 70,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 32,
				blendExponentVInput = 4,
				blendTimeVInput = 1.5,
				positionVInput = {
					-725.245,
					46.812,
					833.615
				},
				rotationVInput = {
					346.915,
					163.121,
					-0.001
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 225,
				openDof = true,
				focalDistance = 270,
				fStop = 15,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 71,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4.3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 72,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 4,
				fovVInput = 23,
				positionVInput = {
					-726.289,
					45.361,
					830.267
				},
				rotationVInput = {
					351.269,
					4.755,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 225,
				openDof = true,
				focalDistance = 270,
				fStop = 15,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Descent"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 75,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 11023300,
				entityType = 2,
				processingTime = 6.867,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 2,
				playableStateVInput = "IdleSpecial04"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 4,
				processingTime = 6.417,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 11023300,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-724.664,
					46,
					831.7
				},
				rotationVInput = {
					0,
					343.95,
					0
				}
			},
			fields = {
				entityId = -4.2220773101410063e+18
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 2,
				playableStateVInput = "Emotion_ShakeHead"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 3,
				processingTime = 3.083,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					270,
					0
				},
				targetPositionVInput = {
					-724.892,
					45.378,
					833.209
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
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
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
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
						nodeId = 78,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 36,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 4,
				fovVInput = 23,
				positionVInput = {
					-726.289,
					45.361,
					830.267
				},
				rotationVInput = {
					351.269,
					4.755,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 63,
				openDof = true,
				focalDistance = 360,
				fStop = 4,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 80,
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
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 81,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 5,
				fovVInput = 30,
				positionVInput = {
					-728.217,
					45.842,
					831.504
				},
				rotationVInput = {
					355.624,
					49.607,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 165,
				openDof = true,
				focalDistance = 171,
				fStop = 15,
				cameraId = 69435579
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					276.572,
					0
				},
				targetPositionVInput = {
					-722.315,
					45.423,
					832.462
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
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
							outWeight = 0,
							inWeight = 0,
							time = 0,
							value = 0,
							inTangent = 0,
							outTangent = 1,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							time = 1,
							value = 1,
							inTangent = 1,
							outTangent = 0,
							weightedMode = 0
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
				blendExponentVInput = 4,
				fovVInput = 23,
				positionVInput = {
					-726.289,
					45.361,
					830.267
				},
				rotationVInput = {
					351.269,
					4.755,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 225,
				openDof = true,
				focalDistance = 270,
				fStop = 15,
				cameraId = 69365951
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 84,
						portId = "In"
					}
				}
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
						nodeId = 85,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 5,
				positionVInput = {
					-723.901,
					46.356,
					833.372
				},
				rotationVInput = {
					349.894,
					120.836,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 165,
				openDof = true,
				focalDistance = 171,
				fStop = 15,
				cameraId = 69435579
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Story_Sleep_Start",
				fadeDurationVInput = 0.2,
				loopDurationVInput = 90000
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 36,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400089,
				entityType = 2,
				processingTime = 0.883,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 88,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 5,
				positionVInput = {
					-726.312,
					46.573,
					835.526
				},
				rotationVInput = {
					1.375,
					136.546,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4,
				cameraId = 69435579
			}
		},
		{
			kind = 9
		},
		{
			kind = 9
		},
		{
			kind = 9
		},
		{
			kind = 17,
			inputs = {
				boneNameVInput = "Bip001 Head"
			}
		},
		{
			kind = 9
		},
		{
			kind = 9
		}
	}
}
