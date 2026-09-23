-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_87039593.lua

return {
	dialogueId = 87039593,
	schema = 1,
	startNodeId = 2,
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
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = false,
					toplogoComList = {
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						portId = "End",
						nodeId = 1
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 4
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
						portId = "In",
						nodeId = 7
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 5
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 39
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 36
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 42
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 46
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 48
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 50
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-10.453,
					102.111,
					-57.251
				},
				rotationVInput = {
					352.383,
					316.839,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 644,
				fStop = 4,
				cameraId = 91384164,
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
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 4,
				positionVInput = {
					-10.767,
					102.143,
					-57.141
				},
				rotationVInput = {
					353.758,
					321.652,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 644,
				fStop = 4,
				cameraId = 91384606,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 8
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
						portId = "In",
						nodeId = 11
					}
				},
				["1"] = {
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
				fovVInput = 40,
				positionVInput = {
					-13.61,
					102.149,
					-49.296
				},
				rotationVInput = {
					2.696,
					231.343,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 200,
				fStop = 11.67,
				cameraId = 91384568,
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
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 5,
				positionVInput = {
					-13.655,
					102.323,
					-49.268
				},
				rotationVInput = {
					358.743,
					231,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 200,
				fStop = 11.67,
				cameraId = 91384667,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 12
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 13
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 33
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 14
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 15
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 21
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 23
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 25
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 27
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 31
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505053
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 16
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
						portId = "In",
						nodeId = 17
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505054
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = 91329900,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 5.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				endSkipVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 20
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-4.513,
					102.695,
					-49.87
				},
				rotationVInput = {
					2.009,
					18.479,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91384529,
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
						nodeId = 22
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendTimeVInput = 10,
				positionVInput = {
					-1.302,
					104.249,
					-50.323
				},
				rotationVInput = {
					6.306,
					1.462,
					0
				}
			},
			fields = {
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91384558,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1385190128,
				targetEulerAngleVInput = {
					0,
					64.16,
					0
				},
				targetPositionVInput = {
					-7.833,
					100.184,
					-43.283
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1385190128,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					355.305,
					0
				},
				targetPositionVInput = {
					-1.791,
					100.265,
					-42.364
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1127636232,
				targetEulerAngleVInput = {
					0,
					55.198,
					0
				},
				targetPositionVInput = {
					-1.305,
					100.149,
					-40.298
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1127636232,
				maxLimitTimeVInput = 25,
				targetEulerAngleVInput = {
					0,
					346.178,
					0
				},
				targetPositionVInput = {
					2.4,
					100.058,
					-37.8
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					355.305,
					0
				},
				targetPositionVInput = {
					-1.791,
					100.265,
					-42.364
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = 1,
				targetEulerAngleVInput = {
					0,
					359.003,
					0
				},
				targetPositionVInput = {
					-3.32,
					100.216,
					-41.552
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
			kind = 14,
			inputs = {
				staticIdVInput = -156307471,
				targetEulerAngleVInput = {
					0,
					31.295,
					0
				},
				targetPositionVInput = {
					-0.5,
					100.202,
					-40.964
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -156307471,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					317.677,
					0
				},
				targetPositionVInput = {
					3.43,
					100.028,
					-37.81
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -224848157,
				targetEulerAngleVInput = {
					0,
					49.733,
					0
				},
				targetPositionVInput = {
					-8.679,
					100.168,
					-42.807
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -224848157,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					359.003,
					0
				},
				targetPositionVInput = {
					-3.32,
					100.216,
					-41.552
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				positionVInput = {
					-9.362,
					109.325,
					-37.757
				},
				rotationVInput = {
					9.572,
					163.344,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 756,
				fStop = 32,
				cameraId = 91384698,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 292,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendTimeVInput = 8,
				positionVInput = {
					-11.52,
					108.703,
					-38.357
				},
				rotationVInput = {
					7.165,
					153.031,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 756,
				fStop = 32,
				cameraId = 90831878,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 292,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1385190128,
				maxLimitTimeVInput = 25,
				targetEulerAngleVInput = {
					0,
					355.305,
					0
				},
				targetPositionVInput = {
					-1.791,
					100.265,
					-42.364
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990010,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-15.935,
					101.241,
					-50.222
				},
				rotationVInput = {
					0,
					40.483,
					0
				}
			},
			fields = {
				entityId = -1127636232,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "FallToGroundL",
				staticIdVInput = -1127636232
			},
			fields = {
				templateId = 990010,
				processingTime = 1.15,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1127636232,
				targetEulerAngleVInput = {
					0,
					55.198,
					0
				},
				targetPositionVInput = {
					-1.305,
					100.149,
					-40.298
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 1,
				positionVInput = {
					-15.99,
					101.143,
					-51.028
				},
				rotationVInput = {
					0,
					40,
					0
				}
			},
			fields = {
				entityId = -1385190128,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 40
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "FallToGroundH",
				staticIdVInput = -1385190128
			},
			fields = {
				templateId = 0,
				processingTime = 2.6,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_LookAround02",
				staticIdVInput = -1385190128,
				speedVInput = 1.2
			},
			fields = {
				templateId = 303,
				processingTime = 9.633,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990011,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-15.147,
					101.241,
					-50.71
				},
				rotationVInput = {
					0,
					44.059,
					0
				}
			},
			fields = {
				entityId = -156307471,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 43
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "FallToGroundL",
				staticIdVInput = -156307471
			},
			fields = {
				templateId = 990011,
				processingTime = 0.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -156307471,
				speedVInput = 0.75,
				targetEulerAngleVInput = {
					0,
					55.198,
					0
				},
				targetPositionVInput = {
					-1.305,
					100.149,
					-40.298
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							outTangent = 1,
							inTangent = 0,
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0
						},
						{
							outTangent = 0,
							inTangent = 1,
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
							inWeight = 0
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
						portId = "In",
						nodeId = 45
					}
				}
			}
		},
		{
			kind = 29,
			inputs = {
				staticIdVInput = -156307471
			},
			fields = {
				emojiName = "Happy",
				duration = 5
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 3,
				positionVInput = {
					-14.962,
					101.143,
					-51.035
				},
				rotationVInput = {
					0,
					40,
					0
				}
			},
			fields = {
				entityId = -224848157,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "FallToGroundH",
				staticIdVInput = -224848157
			},
			fields = {
				templateId = 0,
				processingTime = 2.6,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					40,
					0
				},
				targetPositionVInput = {
					-15.99,
					101.143,
					-51.028
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = 1,
				targetEulerAngleVInput = {
					0,
					40,
					0
				},
				targetPositionVInput = {
					-14.962,
					101.143,
					-51.035
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
			kind = 16,
			inputs = {
				slotParamVInput = 990062,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					11.18,
					101.48,
					-63.43
				},
				rotationVInput = {
					0,
					270,
					0
				}
			},
			fields = {
				entityId = -2037474542,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 51
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990061,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					8.66,
					101.48,
					-67.55
				},
				rotationVInput = {
					0,
					349.714,
					0
				}
			},
			fields = {
				entityId = -1370564884,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
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
			kind = 16,
			inputs = {
				slotParamVInput = 990063,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					14.581,
					102.429,
					-68.306
				},
				rotationVInput = {
					0,
					310.45,
					0
				}
			},
			fields = {
				entityId = -182549301,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		}
	}
}
