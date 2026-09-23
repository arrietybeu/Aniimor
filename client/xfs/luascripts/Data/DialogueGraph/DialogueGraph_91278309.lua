-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91278309.lua

return {
	startNodeId = 1,
	dialogueId = 91278309,
	schema = 1,
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
						nodeId = 2,
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 3,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 4,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108085,
				disablePresetLookAtVInput = true
			},
			fields = {
				duration = 2,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 5200041,
				positionVInput = {
					7.085,
					25.007,
					444.845
				},
				rotationVInput = {
					0,
					210.586,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1251227112
			},
			flowIn = {
				In = 0
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
				staticIdVInput = -1251227112,
				speedVInput = 0.75,
				moveTypeVInput = 4,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					49.5,
					0
				},
				targetPositionVInput = {
					21.34,
					25.1,
					449.709
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
							inTangent = 0,
							value = 0,
							outTangent = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0
						},
						{
							inTangent = 1,
							value = 1,
							outTangent = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1
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
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Love",
				staticIdVInput = -1251227112
			},
			fields = {
				entityType = 2,
				templateId = 5200041,
				processingTime = 3.767,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
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
			kind = 19,
			inputs = {
				staticIdVInput = -1251227112,
				speedVInput = 0.75,
				moveTypeVInput = 4,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					230.6,
					0
				},
				targetPositionVInput = {
					20.5,
					25.126,
					424.868
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
							inTangent = 0,
							value = 0,
							outTangent = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0
						},
						{
							inTangent = 1,
							value = 1,
							outTangent = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1
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
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1251227112,
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true
			},
			fields = {
				entityType = 2,
				processingTime = 0,
				templateId = 5200041,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
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
			kind = 19,
			inputs = {
				staticIdVInput = -1251227112,
				speedVInput = 0.75,
				moveTypeVInput = 4,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					180,
					0
				},
				targetPositionVInput = {
					31.37,
					25,
					417.09
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
							inTangent = 0,
							value = 0,
							outTangent = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0
						},
						{
							inTangent = 1,
							value = 1,
							outTangent = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1
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
						nodeId = 10,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1251227112,
				speedVInput = 0.75,
				moveTypeVInput = 4,
				maxLimitTimeVInput = 10,
				targetPositionVInput = {
					31.37,
					25,
					417.09
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
							inTangent = 0,
							value = 0,
							outTangent = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0
						},
						{
							inTangent = 1,
							value = 1,
							outTangent = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1
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
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Love",
				staticIdVInput = -1251227112
			},
			fields = {
				entityType = 2,
				templateId = 5200041,
				processingTime = 3.767,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				positionVInput = {
					-3.773,
					27.335,
					447.535
				},
				rotationVInput = {
					7.477,
					106.582,
					0.009
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91288571,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					89.402,
					0
				},
				targetPositionVInput = {
					-0.016,
					25.101,
					444.483
				}
			},
			fields = {
				setRotation = true,
				reset = false,
				setPosition = true
			},
			flowIn = {
				In = 0
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
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = 0
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
			kind = 21,
			inputs = {
				blendTimeVInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
			}
		}
	}
}
