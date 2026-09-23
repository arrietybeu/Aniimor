-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_66329284.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 66329284,
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
			kind = 24,
			inputs = {
				switchToLocomotionVInput = true,
				switchToPlayerVInput = true
			},
			flowIn = {
				In = 0
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
			kind = 58,
			inputs = {
				waitPlayerIdleVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				modeInfo = {
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
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true
					}
				}
			},
			flowIn = {
				In = 0
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
			kind = 22,
			inputs = {
				blendVInput = 0.5
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
			kind = 4,
			fields = {
				delayTime = 1.3
			},
			flowIn = {
				In = 0
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
			kind = 23,
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
			inputs = {
				npcIdVInput = 65376064
			},
			fields = {
				reactPreset = 2,
				nodeMode = 0,
				enableGroupLookAt = true,
				enableDefaultLookAt = true,
				cameraPreset = 0,
				resetOrientation = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
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
				portCount = 6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 14,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 24,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 10,
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
						nodeId = 101,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-464.648,
					64.516,
					813.576
				},
				rotationVInput = {
					7.851,
					57.039,
					0.015
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 4,
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-464.789,
					64.516,
					813.676
				},
				rotationVInput = {
					7.851,
					57.039,
					0.015
				}
			},
			fields = {
				fStop = 17,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 70,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 190
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					2.525,
					0
				},
				targetPositionVInput = {
					-463.075,
					62.69,
					814.574
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 105,
					portId = "EntityID"
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
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 2,
				playableStateVInput = "Emotion_Think_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 105,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400104,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					113.187,
					0
				},
				targetPositionVInput = {
					-465.7,
					62.692,
					818.37
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 102,
					portId = "EntityID"
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
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-465.1,
					62.692,
					818.8
				},
				rotationVInput = {
					0,
					123.484,
					0
				}
			},
			fields = {
				entityId = -1972318408,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.75,
				targetEulerAngleVInput = {
					0,
					165,
					0
				},
				targetPositionVInput = {
					-464.934,
					62.691,
					818.414
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
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
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0
						},
						{
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		[18] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Helpless"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 4.583,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[19] = {
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[20] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 4,
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[21] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 9.967,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[22] = {
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					224.329,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		[23] = {
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					60.745,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		[24] = {
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
						nodeId = 100,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		[25] = {
			kind = 16,
			inputs = {
				slotParamVInput = 500029,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-466.284,
					62.694,
					818.117
				},
				rotationVInput = {
					0,
					134.43,
					0
				}
			},
			fields = {
				entityId = -1661517291,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
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
		[26] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 8,
				playableStateVInput = "Emotion_Happy_Start",
				fadeDurationVInput = 0.3,
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 25,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 0.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 500030,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		[27] = {
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
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		[28] = {
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
						nodeId = 29,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 98,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 99,
						portId = "In"
					}
				}
			}
		},
		[29] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904091
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		[30] = {
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
						nodeId = 31,
						portId = "In"
					}
				}
			}
		},
		[31] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 2.7,
				playableStateVInput = "Talk_Introduce"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 4
			},
			flowIn = {
				In = 0
			}
		},
		[32] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904092
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		[33] = {
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
						nodeId = 39,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 34,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 94,
						portId = "In"
					}
				}
			}
		},
		[34] = {
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-466.053,
					64.052,
					814.912
				},
				rotationVInput = {
					358.362,
					93.065,
					0.011
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		[35] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 7,
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-467.24,
					64.318,
					814.976
				},
				rotationVInput = {
					358.362,
					93.065,
					0.011
				}
			},
			fields = {
				fStop = 18,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 92,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 168
			},
			flowIn = {
				In = 0
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
		[36] = {
			kind = 4,
			fields = {
				delayTime = 1.3
			},
			flowIn = {
				In = 0
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
		[37] = {
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-469.232,
					64.066,
					818.584
				},
				rotationVInput = {
					4.138,
					105.029,
					0.011
				}
			},
			fields = {
				fStop = 16,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 263,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 405
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		[38] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 6,
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-469.131,
					64.066,
					818.959
				},
				rotationVInput = {
					4.138,
					105.029,
					0.011
				}
			},
			fields = {
				fStop = 16,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 263,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 405
			},
			flowIn = {
				In = 0
			}
		},
		[39] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904094
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 13,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 4
			},
			flowIn = {
				In = 0
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
		[40] = {
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
						nodeId = 41,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 91,
						portId = "In"
					}
				}
			}
		},
		[41] = {
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
						nodeId = 42,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 89,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 90,
						portId = "In"
					}
				}
			}
		},
		[42] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904096
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
		[43] = {
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
						nodeId = 44,
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
						nodeId = 88,
						portId = "In"
					}
				}
			}
		},
		[44] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904097
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
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
				}
			}
		},
		[45] = {
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
						nodeId = 46,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 84,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				}
			}
		},
		[46] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904098
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		[47] = {
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
						nodeId = 48,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 81,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 82,
						portId = "In"
					}
				}
			}
		},
		[48] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904099
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
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
		[49] = {
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
				["3"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		[50] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904100
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
		[51] = {
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
						nodeId = 52,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 78,
						portId = "In"
					}
				}
			}
		},
		[52] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904101
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
		[53] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904102
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
				}
			}
		},
		[54] = {
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
						nodeId = 55,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 77,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		[55] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904103
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 1
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
						nodeId = 74,
						portId = "In"
					}
				}
			}
		},
		[56] = {
			kind = 7,
			fields = {
				dialogueId = 3904105
			},
			flowIn = {
				In = 0
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
		[57] = {
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
						nodeId = 58,
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
						nodeId = 22,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				}
			}
		},
		[58] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904107
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 15,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		[59] = {
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
						nodeId = 60,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 72,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 71,
						portId = "In"
					}
				}
			}
		},
		[60] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904108
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		[61] = {
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
						nodeId = 62,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 68,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 69,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 70,
						portId = "In"
					}
				}
			}
		},
		[62] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904109
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				}
			}
		},
		[63] = {
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
						nodeId = 64,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		[64] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904110
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 10,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				}
			}
		},
		[65] = {
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 66,
						portId = "In"
					}
				}
			}
		},
		[66] = {
			kind = 23,
			flowIn = {
				In = 0
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
		[67] = {
			kind = 3,
			inputs = {
				fovVInput = 55,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.38,
					63.971,
					817.916
				},
				rotationVInput = {
					5.503,
					29.06,
					0.001
				}
			},
			fields = {
				fStop = 12,
				cameraId = 72347881,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 82
			},
			flowIn = {
				In = 0
			}
		},
		[68] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 117,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 7.033,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[69] = {
			kind = 3,
			inputs = {
				fovVInput = 56,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-465.056,
					64.018,
					818.622
				},
				rotationVInput = {
					3.441,
					233.399,
					0.001
				}
			},
			fields = {
				fStop = 29.86,
				cameraId = 72891998,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 304,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160
			},
			flowIn = {
				In = 0
			}
		},
		[70] = {
			kind = 28,
			inputs = {
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		[71] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-466.11,
					64.056,
					818.048
				},
				rotationVInput = {
					353.55,
					115.615,
					0.011
				}
			},
			fields = {
				fStop = 29.86,
				cameraId = 72891999,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 304,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160
			},
			flowIn = {
				In = 0
			}
		},
		[72] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Normal"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 116,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 4.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[73] = {
			kind = 3,
			inputs = {
				fovVInput = 55,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.38,
					63.971,
					817.916
				},
				rotationVInput = {
					5.503,
					29.06,
					0.001
				}
			},
			fields = {
				fStop = 12,
				cameraId = 72892000,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 82
			},
			flowIn = {
				In = 0
			}
		},
		[74] = {
			kind = 7,
			fields = {
				dialogueId = 3904106
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 75,
						portId = "In"
					}
				}
			}
		},
		[75] = {
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
						nodeId = 73,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 22,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 76,
						portId = "In"
					}
				}
			}
		},
		[76] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904042
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		[77] = {
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.909,
					66.163,
					812.829
				},
				rotationVInput = {
					26.277,
					6.991,
					0.008
				}
			},
			fields = {
				fStop = 11.14,
				cameraId = 72347882,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 557
			},
			flowIn = {
				In = 0
			}
		},
		[78] = {
			kind = 3,
			inputs = {
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-469.18,
					64.066,
					818.784
				},
				rotationVInput = {
					4.138,
					105.029,
					0.011
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 79,
						portId = "In"
					}
				}
			}
		},
		[79] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				fovVInput = 20,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-469.131,
					64.066,
					818.959
				},
				rotationVInput = {
					4.138,
					105.029,
					0.011
				}
			},
			fields = {
				fStop = 25.51,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 395
			},
			flowIn = {
				In = 0
			}
		},
		[80] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.365,
					64.04,
					816.412
				},
				rotationVInput = {
					3.863,
					3.961,
					0.008
				}
			},
			fields = {
				fStop = 13.23,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 272,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 222
			},
			flowIn = {
				In = 0
			}
		},
		[81] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-466.11,
					64.056,
					818.048
				},
				rotationVInput = {
					353.55,
					115.615,
					0.011
				}
			},
			fields = {
				fStop = 29.86,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 304,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160
			},
			flowIn = {
				In = 0
			}
		},
		[82] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 5,
				playableStateVInput = "Emotion_Smile_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 113,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 3.067,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400168
			},
			flowIn = {
				In = 0
			}
		},
		[83] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Anger_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				processingTime = 1.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = 0
			}
		},
		[84] = {
			kind = 3,
			inputs = {
				fovVInput = 15,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-463.59,
					65.577,
					820.104
				},
				rotationVInput = {
					18.989,
					169.249,
					0.011
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 85,
						portId = "In"
					}
				}
			}
		},
		[85] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 30,
				fovVInput = 15,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-463.219,
					65.48,
					819.887
				},
				rotationVInput = {
					18.989,
					169.249,
					0.011
				}
			},
			fields = {
				fStop = 6.93,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 77,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 664
			},
			flowIn = {
				In = 0
			}
		},
		[86] = {
			kind = 3,
			inputs = {
				fovVInput = 26,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.527,
					64.269,
					818.597
				},
				rotationVInput = {
					2.625,
					147.382,
					0.011
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
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
		[87] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				fovVInput = 26,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-465.375,
					64.269,
					818.695
				},
				rotationVInput = {
					2.075,
					147.244,
					0.011
				}
			},
			fields = {
				fStop = 32,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 180
			},
			flowIn = {
				In = 0
			}
		},
		[88] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 2.7,
				playableStateVInput = "Emotion_Think_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 104,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400168,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		[89] = {
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.762,
					63.163,
					816.854
				},
				rotationVInput = {
					359.178,
					340.932,
					0
				}
			},
			fields = {
				fStop = 2,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 47,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 88
			},
			flowIn = {
				In = 0
			}
		},
		[90] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 8,
				playableStateVInput = "Emotion_Happy_Start",
				fadeDurationVInput = 0.3,
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 100,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 0.833,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 500030
			},
			flowIn = {
				In = 0
			}
		},
		[91] = {
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
						nodeId = 92,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 93,
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
		[92] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3904095
			},
			fields = {
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
		[93] = {
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					-465.762,
					63.163,
					816.854
				},
				rotationVInput = {
					359.178,
					340.932,
					0
				}
			},
			fields = {
				fStop = 2,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 47,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 88
			},
			flowIn = {
				In = 0
			}
		},
		[94] = {
			kind = 19,
			inputs = {
				targetEulerAngleVInput = {
					0,
					279.572,
					0
				},
				targetPositionVInput = {
					-464.943,
					62.694,
					814.837
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 103,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = false,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0
						},
						{
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
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
				FinishOut = {
					{
						nodeId = 95,
						portId = "In"
					}
				}
			}
		},
		[95] = {
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					329.96,
					0
				},
				targetPositionVInput = {
					-464.618,
					62.694,
					817.4
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 103,
					portId = "EntityID"
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
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0
						},
						{
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		[96] = {
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				positionVInput = {
					-463.673,
					64.122,
					816.925
				},
				rotationVInput = {
					3.863,
					308.406,
					0.011
				}
			},
			fields = {
				fStop = 4,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 97,
						portId = "In"
					}
				}
			}
		},
		[97] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				blendFuncVInput = "Cubic",
				positionVInput = {
					-464.077,
					64.087,
					817.245
				},
				rotationVInput = {
					3.863,
					308.406,
					0.011
				}
			},
			fields = {
				fStop = 9,
				cameraId = 69365951,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 163
			},
			flowIn = {
				In = 0
			}
		},
		[98] = {
			kind = 19,
			inputs = {
				speedVInput = 0.865,
				targetEulerAngleVInput = {
					0,
					146.479,
					0
				},
				targetPositionVInput = {
					-465.453,
					62.692,
					818.082
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 106,
					portId = "EntityID"
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
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							weightedMode = 0
						},
						{
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		[99] = {
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 111,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 110,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[100] = {
			kind = 16,
			inputs = {
				slotParamVInput = 400109,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-466.284,
					62.694,
					818.117
				},
				rotationVInput = {
					0,
					134.43,
					0
				}
			},
			fields = {
				entityId = -68397360,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
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
		[101] = {
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 102,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 105,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[102] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[103] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[104] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[105] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[106] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[110] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[111] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[113] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[114] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[115] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 0
			}
		},
		[116] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 2
			}
		},
		[117] = {
			kind = 9,
			inputs = {
				staticIdVInput = 65376064
			},
			fields = {
				entityType = 0
			}
		}
	}
}
