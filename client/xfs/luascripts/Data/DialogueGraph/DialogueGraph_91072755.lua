-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91072755.lua

return {
	startNodeId = 2,
	dialogueId = 91072755,
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
						nodeId = 4,
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
					enhanceAmbientIntensity = true,
					toplogoComList = {
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
						petChat = true,
						npc = true
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
						nodeId = 5,
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
						nodeId = 6,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 66,
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
						nodeId = 73,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 74,
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
						nodeId = 7,
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
						nodeId = 8,
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
						nodeId = 9,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 10,
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
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 135,
					portId = "EntityID"
				}
			},
			fields = {
				cameraPreset = 2,
				resetOrientation = true,
				reactPreset = 2,
				nodeMode = 0,
				enableGroupLookAt = true,
				enableDefaultLookAt = true
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
						nodeId = 12,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710069
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
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
						nodeId = 13,
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
						nodeId = 14,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 65,
						portId = "Stop"
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
				dialogueIdVInput = 6710070
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
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
						nodeId = 15,
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
						nodeId = 16,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 62,
						portId = "Stop"
					}
				},
				["2"] = {
					{
						nodeId = 60,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710071
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
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
						nodeId = 17,
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
						nodeId = 18,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 52,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 60,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710072
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
				duration = 0,
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
				In = 0
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
						nodeId = 54,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 52,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 53,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 56,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710073
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 4,
				duration = 4,
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
						nodeId = 21,
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
						nodeId = 22,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 50,
						portId = "In"
					}
				},
				["3"] = {
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
				dialogueIdVInput = 6710074
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
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
						nodeId = 23,
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
						nodeId = 24,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 47,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 49,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710075
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
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
						nodeId = 25,
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
						nodeId = 26,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 46,
						portId = "Stop"
					}
				},
				["2"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710076
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
				duration = 0,
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
						nodeId = 27,
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
						nodeId = 28,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 44,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 43,
						portId = "Stop"
					}
				},
				["3"] = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710077
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
				duration = 0,
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
						nodeId = 29,
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
						nodeId = 30,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 36,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 40,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710078
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
				duration = 0,
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
						nodeId = 31,
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
						nodeId = 32,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 36,
						portId = "Stop"
					}
				},
				["2"] = {
					{
						nodeId = 37,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6710079
			},
			fields = {
				blackScreenIntervalTime = 2,
				npcStaticId = -1,
				npcId = 5170100,
				matchAudioDuration = true,
				portCount = 1,
				skipTime = 0,
				duration = 0,
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
						nodeId = 33,
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
						nodeId = 34,
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
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 21,
			inputs = {
				blendTimeVInput = 3
			},
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
				staticIdVInput = 91141613,
				playableStateVInput = "TalkUpper_PointTo02_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 6,
				animationLayerVInput = 4
			},
			fields = {
				templateId = 5170100,
				processingTime = 5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"TalkUpper_PointTo02_Start",
					"TalkUpper_PointTo02_Loop",
					"TalkUpper_PointTo02_End"
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91141613,
				animationLayerVInput = 4,
				playableStateVInput = "TalkUpper_Like"
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
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-157.567,
					25.524,
					271.925
				},
				rotationVInput = {
					3.937,
					329.531,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 25.62,
				cameraId = 91150566,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 39,
						portId = "In"
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
					-157.722,
					25.503,
					272.188
				},
				rotationVInput = {
					1.531,
					328.155,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 25.62,
				cameraId = 91150530,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Emotion_Excited_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 4,
				processingTime = 1.167,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				aniStateList = {
					"Emotion_Excited_Start",
					"Emotion_Excited_Loop",
					"Emotion_Excited_End"
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
				fovVInput = 40,
				positionVInput = {
					-156.469,
					25.419,
					269.622
				},
				rotationVInput = {
					4.969,
					337.757,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 13.92,
				cameraId = 91150620,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				positionVInput = {
					-156.777,
					25.348,
					270.376
				},
				rotationVInput = {
					4.969,
					337.757,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 13.92,
				cameraId = 91150622,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 91141613,
				playableStateVInput = "Talk_Shrug_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Talk_Shrug_Start",
					"Talk_Shrug_Loop",
					"Talk_Shrug_End"
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
					-158.362,
					25.591,
					272.477
				},
				rotationVInput = {
					2.906,
					97.838,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 25.62,
				cameraId = 91150585,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
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
				fovVInput = 35,
				blendTimeVInput = 10,
				positionVInput = {
					-158.14,
					25.581,
					272.444
				},
				rotationVInput = {
					1.531,
					99.556,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 83,
				fStop = 25.62,
				cameraId = 91150595,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 1,
				staticIdVInput = 91141613,
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 1,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
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
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-157.567,
					25.524,
					271.925
				},
				rotationVInput = {
					3.937,
					329.531,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 84,
				fStop = 25.62,
				cameraId = 91150499,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 132,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 48,
						portId = "In"
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
					-157.722,
					25.503,
					272.188
				},
				rotationVInput = {
					1.531,
					328.155,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 84,
				fStop = 25.62,
				cameraId = 91150529,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 132,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Emotion_Think_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 4,
				processingTime = 1.733,
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
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-159.287,
					25.543,
					272.656
				},
				rotationVInput = {
					4.335,
					90.294,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 25.62,
				cameraId = 91150584,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 51,
						portId = "In"
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
					-159.288,
					25.543,
					272.427
				},
				rotationVInput = {
					3.819,
					83.246,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 111,
				fStop = 25.62,
				cameraId = 91150594,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 166,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead",
				staticIdVInput = 2
			},
			fields = {
				templateId = 4,
				processingTime = 2.367,
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
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial03",
				staticIdVInput = 91141613
			},
			fields = {
				templateId = 5170100,
				processingTime = 5,
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
			kind = 3,
			inputs = {
				fovVInput = 27,
				positionVInput = {
					-156.444,
					25.581,
					272.311
				},
				rotationVInput = {
					6,
					280.2,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 91150484,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 55,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendTimeVInput = 20,
				positionVInput = {
					-156.423,
					25.581,
					272.431
				},
				rotationVInput = {
					4.797,
					275.043,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
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
						nodeId = 57,
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
						nodeId = 58,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 53,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-134.051,
					25.206,
					273.058
				},
				rotationVInput = {
					2.906,
					179.02,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 91150485,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 15,
				positionVInput = {
					-134.001,
					25.057,
					270.134
				},
				rotationVInput = {
					2.906,
					179.02,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 91165011,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = 91141613
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.333,
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
			kind = 3,
			inputs = {
				fovVInput = 27,
				positionVInput = {
					-158.497,
					25.548,
					273.625
				},
				rotationVInput = {
					2.2,
					142.12,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.39,
				cameraId = 91150572,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 117,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 20,
				staticIdVInput = 91141613,
				playableStateVInput = "Talk_Cheeksupport_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.333,
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
				fovVInput = 27,
				positionVInput = {
					-156.444,
					25.581,
					272.311
				},
				rotationVInput = {
					6,
					280.2,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 91150345,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 64,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendTimeVInput = 20,
				positionVInput = {
					-156.423,
					25.581,
					272.431
				},
				rotationVInput = {
					4.797,
					275.043,
					0.019
				}
			},
			fields = {
				openDof = true,
				focalDistance = 138,
				fStop = 22.89,
				cameraId = 91150360,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 155,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 10,
				staticIdVInput = 91141613,
				playableStateVInput = "Emotion_Applaud_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				templateId = 5170100,
				processingTime = 1.333,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Applaud_Start",
					"Emotion_Applaud_Loop",
					"Emotion_Applaud_End"
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
				delayTime = 0.5
			},
			flowIn = {
				In = 0
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
						nodeId = 68,
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
						nodeId = 69,
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
					310.043,
					0
				},
				targetPositionVInput = {
					-157.185,
					24.263,
					272.206
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
				delayTime = 1
			},
			flowIn = {
				In = 0
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
			kind = 3,
			inputs = {
				fovVInput = 40,
				positionVInput = {
					-152.644,
					26.538,
					271.569
				},
				rotationVInput = {
					9.094,
					278.308,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 331,
				fStop = 7.74,
				cameraId = 91150304,
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
						nodeId = 72,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendTimeVInput = 10,
				positionVInput = {
					-153.495,
					26.392,
					271.692
				},
				rotationVInput = {
					10.297,
					278.136,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 331,
				fStop = 7.74,
				cameraId = 91150309,
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
				delayTime = 0.8
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
		{
			kind = 14,
			inputs = {
				staticIdVInput = 91141613,
				targetEulerAngleVInput = {
					0,
					126.356,
					0
				},
				targetPositionVInput = {
					-158.19,
					24.27,
					272.85
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
		[135] = {
			kind = 9,
			inputs = {
				staticIdVInput = 91141613
			},
			fields = {
				entityType = 2
			}
		}
	}
}
