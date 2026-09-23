-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90622168.lua

return {
	dialogueId = 90622168,
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
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					exitCatchMode = true,
					resetAllActions = true,
					blockEvent = true,
					modeType = 2,
					toplogoComList = {
						alert = true,
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
						bubble = true
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
				["1"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 196
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					45.903,
					0
				},
				targetPositionVInput = {
					-1382.033,
					80.419,
					1019.177
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
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
				delayTime = 4
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-1385.396,
					82.806,
					1018.138
				},
				rotationVInput = {
					19.862,
					73.209,
					-0.001
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 336,
				fStop = 10,
				cameraId = 90737619
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 25,
				blendTimeVInput = 10,
				positionVInput = {
					-1384.607,
					82.487,
					1018.396
				},
				rotationVInput = {
					17.111,
					71.147,
					-0.001
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 336,
				fStop = 10,
				cameraId = 90829718
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_RACE",
					1005100,
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
						portId = "In",
						nodeId = 11
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 113
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_RACE",
					1005200,
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
						portId = "In",
						nodeId = 12
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 162
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_RACE",
					1005300,
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
						portId = "In",
						nodeId = 112
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 13
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
						nodeId = 63
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 14
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 17
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 110
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-1384.196,
					83,
					1019.845
				},
				rotationVInput = {
					359.282,
					283.078,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 180,
				fStop = 17,
				cameraId = 91125009
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
				fovVInput = 30,
				blendTimeVInput = 2,
				positionVInput = {
					-1384.196,
					82,
					1019.845
				},
				rotationVInput = {
					359.282,
					283.078,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 180,
				fStop = 17,
				cameraId = 91125010
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
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					flags = 0,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					decayTime = 2,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
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
				delayTime = 3.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505094,
				enableFadeOutVInput = true,
				enableFadeInVInput = true
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 19
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
						portId = "In",
						nodeId = 20
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 62
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505024
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 13,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				portCount = 4
			},
			flowIn = {
				In = 0
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
						nodeId = 60
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505025
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 3
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
						nodeId = 24
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 58
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 59
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505026
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 0,
				disableCamera = false,
				chatType = 3
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
						nodeId = 26
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 56
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505027
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 0,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 2,
				dialogueIdVInput = 6505028
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3
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
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6505029
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 29
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
						nodeId = 30
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 40
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505031
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 5.12,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 31
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
						nodeId = 32
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
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505032
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 33
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
						nodeId = 34
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 36
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505036
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 8.38,
				disableCamera = false,
				chatType = 3
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
						portId = "End",
						nodeId = 1
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Like",
				loopDurationVInput = 4,
				animationLayerVInput = 4,
				staticIdVInput = 86076120
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 3.333
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Stop",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 5,
				playableStateVInput = "TalkUpper_Crossingarms_Start",
				staticIdVInput = 86076120
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 1,
				aniStateList = {
					"TalkUpper_Crossingarms_Start",
					"TalkUpper_Crossingarms_Loop",
					"TalkUpper_Crossingarms_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Stop",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				loopDurationVInput = 4,
				playableStateVInput = "Daily_Invite_Start",
				staticIdVInput = 86076120
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 1,
				aniStateList = {
					"Daily_Invite_Start",
					"Daily_Invite_Loop",
					"Daily_Invite_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Linear",
				fovVInput = 25,
				positionVInput = {
					-1383.013,
					81.743,
					1018.828
				},
				rotationVInput = {
					5.939,
					54.716,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 135,
				fStop = 20,
				cameraId = 90829871
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Shrug_Start",
				staticIdVInput = 2,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 1,
				aniStateList = {
					"Talk_Shrug_Start",
					"Talk_Shrug_Loop",
					"Talk_Shrug_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6505030
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				dialogueIdVInput = 6505033
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 43
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
						nodeId = 44
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 53
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 52
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505034
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 45
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
						nodeId = 46
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 47
					}
				},
				["2"] = {
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
				dialogueIdVInput = 6505035
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 8.25,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 86076120,
				speedVInput = 0.75,
				moveTypeVInput = 2,
				targetEulerAngleVInput = {
					0,
					188.967,
					0
				},
				targetPositionVInput = {
					-1381.765,
					80.419,
					1019.747
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
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
						portId = "In",
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				staticIdVInput = 86076120,
				playableStateVInput = "TalkUpper_Shrug",
				loopDurationVInput = 4,
				animationLayerVInput = 4
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 1,
				aniStateList = {
					"TalkUpper_Shrug",
					"TalkUpper_Shrug",
					"TalkUpper_Shrug"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Linear",
				fovVInput = 25,
				positionVInput = {
					-1385.334,
					81.718,
					1019.372
				},
				rotationVInput = {
					5.079,
					88.578,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 20,
				cameraId = 90829891
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 25,
				blendFuncVInput = "Linear",
				blendTimeVInput = 0.5,
				positionVInput = {
					-1385.334,
					81.718,
					1019.372
				},
				rotationVInput = {
					5.079,
					88.578,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 20,
				cameraId = 90830142
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
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendFuncVInput = "Linear",
				blendTimeVInput = 0.5,
				positionVInput = {
					-1384.752,
					81.666,
					1019.386
				},
				rotationVInput = {
					3.017,
					89.266,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 20,
				cameraId = 90830144
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
					-1381.682,
					81.736,
					1020.892
				},
				rotationVInput = {
					5.251,
					186.898,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 190,
				fStop = 25,
				cameraId = 90829839
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 54
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_ShakeHead",
				staticIdVInput = 2
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 55
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 86076120,
				staticIdVInput = 2
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
					-1385.229,
					81.962,
					1016.887
				},
				rotationVInput = {
					3.704,
					54.373,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 350,
				fStop = 20,
				cameraId = 90829674
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 57
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 18,
				positionVInput = {
					-1386.669,
					82.104,
					1016.732
				},
				rotationVInput = {
					4.564,
					66.405,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 350,
				fStop = 20,
				cameraId = 90829821
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Confused_Start",
				staticIdVInput = 2,
				playStartLoopEndVInput = true
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 401,
				processingTime = 1,
				aniStateList = {
					"TalkUpper_Confused_Start",
					"TalkUpper_Confused_Loop",
					"TalkUpper_Confused_End"
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
					-1382.168,
					81.779,
					1020.572
				},
				rotationVInput = {
					7.314,
					172.803,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 135,
				fStop = 25,
				cameraId = 90829666
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendFuncVInput = "Linear",
				blendTimeVInput = 0.3,
				positionVInput = {
					-1382.811,
					81.931,
					1019.485
				},
				rotationVInput = {
					13.845,
					70.014,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 135,
				fStop = 20,
				cameraId = 90829622
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = 86076120
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 2.7
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Like",
				staticIdVInput = 86076120,
				animationLayerVInput = 4
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 990010,
				processingTime = 0.833
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005305,
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
						portId = "In",
						nodeId = 64
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 103
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005304,
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
						portId = "In",
						nodeId = 72
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 65
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990074,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -1116927411,
				ignoreGravity = false
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
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 65
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 67
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 65
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 68
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
						portId = "Play",
						nodeId = 69
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 65
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 70
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 65
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
						portId = "In",
						nodeId = 66
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005303,
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
						portId = "In",
						nodeId = 80
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 73
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990073,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -575638234,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 79
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 73
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 75
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 73
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 76
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
						portId = "Play",
						nodeId = 77
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 73
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 78
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 73
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
						portId = "In",
						nodeId = 74
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005302,
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
						portId = "In",
						nodeId = 88
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 81
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990072,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -418749737,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 87
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 81
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 83
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 81
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 84
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
						portId = "Play",
						nodeId = 85
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 81
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 86
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 81
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
						portId = "In",
						nodeId = 82
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005301,
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
						portId = "In",
						nodeId = 96
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 89
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990071,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -113045865,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 95
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 89
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 91
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 89
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 92
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
						portId = "Play",
						nodeId = 93
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 89
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 94
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 89
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
						portId = "In",
						nodeId = 90
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990066,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -1912437297,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 102
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 96
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 98
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 96
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 99
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
						portId = "Play",
						nodeId = 100
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 96
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 101
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 96
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
						portId = "In",
						nodeId = 97
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990075,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -1776676417,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 109
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack01",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 103
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005300,
				processingTime = 2.833
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 105
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10053_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 103
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 106
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
						portId = "Play",
						nodeId = 107
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 103
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 108
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 103
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
						portId = "In",
						nodeId = 104
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 111
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_10051_Fireball_Hit.prefab",
				postionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_RACE",
					1005500,
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
						portId = "In",
						nodeId = 113
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 147
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
						nodeId = 119
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 114
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 117
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 145
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				positionVInput = {
					-1384.196,
					82,
					1019.845
				},
				rotationVInput = {
					359.282,
					283.078,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 180,
				fStop = 17,
				cameraId = 90829468
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 115
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				blendTimeVInput = 2,
				positionVInput = {
					-1384.196,
					81.3,
					1019.845
				},
				rotationVInput = {
					359.282,
					283.078,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 180,
				fStop = 17,
				cameraId = 90829582
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 116
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					flags = 0,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					decayTime = 2,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
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
				delayTime = 3.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 118
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505023,
				enableFadeOutVInput = true,
				enableFadeInVInput = true
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005101,
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
						portId = "In",
						nodeId = 128
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 120
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990067,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -197218927,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 127
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Skill_Fireball",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 120
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005100,
				processingTime = 1.25
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 122
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10051_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 120
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 123
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
						portId = "Play",
						nodeId = 124
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 120
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 125
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
						portId = "In",
						nodeId = 126
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 120
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
						portId = "In",
						nodeId = 121
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005104,
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
						portId = "In",
						nodeId = 137
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 129
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990068,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -1018727779,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 136
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Skill_Fireball",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 129
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005100,
				processingTime = 1.25
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 131
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10051_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 129
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 132
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
						portId = "Play",
						nodeId = 133
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 129
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 134
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
						portId = "In",
						nodeId = 135
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 129
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
						portId = "In",
						nodeId = 130
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990029,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -2090166212,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 144
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Skill_Fireball",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 137
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005100,
				processingTime = 1.25
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 139
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10051_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 137
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 140
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
						portId = "Play",
						nodeId = 141
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 137
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 142
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
						portId = "In",
						nodeId = 143
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 137
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
						portId = "In",
						nodeId = 138
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 146
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_10051_Fireball_Hit.prefab",
				postionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
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
						nodeId = 148
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 155
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 158
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 160
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990076,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.9,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -868659061,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 154
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack04",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 148
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005500,
				processingTime = 3.067
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 150
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10055_Attack_L"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 148
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 151
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
						portId = "Play",
						nodeId = 152
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 148
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 153
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 148
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
						portId = "In",
						nodeId = 149
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-1383.083,
					82.5,
					1019.634
				},
				rotationVInput = {
					330,
					282.562,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 17,
				cameraId = 91227658
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 156
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 4,
				positionVInput = {
					-1383.083,
					82.2,
					1019.634
				},
				rotationVInput = {
					15,
					281.703,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 17,
				cameraId = 91227661
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 157
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					flags = 0,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					decayTime = 2,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
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
				delayTime = 3.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 159
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505097,
				enableFadeOutVInput = true,
				enableFadeInVInput = true
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 161
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_10055_Skill_Attack01.prefab",
				postionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
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
						nodeId = 168
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 163
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 166
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 194
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				positionVInput = {
					-1383.083,
					82.024,
					1019.634
				},
				rotationVInput = {
					344.844,
					282.562,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 17,
				cameraId = 91125023
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 164
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 25,
				blendTimeVInput = 4,
				positionVInput = {
					-1383.083,
					82.024,
					1019.634
				},
				rotationVInput = {
					25.409,
					281.703,
					0
				}
			},
			fields = {
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 108,
				fStop = 17,
				cameraId = 91125022
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 165
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					flags = 0,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					decayTime = 2,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								weightedMode = 0,
								value = 1,
								inWeight = 0,
								outTangent = 0
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
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
				delayTime = 3.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 167
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6505093,
				enableFadeOutVInput = true,
				enableFadeInVInput = true
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005201,
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
						portId = "In",
						nodeId = 177
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 169
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990069,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -982117518,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 176
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack02",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 169
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005200,
				processingTime = 1.367
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 171
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10052_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 169
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 172
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
						portId = "Play",
						nodeId = 173
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 169
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 174
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
						portId = "In",
						nodeId = 175
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 169
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
						portId = "In",
						nodeId = 170
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"HAS_PET_ID",
					1005204,
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
						portId = "In",
						nodeId = 186
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 178
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990070,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -651446136,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 185
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack02",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005200,
				processingTime = 1.05
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 180
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10052_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 178
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 181
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
						portId = "Play",
						nodeId = 182
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 178
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 183
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
						portId = "In",
						nodeId = 184
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 178
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
						portId = "In",
						nodeId = 179
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990065,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				entityId = -1659315316,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 193
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Attack02",
				staticIdVInput = 1,
				fadeDurationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 186
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 1,
				templateId = 1005200,
				processingTime = 1.05
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 188
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "VOX_Combat_Parmon_10052_Attack_H"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 186
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 189
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
						portId = "Play",
						nodeId = 190
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "parmon_10051_Skill_FireBall_Shoot"
			},
			valueIn = {
				audioTransformVInput = {
					portId = "BoneTrans",
					nodeId = 186
				}
			},
			flowIn = {
				Play = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 191
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
						portId = "In",
						nodeId = 192
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "BoneTrans",
					nodeId = 186
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
						portId = "In",
						nodeId = 187
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 195
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_10051_Fireball_Hit.prefab",
				postionVInput = {
					-1385.996,
					80.805,
					1020.282
				},
				rotationVInput = {
					0,
					102.252,
					0
				}
			},
			fields = {
				playOne = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 0.2,
				staticIdVInput = 1,
				speedVInput = 1.25,
				moveTypeVInput = 2,
				targetEulerAngleVInput = {
					0,
					58.647,
					0
				},
				targetPositionVInput = {
					-1385.632,
					80.873,
					1017.328
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
							time = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							time = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 1,
							inWeight = 0,
							outTangent = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		}
	}
}
