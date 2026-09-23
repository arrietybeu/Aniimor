-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91088552.lua

return {
	dialogueId = 91088552,
	schema = 1,
	startNodeId = 1,
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
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					blockEvent = true,
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
					hideInteractionSign = true,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					toplogoComList = {
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
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						portId = "In",
						nodeId = 3
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
						nodeId = 0
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
						nodeId = 5
					}
				},
				["1"] = {
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
				dialogueIdVInput = 9102018
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5,
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
						portId = "0",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 2,
				maxAwaitTime = -1
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 43
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1,
				enableGroupLookAt = false,
				enableDefaultLookAt = true,
				cameraPreset = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 3,
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 46
				},
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 52
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 52
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
							weightedMode = 0,
							time = 0,
							value = 0,
							inWeight = 0,
							outTangent = 1
						},
						{
							inTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-47.769,
					39.295,
					327.943
				},
				rotationVInput = {
					358.656,
					12.561,
					0
				}
			},
			fields = {
				cameraId = 91111284,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
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
			kind = 1,
			inputs = {
				lookAtIdVInput = 5200003,
				dialogueIdVInput = 9102012
			},
			fields = {
				duration = 4.75,
				npcId = 5200009,
				skipTime = 0,
				npcStaticId = -317273765,
				matchAudioDuration = true,
				anim = "Talk_Introduce",
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				animCfg = {
					[1] = "Talk_Introduce",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 14
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 12
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Parmon_10042_Skill_WaterHeal.prefab",
				postionVInput = {
					-47.325,
					38.11,
					328.8
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
			kind = 1,
			inputs = {
				lookAtIdVInput = 5200001,
				dialogueIdVInput = 9102013
			},
			fields = {
				duration = 2,
				npcId = 5200003,
				skipTime = 2,
				npcStaticId = -1579527018,
				matchAudioDuration = true,
				anim = "Skill_WaterHeal",
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				animCfg = {
					[1] = "Skill_WaterHeal",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-48.135,
					39.311,
					329.399
				},
				rotationVInput = {
					355.219,
					117.068,
					0
				}
			},
			fields = {
				cameraId = 91114151,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 5200003,
				dialogueIdVInput = 9102014
			},
			fields = {
				duration = 10.12,
				npcId = 5200009,
				skipTime = 0,
				npcStaticId = -317273765,
				matchAudioDuration = true,
				anim = "Emotion_Shock",
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				animCfg = {
					[1] = "Emotion_Shock",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
			kind = 3,
			inputs = {
				positionVInput = {
					-46.193,
					39.431,
					329.43
				},
				rotationVInput = {
					357.973,
					317.991,
					359.99
				}
			},
			fields = {
				cameraId = 91111300,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
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
						nodeId = 19
					}
				},
				["1"] = {
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
				lookAtIdVInput = 5200001,
				dialogueIdVInput = 9102015
			},
			fields = {
				skipTime = 0,
				npcStaticId = -2005228816,
				npcId = 5200002,
				matchAudioDuration = true,
				duration = 8.25,
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
						portId = "In",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-45.614,
					39.86,
					331.319
				},
				rotationVInput = {
					13.018,
					214.401,
					-0.002
				}
			},
			fields = {
				cameraId = 91358456,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				portCount = 2
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
						nodeId = 36
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 5200003,
				dialogueIdVInput = 9102016
			},
			fields = {
				skipTime = 0,
				npcStaticId = 0,
				npcId = 0,
				matchAudioDuration = true,
				duration = 8.38,
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
						portId = "In",
						nodeId = 23
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-45.614,
					39.86,
					331.319
				},
				rotationVInput = {
					13.018,
					214.401,
					-0.002
				}
			},
			fields = {
				cameraId = 91358454,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9102040
			},
			fields = {
				duration = 4.75,
				npcId = 5200002,
				skipTime = 0,
				npcStaticId = -2005228816,
				matchAudioDuration = true,
				anim = "Daily_Thanks",
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				animCfg = {
					[1] = "Daily_Thanks",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
			kind = 3,
			inputs = {
				positionVInput = {
					-45.614,
					39.86,
					331.319
				},
				rotationVInput = {
					13.018,
					214.401,
					-0.002
				}
			},
			fields = {
				cameraId = 91112393,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
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
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -317273765
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -317273765,
				lookAtEntityStaticIdVInput = 2
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
						nodeId = 29
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9102017
			},
			fields = {
				duration = 9.12,
				npcId = 5200009,
				skipTime = 2,
				npcStaticId = -317273765,
				matchAudioDuration = true,
				anim = "TalkUpper_Firm",
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				animCfg = {
					[1] = "TalkUpper_Firm",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 31
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 33
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9102051
			},
			fields = {
				skipTime = 4,
				npcStaticId = -1,
				npcId = -1,
				matchAudioDuration = true,
				duration = 4,
				disableCamera = false,
				chatType = 5,
				blackScreenPlayType = 1,
				blackScreenIntervalTime = 2,
				portCount = 1
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
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 66,
			inputs = {
				resetOnFinishVInput = true
			},
			fields = {
				staticIdList = {
					-317273765,
					-1579527018,
					-2005228816
				}
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
			kind = 20,
			inputs = {
				staticIdVInput = -317273765
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				staticIdVInput = -317273765,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Emotion_Firm_Start"
			},
			fields = {
				templateId = 5200009,
				processingTime = 5.5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Firm_Start",
					"Emotion_Firm_Loop",
					"Emotion_Firm_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Talk_Cheeksupport"
			},
			fields = {
				templateId = 403,
				processingTime = 5.5,
				playAniType = 1,
				isLooping = false,
				entityType = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				staticIdVInput = -2005228816,
				defaultTransStateVInput = "Idle",
				playableStateVInput = "Emotion_Laugh_Start"
			},
			fields = {
				templateId = 5200002,
				processingTime = 5.5,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Emotion_Laugh_Start",
					"Emotion_Laugh_Loop",
					"Emotion_Laugh_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 66,
			fields = {
				staticIdList = {
					[1] = 91086387,
					[2] = 91086385
				}
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
						nodeId = 45
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 40
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200002,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 50
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 50
				}
			},
			fields = {
				entityId = -2005228816,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "1",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				portCount = 3,
				maxAwaitTime = -1
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0,
				["2"] = 0
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
			kind = 3,
			inputs = {
				positionVInput = {
					-43.959,
					39.709,
					331.352
				},
				rotationVInput = {
					3.817,
					234.796,
					359.991
				}
			},
			fields = {
				cameraId = 91093432,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "1",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 46
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 40
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 44
				},
				["4EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 53
				}
			},
			fields = {
				portCount = 4
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200003,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 51
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 51
				}
			},
			fields = {
				entityId = -1579527018,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "2",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 49
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 49
				}
			},
			fields = {
				setPosition = true,
				reset = false,
				setRotation = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 46
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 5200001,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-45.994,
					38.366,
					320.813
				},
				rotationVInput = {
					0,
					340.414,
					0
				}
			},
			fields = {
				entityId = -317273765,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "0",
						nodeId = 41
					}
				}
			}
		},
		[49] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91303501,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91303497
			}
		},
		[50] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91303499,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91303497
			}
		},
		[51] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91303498,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91303497
			}
		},
		[52] = {
			kind = 43,
			inputs = {
				slotIDVInput = 91303500,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91303497
			}
		},
		[53] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		}
	}
}
