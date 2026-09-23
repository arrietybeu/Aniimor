-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_77932341.lua

return {
	startNodeId = 2,
	dialogueId = 77932341,
	schema = 1,
	nodes = {
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
					showHud = true,
					hideAllUI = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true,
						photo = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 52,
						portId = "In"
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
			kind = 2,
			fields = {
				portCount = 23
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
						nodeId = 7,
						portId = "In"
					}
				},
				["10"] = {
					{
						nodeId = 89,
						portId = "In"
					}
				},
				["11"] = {
					{
						nodeId = 91,
						portId = "In"
					}
				},
				["12"] = {
					{
						nodeId = 95,
						portId = "In"
					}
				},
				["13"] = {
					{
						nodeId = 97,
						portId = "In"
					}
				},
				["14"] = {
					{
						nodeId = 99,
						portId = "In"
					}
				},
				["15"] = {
					{
						nodeId = 101,
						portId = "In"
					}
				},
				["16"] = {
					{
						nodeId = 103,
						portId = "In"
					}
				},
				["17"] = {
					{
						nodeId = 105,
						portId = "In"
					}
				},
				["18"] = {
					{
						nodeId = 107,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				},
				["22"] = {
					{
						nodeId = 109,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 9,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 74,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 76,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 79,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 81,
						portId = "In"
					}
				},
				["8"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				},
				["9"] = {
					{
						nodeId = 85,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Anxious"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 18.667,
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
				targetEulerAngleVInput = {
					0,
					356.001,
					0
				},
				targetPositionVInput = {
					-513.944,
					52.97,
					844.399
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400077,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-513.224,
					52.857,
					844.658
				},
				rotationVInput = {
					0,
					302.763,
					0
				}
			},
			fields = {
				entityId = -719621957,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.788,
				targetPositionVInput = {
					-515.099,
					53.269,
					847.524
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
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
							time = 0,
							weightedMode = 0,
							value = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							time = 1,
							weightedMode = 0,
							value = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400077,
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
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					280,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
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
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400077,
				processingTime = 18.533,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
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
					328.695,
					0
				},
				targetPositionVInput = {
					-513.352,
					53.055,
					844.763
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400077,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Think_Start",
					"",
					"Emotion_Think_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304210
			},
			fields = {
				npcStaticId = -1,
				npcId = 400063,
				matchAudioDuration = true,
				duration = 4.62,
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
						nodeId = 22,
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
						nodeId = 23,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 71,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 73,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304211
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 7.5,
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
						nodeId = 24,
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
						nodeId = 25,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304212
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
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
						nodeId = 26,
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
						nodeId = 29,
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
						nodeId = 17,
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
					8,
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
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Helpless"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 4,
				processingTime = 2,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304213
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.25,
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
						nodeId = 30,
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
						nodeId = 31,
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
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304214
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.75,
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
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304215
			},
			fields = {
				npcStaticId = -1,
				npcId = 4,
				matchAudioDuration = true,
				duration = 3.62,
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
						nodeId = 33,
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
						nodeId = 37,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				positionVInput = {
					-515.243,
					54.743,
					847.318
				},
				rotationVInput = {
					5.789,
					351.178,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 16,
				cameraId = 85439081,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				blendTimeVInput = 5,
				positionVInput = {
					-515.269,
					54.606,
					847.633
				},
				rotationVInput = {
					359.607,
					351.178,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 16,
				cameraId = 89412296,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304216
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4.62,
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
						nodeId = 38,
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
						nodeId = 40,
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
						nodeId = 15,
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
					328.695,
					0
				},
				targetPositionVInput = {
					-512.36,
					53.228,
					844.732
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
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
						nodeId = 41,
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
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
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
						nodeId = 14,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 62,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 66,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 0.791,
				targetPositionVInput = {
					-514.343,
					53.32,
					847.862
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
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
							time = 0,
							weightedMode = 0,
							value = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							time = 1,
							weightedMode = 0,
							value = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1
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
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-514.038,
					54.424,
					846.835
				},
				rotationVInput = {
					3.453,
					326.283,
					359.392
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 130,
				fStop = 12,
				cameraId = 90758841,
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
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 1,
				targetEulerAngleVInput = {
					0,
					147,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			fields = {
				reset = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
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
				portCount = 3
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
						nodeId = 60,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304217
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 10.75,
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 11,
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
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 4,
				processingTime = 3.017,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
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
						nodeId = 52,
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
						nodeId = 53,
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
						nodeId = 54,
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
						nodeId = 55,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 58,
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
						nodeId = 56,
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
						nodeId = 57,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 1,
						portId = "End"
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
						nodeId = 59,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 21,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 2.417,
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
				blendTimeVInput = 4,
				positionVInput = {
					-514.152,
					54.424,
					846.878
				},
				rotationVInput = {
					3.464,
					327.327,
					359.455
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 130,
				fStop = 12,
				cameraId = 90838571,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-518.408,
					55.603,
					844.836
				},
				rotationVInput = {
					15.836,
					40.975,
					2.873
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 85594241,
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
						nodeId = 65,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 5,
				positionVInput = {
					-518.227,
					55.386,
					844.729
				},
				rotationVInput = {
					15.981,
					37.345,
					1.877
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 90758838,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400063,
				processingTime = 8.767,
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
						nodeId = 68,
						portId = "In"
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
			kind = 3,
			inputs = {
				fovVInput = 60,
				positionVInput = {
					-514.911,
					54.594,
					841.116
				},
				rotationVInput = {
					13.29,
					348.131,
					359.026
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 100,
				fStop = 16,
				cameraId = 81560178,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320
			},
			flowIn = {
				In = 0
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
				fovVInput = 50,
				blendTimeVInput = 20,
				positionVInput = {
					-514.989,
					53.735,
					842.758
				},
				rotationVInput = {
					344.719,
					355.49,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 300,
				fStop = 10,
				cameraId = 81560185,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 320
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-513.86,
					54.683,
					846.072
				},
				rotationVInput = {
					16.526,
					163.424,
					354.358
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 16,
				cameraId = 85415167,
				visualizeDOF = false,
				squeezeFactor = 1.078,
				sensorWidth = 230
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
				blendTimeVInput = 10,
				fovVInput = 40,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-514.347,
					54.349,
					845.837
				},
				rotationVInput = {
					5.774,
					150.256,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 102,
				fStop = 16,
				cameraId = 81795731,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Righthand"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 114,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 4,
				processingTime = 2.5,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 50,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-511.881,
					55.395,
					839.965
				},
				rotationVInput = {
					4.296,
					332.723,
					359.052
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 925,
				fStop = 16,
				cameraId = 81503104,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 75,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 3,
				fovVInput = 50,
				blendFuncVInput = "EaseIn",
				positionVInput = {
					-511.665,
					55.358,
					840.081
				},
				rotationVInput = {
					4.258,
					330.612,
					358.895
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 705,
				fStop = 16,
				cameraId = 81499873,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400554,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-511.81,
					52.955,
					843.539
				},
				rotationVInput = {
					0,
					322.273,
					0
				}
			},
			fields = {
				entityId = -492761629,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 78,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 76,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400554,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 76,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
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
			kind = 16,
			inputs = {
				slotParamVInput = 400557,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.23,
					52.815,
					843.112
				},
				rotationVInput = {
					0,
					23.624,
					0
				}
			},
			fields = {
				entityId = -1104310218,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 80,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 79,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400557,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Story_Akimbo01_Start",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400550,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-516.162,
					52.848,
					843.95
				},
				rotationVInput = {
					0,
					19.175,
					0
				}
			},
			fields = {
				entityId = -954269658,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 82,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 81,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 401069,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400558,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-519.401,
					52.848,
					844.421
				},
				rotationVInput = {
					0,
					36.123,
					0
				}
			},
			fields = {
				entityId = -890413900,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				playableStateVInput = "Emotion_AngrySigh",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 83,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 401070,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_AngrySigh",
					"Emotion_AngrySigh",
					"Emotion_AngrySigh"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400557,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-513.323,
					52.848,
					843.635
				},
				rotationVInput = {
					0,
					339.343,
					0
				}
			},
			fields = {
				entityId = -331824419,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 88,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_FoldArms_Loop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 85,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400147,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Story_FoldArms_Loop",
					"Story_FoldArms_Loop",
					"Story_FoldArms_Loop"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 85,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 115,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 86,
						portId = "In"
					}
				}
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
						nodeId = 87,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400556,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-512.88,
					52.848,
					843.912
				},
				rotationVInput = {
					0,
					323.167,
					0
				}
			},
			fields = {
				entityId = -340610525,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 90,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Pray_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 89,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400556,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Daily_Pray_Start",
					"Daily_Pray_Loop",
					"Daily_Pray_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-514.446,
					52.848,
					842.95
				},
				rotationVInput = {
					0,
					359.41,
					0
				}
			},
			fields = {
				entityId = -1437125028,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 94,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Thankful_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 91,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400576,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Story_Thankful_Start",
					"Story_Thankful_Loop",
					"Story_Thankful_End"
				}
			},
			flowIn = {
				In = 0
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
					nodeId = 115,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 92,
						portId = "In"
					}
				}
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
						nodeId = 93,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.278,
					52.848,
					842.489
				},
				rotationVInput = {
					0,
					1.078,
					0
				}
			},
			fields = {
				entityId = -1496783819,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 96,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Helpless",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 95,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400295,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Helpless",
					"Emotion_Helpless",
					"Emotion_Helpless"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400555,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-519.495,
					52.848,
					844.959
				},
				rotationVInput = {
					0,
					24.763,
					0
				}
			},
			fields = {
				entityId = -1204928747,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 98,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Pray_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 97,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400297,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Daily_Pray_Start",
					"Daily_Pray_Loop",
					"Daily_Pray_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400556,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-515.516,
					52.848,
					842.793
				},
				rotationVInput = {
					0,
					357.51,
					0
				}
			},
			fields = {
				entityId = -1705345280,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 100,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Anger_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 99,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400556,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Anger_Start",
					"Emotion_Anger_Loop",
					"Emotion_Anger_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400554,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-518.049,
					52.848,
					843.642
				},
				rotationVInput = {
					0,
					20.574,
					0
				}
			},
			fields = {
				entityId = -1801443834,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 102,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 101,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400554,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Confused_Start",
					"Emotion_Confused_Loop",
					"Emotion_Confused_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400555,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-515.449,
					52.848,
					843.47
				},
				rotationVInput = {
					0,
					4.736,
					0
				}
			},
			fields = {
				entityId = -1529848584,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 103,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400147,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Talk",
					"Talk",
					"Talk"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400558,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-514.531,
					52.848,
					843.63
				},
				rotationVInput = {
					0,
					349.287,
					0
				}
			},
			fields = {
				entityId = -616296598,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 106,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Discuss_Start_02",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 105,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400147,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Story_Discuss_Start_02",
					"Story_Discuss_Loop_02",
					"Story_Discuss_End_02"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400551,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-517.435,
					52.848,
					844.263
				},
				rotationVInput = {
					0,
					20.521,
					0
				}
			},
			fields = {
				entityId = -882173410,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 108,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Pain_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 107,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400147,
				processingTime = 0,
				playAniType = 1,
				entityType = 2,
				isLooping = false,
				aniStateList = {
					"Emotion_Pain_Start",
					"Emotion_Pain_Loop",
					"Emotion_Pain_End"
				}
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
						nodeId = 110,
						portId = "In"
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
		[114] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[115] = {
			kind = 17,
			inputs = {
				staticIdVInput = 79412478
			},
			fields = {
				entityType = 2
			}
		}
	}
}
