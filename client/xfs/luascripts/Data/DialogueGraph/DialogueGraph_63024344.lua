-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_63024344.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 63024344,
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
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
			},
			flowIn = {
				In = 0
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
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = false,
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
					toplogoComList = {
						actionState = true,
						vlog = true,
						teamSpeech = true,
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
						alert = true
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
						nodeId = 0
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
			kind = 22,
			flowIn = {
				In = 0
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
				portCount = 8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 49
					}
				},
				["2"] = {
					{
						portId = "Play",
						nodeId = 6
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 81
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 45
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 55
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 60
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "BGM_Scene_BloomvilleView_FirstMeeting"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304094
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -484332062,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				ShowFinOut = {
					{
						portId = "StopLip",
						nodeId = 44
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
						nodeId = 9
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
						nodeId = 14
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
						nodeId = 13
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 41
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 43
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 2,
				durationVInput = 1,
				targetEulerAngleVInput = {
					0,
					85,
					0
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
						portId = "In",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Overlook_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 1,
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 2.2,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				aniStateList = {
					"Daily_Overlook_Start",
					"Daily_Overlook_Loop",
					"Daily_Overlook_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -484332062,
				durationVInput = 1,
				targetEulerAngleVInput = {
					0,
					60,
					0
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 43,
				blendFuncVInput = "Linear",
				positionVInput = {
					-587.849,
					54.744,
					826.127
				},
				rotationVInput = {
					7.94,
					83.033,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 3325,
				fStop = 15,
				cameraId = 91292151,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendFuncVInput = "Linear",
				blendTimeVInput = 3,
				positionVInput = {
					-588.966,
					55.639,
					828.192
				},
				rotationVInput = {
					2.784,
					88.534,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91292152,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				portCount = 3
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
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendFuncVInput = "Linear",
				positionVInput = {
					-555.49,
					52.914,
					837.01
				},
				rotationVInput = {
					344.22,
					24.592,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91293624,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 35,
				blendFuncVInput = "Linear",
				blendTimeVInput = 3,
				positionVInput = {
					-555.349,
					52.914,
					836.938
				},
				rotationVInput = {
					344.392,
					27.858,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91293625,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 3304095
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -826559229,
				npcId = 400077,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 20
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
						portId = "In",
						nodeId = 23
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendFuncVInput = "Linear",
				positionVInput = {
					-546.554,
					51.578,
					819.484
				},
				rotationVInput = {
					344.048,
					95.925,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91309959,
				visualizeDOF = false,
				squeezeFactor = 1
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
				fovVInput = 27,
				blendFuncVInput = "Linear",
				blendTimeVInput = 4,
				positionVInput = {
					-546.575,
					51.656,
					819.487
				},
				rotationVInput = {
					344.907,
					97.988,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91309957,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 3304096
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -484332062,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 3.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 24
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
						portId = "In",
						nodeId = 25
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendFuncVInput = "Linear",
				positionVInput = {
					-455.383,
					66.078,
					754.156
				},
				rotationVInput = {
					22.881,
					60.173,
					359.286
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91297765,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendFuncVInput = "Linear",
				blendTimeVInput = 5,
				positionVInput = {
					-455.383,
					66.078,
					754.156
				},
				rotationVInput = {
					19.959,
					63.478,
					359.3
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91297794,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304097
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -484332062,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 4.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 29
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 31
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-518.392,
					54.017,
					840.851
				},
				rotationVInput = {
					332.526,
					16.262,
					0.236
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91046495,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
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
				fovVInput = 35,
				blendTimeVInput = 6,
				positionVInput = {
					-518.184,
					54.404,
					841.565
				},
				rotationVInput = {
					332.011,
					16.26,
					0.238
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91046496,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304098
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
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
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 33
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
						portId = "In",
						nodeId = 34
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
						portId = "In",
						nodeId = 35
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 38
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 40
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
						portId = "In",
						nodeId = 36
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
						nodeId = 37
					}
				},
				["1"] = {
					{
						portId = "End",
						nodeId = 0
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
				In = 0
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
						nodeId = 39
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				positionVInput = {
					-573.505,
					48.985,
					828.029
				},
				rotationVInput = {
					355.323,
					93.482,
					0
				}
			},
			fields = {
				sensorWidth = 454,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 800,
				fStop = 15,
				cameraId = 91365317,
				visualizeDOF = false,
				squeezeFactor = 1
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
					0.67,
					84.996,
					359.33
				},
				targetPositionVInput = {
					-569.603,
					47.918,
					827.805
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -76487011,
				staticIdVInput = -1730750753
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Overlook_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				staticIdVInput = -826559229
			},
			fields = {
				templateId = 400077,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Daily_Overlook_Start",
					"Daily_Overlook_Loop",
					"Daily_Overlook_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Smile",
				entityIdVInput = -484332062
			},
			fields = {
				activePlayEmotion = true,
				noBlink = false,
				activePlayLip = true
			},
			flowIn = {
				StopLip = 1,
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400204,
				positionVInput = {
					-570.62,
					47.94,
					827.24
				},
				rotationVInput = {
					0,
					191.199,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -484332062
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				In = 0
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
						nodeId = 44
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
						portId = "In",
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Lefthand",
				staticIdVInput = -484332062
			},
			fields = {
				templateId = 400204,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 50
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
						nodeId = 51
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 52
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
				In = 0
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
						nodeId = 53
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-571.602,
					48.904,
					825.888
				},
				rotationVInput = {
					356.768,
					37.999,
					0
				}
			},
			fields = {
				sensorWidth = 453,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 400,
				fStop = 25,
				cameraId = 91291787,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 54
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 10,
				positionVInput = {
					-571.735,
					48.892,
					825.717
				},
				rotationVInput = {
					356.768,
					37.999,
					0
				}
			},
			fields = {
				sensorWidth = 453,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 400,
				fStop = 25,
				cameraId = 91291255,
				visualizeDOF = false,
				squeezeFactor = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 56
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
						portId = "In",
						nodeId = 57
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 58
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 89415699,
				targetPositionVInput = {
					-541.95,
					52.06,
					817.93
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400292,
				positionVInput = {
					-540.129,
					51.591,
					817.779
				},
				rotationVInput = {
					0,
					56.2,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1730750753
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 59
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1730750753,
				playableStateVInput = "Emotion_Applaud_Loop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				speedVInput = 0.7
			},
			fields = {
				templateId = 400292,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud_Loop",
					"Emotion_Applaud_Loop",
					"Emotion_Applaud_Loop"
				}
			},
			flowIn = {
				In = 0
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
				["1"] = {
					{
						portId = "In",
						nodeId = 61
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 69
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 79
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 66
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 68
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 75
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 77
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400076,
				positionVInput = {
					-538.13,
					52.873,
					818.133
				},
				rotationVInput = {
					0.277,
					256,
					0.906
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -76487011
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 62
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
						portId = "In",
						nodeId = 63
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 64
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 65
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -76487011,
				staticIdVInput = -1730750753
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 89415699,
				staticIdVInput = -76487011
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -76487011,
				playableStateVInput = "Behav_LoveStart",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				speedVInput = 0.5
			},
			fields = {
				templateId = 400076,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Behav_LoveStart",
					"Behav_LoveLoop",
					"Behav_LoveEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400311,
				positionVInput = {
					-448.851,
					63.902,
					756.178
				},
				rotationVInput = {
					0,
					275.684,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -2116861493
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				staticIdVInput = -2116861493
			},
			fields = {
				templateId = 400311,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"IdleSpecial",
					"IdleSpecial",
					"IdleSpecial"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400068,
				positionVInput = {
					-448.38,
					63.6,
					759.108
				},
				rotationVInput = {
					0,
					289.732,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1743653907
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400068,
				positionVInput = {
					-448.466,
					61.687,
					756.068
				},
				rotationVInput = {
					0,
					275.684,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -644250477
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 70
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
						portId = "In",
						nodeId = 71
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
						portId = "In",
						nodeId = 72
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 73
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_SleepLoop",
				staticIdVInput = -644250477,
				loopDurationVInput = 999
			},
			fields = {
				templateId = 400068,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 74
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -644250477,
				targetEulerAngleVInput = {
					0,
					275.684,
					0
				},
				targetPositionVInput = {
					-448.422,
					62.332,
					756.208
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 201405,
				positionVInput = {
					-552.187,
					53.868,
					841.001
				},
				rotationVInput = {
					0,
					187.844,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1948599373
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 76
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1948599373,
				playableStateVInput = "EnvBehav_StuckLoop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				speedVInput = 0.8
			},
			fields = {
				templateId = 400085,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_StuckLoop",
					"EnvBehav_StuckLoop",
					"EnvBehav_StuckLoop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400085,
				positionVInput = {
					-553.689,
					53.374,
					840.672
				},
				rotationVInput = {
					0,
					160,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -2012806553
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 78
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_DoubtLoop",
				staticIdVInput = -2012806553,
				loopDurationVInput = 999
			},
			fields = {
				templateId = 400085,
				processingTime = 0.267,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400086,
				positionVInput = {
					-551.285,
					53.113,
					840.638
				},
				rotationVInput = {
					0,
					254.8,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -836958105
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 80
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Plant_Loop",
				staticIdVInput = -836958105,
				loopDurationVInput = 999
			},
			fields = {
				templateId = 400086,
				processingTime = 17.167,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
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
						nodeId = 82
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 83
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400077,
				positionVInput = {
					-570.675,
					47.881,
					828.184
				},
				rotationVInput = {
					0,
					161,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -826559229
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
					0.277,
					202.991,
					0.906
				},
				targetPositionVInput = {
					-569.603,
					47.918,
					827.805
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		}
	}
}
