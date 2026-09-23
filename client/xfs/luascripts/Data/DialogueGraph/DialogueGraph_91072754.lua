-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91072754.lua

return {
	schema = 1,
	startNodeId = 2,
	dialogueId = 91072754,
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
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					pauseNearbyMonsterAI = true,
					toplogoComList = {
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						vlog = true,
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 1,
						portId = "End"
					}
				},
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
				portCount = 5
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
						nodeId = 61,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 68,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 69,
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
				delayTime = 1
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
						nodeId = 8,
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
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						nodeId = 9,
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 10,
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
				In = 0
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
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_LookAround02",
				staticIdVInput = 2,
				speedVInput = 1.3
			},
			fields = {
				templateId = 403,
				processingTime = 9.767,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
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
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Confused_Start",
				staticIdVInput = 2,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 3,
				processingTime = 0,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5
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
						nodeId = 15,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 55,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 57,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 58,
						portId = "In"
					}
				},
				["4"] = {
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
				dialogueIdVInput = 6710054
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
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
				portCount = 9
			},
			flowIn = {
				In = 0
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
						nodeId = 46,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 48,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 52,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 53,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 12,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710055
			},
			fields = {
				skipTime = 5,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				duration = 6.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				portCount = 6
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
						nodeId = 43,
						portId = "closeUIFInput"
					}
				},
				["2"] = {
					{
						nodeId = 44,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710056
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
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
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 40,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 42,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710057
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				duration = 11.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 27,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 39,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710058
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 2.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 25,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 27,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 28,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-158.895,
					25.588,
					276.236
				},
				rotationVInput = {
					4.937,
					152.637,
					0.021
				}
			},
			fields = {
				cameraId = 91146138,
				openDof = true,
				focalDistance = 145,
				fStop = 12.69,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 131
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				blendTimeVInput = 10,
				fovVInput = 25,
				positionVInput = {
					-158.749,
					25.561,
					275.954
				},
				rotationVInput = {
					4.25,
					153.497,
					0.021
				}
			},
			fields = {
				cameraId = 91150111,
				openDof = true,
				focalDistance = 145,
				fStop = 12.69,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 131
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think_Start",
				staticIdVInput = 2,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 4,
				processingTime = 1.967,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				aniStateList = {
					"Emotion_Think_Start",
					"Emotion_Think_Loop",
					"Emotion_Think_End"
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1634834815,
				facialEmotionVInput = "Expect"
			},
			fields = {
				activePlayLip = false,
				activePlayEmotion = true,
				noBlink = true
			},
			flowIn = {
				In = 0,
				StopEmotion = 1
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
						portId = "StopEmotion"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Lefthand",
				loopDurationVInput = 2,
				staticIdVInput = -1634834815
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
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
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710059
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
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
		{
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710060
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				duration = 7.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
						portId = "In"
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
						nodeId = 36,
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Invite_Start",
				loopDurationVInput = 1,
				staticIdVInput = -1634834815,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Daily_Invite_Start",
					"Daily_Invite_Loop",
					"Daily_Invite_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-158.759,
					25.593,
					274.542
				},
				rotationVInput = {
					2.3,
					19.11,
					0.02
				}
			},
			fields = {
				cameraId = 91149931,
				openDof = true,
				focalDistance = 145,
				fStop = 12.69,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 131
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Cheeksupport_Start",
				loopDurationVInput = 2,
				staticIdVInput = -1634834815,
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Talk_Cheeksupport_Start",
					"Talk_Cheeksupport_Loop",
					"Talk_Cheeksupport_End"
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-159.08,
					25.579,
					276.682
				},
				rotationVInput = {
					6.597,
					145.296,
					0.021
				}
			},
			fields = {
				cameraId = 91145916,
				openDof = true,
				focalDistance = 173,
				fStop = 6.1,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 129
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 35,
				positionVInput = {
					-158.94,
					25.55,
					276.48
				},
				rotationVInput = {
					7.112,
					146.327,
					0.021
				}
			},
			fields = {
				cameraId = 91149939,
				openDof = true,
				focalDistance = 173,
				fStop = 6.1,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 129
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Story_Greet02"
			},
			fields = {
				templateId = 3,
				processingTime = 0,
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
			kind = 27,
			fields = {
				uid = 306,
				param = {
					style = 0,
					title = "CHARACTER_APPEARANCE_DESC_XIXI",
					name = "CHARACTER_APPEARANCE_NAME_XIXI",
					pos = {
						1650,
						-200,
						0
					}
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-158.852,
					25.552,
					273.638
				},
				rotationVInput = {
					5.6,
					22.93,
					0.02
				}
			},
			fields = {
				cameraId = 91145952,
				openDof = true,
				focalDistance = 139,
				fStop = 8.6,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 129
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10,
				fovVInput = 35,
				positionVInput = {
					-158.755,
					25.572,
					273.909
				},
				rotationVInput = {
					5.6,
					22.93,
					0.02
				}
			},
			fields = {
				cameraId = 91149998,
				openDof = true,
				focalDistance = 139,
				fStop = 8.6,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 129
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-158.984,
					25.391,
					275.859
				},
				rotationVInput = {
					0.468,
					135.104,
					0.02
				}
			},
			fields = {
				cameraId = 91145762,
				openDof = true,
				focalDistance = 90,
				fStop = 10.94,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 86
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 5,
				fovVInput = 35,
				positionVInput = {
					-158.984,
					25.39,
					275.859
				},
				rotationVInput = {
					0.5,
					142.32,
					0.02
				}
			},
			fields = {
				cameraId = 91145769,
				openDof = true,
				focalDistance = 90,
				fStop = 10.94,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 86
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 3.5,
				staticIdVInput = -1634834815,
				targetEulerAngleVInput = {
					0,
					1.969,
					0
				},
				targetPositionVInput = {
					-158.238,
					24.273,
					274.569
				}
			},
			fields = {
				reset = false,
				finishToSteer = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inTangent = 0,
							outWeight = 0,
							value = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							value = 1,
							weightedMode = 0,
							time = 1,
							inWeight = 0,
							outTangent = 0
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
						nodeId = 49,
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
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 50,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1634834815,
				playableStateVInput = "IdleSpecial03"
			},
			fields = {
				templateId = 5170100,
				processingTime = 5,
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
					177.558,
					0
				},
				targetPositionVInput = {
					-158.299,
					24.27,
					275.918
				}
			},
			fields = {
				setRotation = true,
				reset = false,
				setPosition = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -722733682,
				targetEulerAngleVInput = {
					0,
					323.299,
					0
				},
				targetPositionVInput = {
					-157.404,
					24.285,
					274.039
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
							outWeight = 0,
							value = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							value = 1,
							weightedMode = 0,
							time = 1,
							inWeight = 0,
							outTangent = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -2108004219,
				targetEulerAngleVInput = {
					0,
					304.972,
					0
				},
				targetPositionVInput = {
					-156.828,
					24.3,
					274.654
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
							outWeight = 0,
							value = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							value = 1,
							weightedMode = 0,
							time = 1,
							inWeight = 0,
							outTangent = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1634834815
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-159.793,
					25.651,
					275.965
				},
				rotationVInput = {
					3.67,
					73.26,
					0.02
				}
			},
			fields = {
				cameraId = 91145651,
				openDof = true,
				focalDistance = 145,
				fStop = 12.69,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 131
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				blendTimeVInput = 10,
				fovVInput = 25,
				positionVInput = {
					-159.385,
					25.625,
					276.088
				},
				rotationVInput = {
					1.951,
					73.603,
					0.02
				}
			},
			fields = {
				cameraId = 91145703,
				openDof = true,
				focalDistance = 145,
				fStop = 12.69,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 131
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 5170100,
				positionVInput = {
					-157.829,
					24.263,
					271.574
				},
				rotationVInput = {
					0,
					14.919,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1634834815
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 710026,
				positionVInput = {
					-156.375,
					24.24,
					271.416
				},
				rotationVInput = {
					0,
					334.411,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -722733682
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 710027,
				positionVInput = {
					-155.66,
					24.22,
					271.994
				},
				rotationVInput = {
					0,
					307.639,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -2108004219
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					232.743,
					0
				},
				targetPositionVInput = {
					-158.203,
					24.279,
					276.444
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
							outWeight = 0,
							value = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							value = 1,
							weightedMode = 0,
							time = 1,
							inWeight = 0,
							outTangent = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 62,
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
				In = 0
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
						nodeId = 64,
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
					200.22,
					0
				},
				targetPositionVInput = {
					-157.1,
					24.336,
					279.047
				}
			},
			fields = {
				setRotation = true,
				reset = false,
				setPosition = true
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
						nodeId = 66,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-157.833,
					25.506,
					279.706
				},
				rotationVInput = {
					1.328,
					199.046,
					0.019
				}
			},
			fields = {
				cameraId = 91149786,
				openDof = true,
				focalDistance = 221,
				fStop = 20.81,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15,
				fovVInput = 40,
				positionVInput = {
					-157.686,
					25.535,
					278.115
				},
				rotationVInput = {
					2.4,
					209.188,
					0.019
				}
			},
			fields = {
				cameraId = 91149787,
				openDof = true,
				focalDistance = 194,
				fStop = 17.46,
				recombineQuality = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 50,
			inputs = {
				enableFillLightVInput = true,
				fillLightIntensityVInput = 14367
			},
			flowIn = {
				In = 0
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
						nodeId = 70,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 501018,
				positionVInput = {
					-160.7,
					24.24,
					274.91
				},
				rotationVInput = {
					0,
					113.57,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1464805727
			},
			flowIn = {
				In = 0
			}
		}
	}
}
