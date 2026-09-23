-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_76883606.lua

return {
	schema = 1,
	startNodeId = 3,
	dialogueId = 76883606,
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
		[3] = {
			kind = 8,
			flowOut = {
				Start = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		[4] = {
			kind = 11,
			fields = {
				onSkipStartConnected = true,
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
					hideUIWhiteList = {
						[306] = true
					},
					toplogoComList = {
						photo = true,
						quest = true,
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						teamSpeech = true,
						vlog = true,
						actionState = true,
						battleRoom = true
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
						nodeId = 127
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
		[5] = {
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
						nodeId = 7
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 115
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 107
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 114
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 118
					}
				}
			}
		},
		[6] = {
			kind = 19,
			inputs = {
				staticIdVInput = 77239040,
				speedVInput = 0.9,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					276.081,
					0
				},
				targetPositionVInput = {
					47.943,
					58.393,
					1066.669
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
		[7] = {
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
						nodeId = 8
					}
				}
			}
		},
		[8] = {
			kind = 15,
			inputs = {
				staticIdVInput = 76707208,
				lookAtEntityStaticIdVInput = 2
			},
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
		[9] = {
			kind = 26,
			inputs = {
				staticIdVInput = 76707208,
				durationVInput = 0.5,
				targetEulerAngleVInput = {
					0,
					150,
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
						nodeId = 10
					}
				}
			}
		},
		[10] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707502
			},
			fields = {
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Emotion_Nod",
				skipTime = 0,
				npcStaticId = -1,
				npcId = 401052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				animCfg = {
					[1] = "Emotion_Nod",
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
		[11] = {
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
						nodeId = 12
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 13
					}
				}
			}
		},
		[12] = {
			kind = 28,
			inputs = {
				staticIdVInput = 76707208
			},
			flowIn = {
				In = 0
			}
		},
		[13] = {
			kind = 12,
			inputs = {
				resumeNpcVInput = false
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
		[14] = {
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
						nodeId = 15
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 17
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 104
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 27
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 106
					}
				}
			}
		},
		[15] = {
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
						nodeId = 16
					}
				}
			}
		},
		[16] = {
			kind = 27,
			fields = {
				uid = 306,
				param = {
					style = 0,
					name = "CHARACTER_APPEARANCE_NAME_Levi",
					level = "CHARACTER_APPEARANCE_TITLE_Levi",
					title = "CHARACTER_APPEARANCE_DESC_Levi",
					pos = {
						-1200,
						100,
						0
					}
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			}
		},
		[17] = {
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
						nodeId = 18
					}
				}
			}
		},
		[18] = {
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
						nodeId = 19
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
						nodeId = 22
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 26
					}
				}
			}
		},
		[19] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				blendFuncVInput = "EaseOut",
				positionVInput = {
					45.519,
					59.19,
					1065.252
				},
				rotationVInput = {
					344.467,
					14.426,
					0
				}
			},
			fields = {
				fStop = 10,
				cameraId = 91346023,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 95,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 276
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 20
					}
				}
			}
		},
		[20] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				blendTimeVInput = 6,
				positionVInput = {
					46.026,
					59.174,
					1064.994
				},
				rotationVInput = {
					346.014,
					1.019,
					0
				}
			},
			fields = {
				fStop = 10,
				cameraId = 91346024,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 95,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 276
			},
			flowIn = {
				In = 0
			}
		},
		[21] = {
			kind = 15,
			inputs = {
				staticIdVInput = 76707208,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		[22] = {
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "Position",
					nodeId = 231
				},
				rotationVInput = {
					portId = "EulerAngles",
					nodeId = 231
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1883551374
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 23
					}
				}
			}
		},
		[23] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					9.345,
					0
				},
				targetPositionVInput = {
					45.983,
					58.39,
					1065.522
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 22
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
		[24] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					38.766,
					0
				},
				targetPositionVInput = {
					44.765,
					58.39,
					1065.612
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 22
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
		[25] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					9.345,
					0
				},
				targetPositionVInput = {
					45.936,
					58.39,
					1065.522
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 22
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
		[26] = {
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					344.709,
					0
				},
				targetPositionVInput = {
					46.899,
					58.389,
					1065.7
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
		[27] = {
			kind = 19,
			inputs = {
				staticIdVInput = 76707208,
				targetEulerAngleVInput = {
					0,
					145.744,
					0
				},
				targetPositionVInput = {
					45.849,
					58.399,
					1067.511
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
						portId = "In",
						nodeId = 28
					}
				}
			}
		},
		[28] = {
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
						nodeId = 29
					}
				}
			}
		},
		[29] = {
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
						portId = "closeUIFInput",
						nodeId = 16
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		[30] = {
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
						nodeId = 31
					}
				}
			}
		},
		[31] = {
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
						nodeId = 103
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 32
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 100
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 102
					}
				}
			}
		},
		[32] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707503
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Story_Greet",
				skipTime = 0,
				npcStaticId = 77239040,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 9.12,
				disableCamera = false,
				animCfg = {
					[1] = "Story_Greet",
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
						nodeId = 33
					}
				}
			}
		},
		[33] = {
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 76707208
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 250
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
		[34] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707504
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Talk_Lefthand",
				skipTime = 0,
				npcStaticId = 0,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5.88,
				disableCamera = false,
				animCfg = {
					[1] = "Talk_Lefthand",
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
						nodeId = 35
					}
				}
			}
		},
		[35] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707505
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Talk_Lefthand",
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 401052,
				matchAudioDuration = true,
				duration = 7.38,
				disableCamera = false,
				animCfg = {
					[1] = "Talk_Lefthand",
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
						nodeId = 36
					}
				}
			}
		},
		[36] = {
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
						portId = "In",
						nodeId = 39
					}
				}
			}
		},
		[37] = {
			kind = 3,
			inputs = {
				fovVInput = 12,
				positionVInput = {
					45.675,
					59.188,
					1064.763
				},
				rotationVInput = {
					346.392,
					4.559,
					0
				}
			},
			fields = {
				fStop = 15,
				cameraId = 91128321,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 288
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
		[38] = {
			kind = 3,
			inputs = {
				fovVInput = 12,
				blendTimeVInput = 10,
				positionVInput = {
					45.565,
					59.189,
					1064.798
				},
				rotationVInput = {
					346.22,
					6.45,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91155053,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[39] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707506,
				defaultSkipBranchVInput = 1
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 40
					}
				}
			}
		},
		[40] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707507
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 401052,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 41
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
						portId = "In",
						nodeId = 43
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 45
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 42
					}
				}
			}
		},
		[42] = {
			kind = 14,
			inputs = {
				staticIdVInput = 91114225,
				targetEulerAngleVInput = {
					0,
					234.023,
					0
				},
				targetPositionVInput = {
					50.202,
					58.407,
					1070.486
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
		[43] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				positionVInput = {
					44.261,
					60.202,
					1068.612
				},
				rotationVInput = {
					10.8,
					134.163,
					0
				}
			},
			fields = {
				fStop = 15,
				cameraId = 91155086,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 230
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
		[44] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				blendTimeVInput = 10,
				positionVInput = {
					44.372,
					60.239,
					1068.653
				},
				rotationVInput = {
					11.316,
					136.225,
					0
				}
			},
			fields = {
				fStop = 15,
				cameraId = 91155116,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 260
			},
			flowIn = {
				In = 0
			}
		},
		[45] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707508
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 401052,
				matchAudioDuration = true,
				duration = 8.25,
				disableCamera = false
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
						nodeId = 98
					}
				}
			}
		},
		[46] = {
			kind = 7,
			fields = {
				dialogueId = 3707509
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 47
					}
				}
			}
		},
		[47] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707511
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Emotion_Nod",
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				animCfg = {
					[1] = "Emotion_Nod",
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
						nodeId = 48
					}
				}
			}
		},
		[48] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707514
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false
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
				}
			}
		},
		[49] = {
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
						nodeId = 50
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 93
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 88
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 97
					}
				}
			}
		},
		[50] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707515
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 3,
				npcStaticId = 91114225,
				npcId = 400129,
				matchAudioDuration = true,
				duration = 4.12,
				disableCamera = false
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
				}
			}
		},
		[51] = {
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
						nodeId = 84
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 52
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 83
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 25
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 81
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 85
					}
				}
			}
		},
		[52] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707516
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 2,
				npcStaticId = 76707208,
				npcId = 400129,
				matchAudioDuration = true,
				duration = 5.38,
				disableCamera = false
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
		[53] = {
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
						portId = "In",
						nodeId = 54
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 69
					}
				}
			}
		},
		[54] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707517
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = 91114225,
				npcId = 400129,
				matchAudioDuration = true,
				duration = 10.88,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 55
					}
				}
			}
		},
		[55] = {
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						portId = "In",
						nodeId = 56
					}
				}
			}
		},
		[56] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707518
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Emotion_Shock",
				skipTime = 1,
				npcStaticId = 77239040,
				npcId = 401086,
				matchAudioDuration = true,
				duration = 5.75,
				disableCamera = false,
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
						nodeId = 57
					}
				}
			}
		},
		[57] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707519
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = 2,
				npcId = 0,
				matchAudioDuration = true,
				duration = 7.38,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 58
					}
				}
			}
		},
		[58] = {
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
						nodeId = 59
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 67
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 68
					}
				}
			}
		},
		[59] = {
			kind = 28,
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 251
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 60
					}
				}
			}
		},
		[60] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707520
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3.25,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		[61] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707521
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 401086,
				matchAudioDuration = true,
				duration = 8.38,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 62
					}
				}
			}
		},
		[62] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707522
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 401086,
				matchAudioDuration = true,
				duration = 2.5,
				disableCamera = false
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
				}
			}
		},
		[63] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707523
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 401052,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 64
					}
				}
			}
		},
		[64] = {
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
						nodeId = 65
					}
				},
				["1"] = {
					{
						portId = "StopDof",
						nodeId = 66
					}
				}
			}
		},
		[65] = {
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
						nodeId = 1
					}
				}
			}
		},
		[66] = {
			kind = 3,
			inputs = {
				fovVInput = 28,
				blendTimeVInput = 20,
				positionVInput = {
					46.897,
					59.356,
					1067.81
				},
				rotationVInput = {
					356.637,
					186.347,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91074881,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				StopDof = 1
			}
		},
		[67] = {
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Emotion_Amazed_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 0,
				templateId = 301,
				processingTime = 1.633,
				playAniType = 1,
				aniStateList = {
					"Emotion_Amazed_Start",
					"Emotion_Amazed_Loop",
					"Emotion_Amazed_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[68] = {
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = 91114225
			},
			flowIn = {
				In = 0
			}
		},
		[69] = {
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
						nodeId = 70
					}
				}
			}
		},
		[70] = {
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
						nodeId = 77
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 71
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 79
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 80
					}
				}
			}
		},
		[71] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 1,
				staticIdVInput = 91114225,
				playableStateVInput = "Daily_Invite_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400129,
				processingTime = 1.633,
				playAniType = 1,
				aniStateList = {
					"Daily_Invite_Start",
					"Daily_Invite_Loop",
					"Daily_Invite_End"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 72
					}
				}
			}
		},
		[72] = {
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
						nodeId = 73
					}
				}
			}
		},
		[73] = {
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
						nodeId = 76
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 74
					}
				}
			}
		},
		[74] = {
			kind = 3,
			inputs = {
				fovVInput = 15,
				positionVInput = {
					44.215,
					59.362,
					1062.721
				},
				rotationVInput = {
					357.565,
					35.845,
					0
				}
			},
			fields = {
				fStop = 12,
				cameraId = 91175211,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 375
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 75
					}
				}
			}
		},
		[75] = {
			kind = 3,
			inputs = {
				fovVInput = 15,
				blendTimeVInput = 8,
				positionVInput = {
					44.29,
					59.368,
					1062.826
				},
				rotationVInput = {
					357.565,
					35.845,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91175207,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[76] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Story_TakeItem",
				staticIdVInput = 2
			},
			fields = {
				isLooping = false,
				entityType = 0,
				templateId = 301,
				processingTime = 1.633,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		[77] = {
			kind = 15,
			inputs = {
				staticIdVInput = 76707208,
				lookAtEntityStaticIdVInput = 2
			},
			valueIn = {
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 251
				}
			},
			flowIn = {
				In = 0
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
		[78] = {
			kind = 15,
			inputs = {
				staticIdVInput = 77239040,
				lookAtEntityStaticIdVInput = 2
			},
			valueIn = {
				lookAtEntityIdVInput = {
					portId = "EntityID",
					nodeId = 251
				}
			},
			flowIn = {
				In = 0
			}
		},
		[79] = {
			kind = 26,
			inputs = {
				staticIdVInput = 2
			},
			valueIn = {
				faceTransVInput = {
					portId = "BoneTransform",
					nodeId = 244
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			}
		},
		[80] = {
			kind = 15,
			inputs = {
				staticIdVInput = 91114225,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		[81] = {
			kind = 3,
			inputs = {
				fovVInput = 15,
				positionVInput = {
					42.316,
					60.282,
					1058.205
				},
				rotationVInput = {
					5.128,
					26.115,
					0
				}
			},
			fields = {
				fStop = 6,
				cameraId = 91061440,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 150,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 980
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 82
					}
				}
			}
		},
		[82] = {
			kind = 3,
			inputs = {
				fovVInput = 15,
				blendTimeVInput = 20,
				positionVInput = {
					41.365,
					60.347,
					1059.158
				},
				rotationVInput = {
					6.331,
					34.881,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91074768,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[83] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					349.534,
					0
				},
				targetPositionVInput = {
					46.611,
					58.389,
					1065.7
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 255
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
		[84] = {
			kind = 15,
			inputs = {
				staticIdVInput = 91114225,
				lookAtEntityStaticIdVInput = 76707208
			},
			flowIn = {
				In = 0
			}
		},
		[85] = {
			kind = 15,
			inputs = {
				staticIdVInput = 76707208,
				lookAtEntityStaticIdVInput = 91114225
			},
			flowIn = {
				In = 0
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
		[86] = {
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = 91114225
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
		[87] = {
			kind = 15,
			inputs = {
				staticIdVInput = 77239040,
				lookAtEntityStaticIdVInput = 91114225
			},
			flowIn = {
				In = 0
			}
		},
		[88] = {
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
						nodeId = 89
					}
				}
			}
		},
		[89] = {
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
						nodeId = 90
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 24
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 91
					}
				}
			}
		},
		[90] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					344.709,
					0
				},
				targetPositionVInput = {
					46.105,
					58.394,
					1066.526
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 255
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
		[91] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				positionVInput = {
					51.647,
					60.057,
					1073.063
				},
				rotationVInput = {
					4.784,
					219.656,
					0
				}
			},
			fields = {
				fStop = 8,
				cameraId = 91171790,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 540
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 92
					}
				}
			}
		},
		[92] = {
			kind = 3,
			inputs = {
				fovVInput = 16,
				blendTimeVInput = 5,
				positionVInput = {
					51.473,
					60.07,
					1072.853
				},
				rotationVInput = {
					4.784,
					219.656,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91172879,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[93] = {
			kind = 4,
			fields = {
				delayTime = 0.75
			},
			flowIn = {
				In = 0
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
		[94] = {
			kind = 15,
			inputs = {
				staticIdVInput = 76707208,
				lookAtEntityStaticIdVInput = 91114225
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
		[95] = {
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = 91114225
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 96
					}
				}
			}
		},
		[96] = {
			kind = 15,
			inputs = {
				staticIdVInput = 77239040,
				lookAtEntityStaticIdVInput = 91114225
			},
			flowIn = {
				In = 0
			}
		},
		[97] = {
			kind = 19,
			inputs = {
				staticIdVInput = 91114225,
				speedVInput = 1.1,
				targetEulerAngleVInput = {
					0,
					-154,
					0
				},
				targetPositionVInput = {
					47.627,
					58.407,
					1068.038
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
		[98] = {
			kind = 7,
			fields = {
				dialogueId = 3707510
			},
			flowIn = {
				In = 0
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
		[99] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 3707512
			},
			fields = {
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				anim = "Emotion_Nod",
				skipTime = 0,
				npcStaticId = 76707208,
				npcId = 400162,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				animCfg = {
					[1] = "Emotion_Nod",
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
						nodeId = 48
					}
				}
			}
		},
		[100] = {
			kind = 3,
			inputs = {
				fovVInput = 22,
				positionVInput = {
					46.004,
					59.735,
					1059.855
				},
				rotationVInput = {
					2.722,
					5.625,
					0
				}
			},
			fields = {
				fStop = 16,
				cameraId = 81176811,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 380
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 101
					}
				}
			}
		},
		[101] = {
			kind = 3,
			inputs = {
				fovVInput = 22,
				blendTimeVInput = 20,
				positionVInput = {
					45.692,
					59.901,
					1059.903
				},
				rotationVInput = {
					4.269,
					8.375,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 81177055,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[102] = {
			kind = 14,
			inputs = {
				staticIdVInput = 76707208,
				targetEulerAngleVInput = {
					0,
					137.35,
					0
				},
				targetPositionVInput = {
					45.782,
					58.399,
					1067.45
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
		[103] = {
			kind = 14,
			inputs = {
				staticIdVInput = 77239040,
				targetEulerAngleVInput = {
					0,
					278.846,
					0
				},
				targetPositionVInput = {
					47.768,
					58.358,
					1066.35
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
		[104] = {
			kind = 26,
			inputs = {
				staticIdVInput = 76707249,
				targetEulerAngleVInput = {
					0,
					170,
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
						nodeId = 105
					}
				}
			}
		},
		[105] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Observe",
				staticIdVInput = 76707249
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 401055,
				processingTime = 6.8,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		[106] = {
			kind = 14,
			inputs = {
				staticIdVInput = 77239040,
				targetEulerAngleVInput = {
					0,
					276.081,
					0
				},
				targetPositionVInput = {
					47.943,
					58.393,
					1066.669
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
		[107] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Goodbye",
				staticIdVInput = 76707208
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400162,
				processingTime = 2.233,
				playAniType = 1
			},
			flowIn = {
				In = 0
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
		[108] = {
			kind = 4,
			fields = {
				delayTime = 1.5
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
		[109] = {
			kind = 19,
			inputs = {
				staticIdVInput = 76877288,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					280,
					0
				},
				targetPositionVInput = {
					35.65,
					58.35,
					1074.681
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
				Out = {
					{
						portId = "In",
						nodeId = 110
					}
				}
			}
		},
		[110] = {
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
						nodeId = 111
					}
				}
			}
		},
		[111] = {
			kind = 19,
			inputs = {
				staticIdVInput = 76877939,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					270,
					0
				},
				targetPositionVInput = {
					35.65,
					58.35,
					1076.002
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
						portId = "In",
						nodeId = 112
					}
				}
			}
		},
		[112] = {
			kind = 20,
			inputs = {
				staticIdVInput = 76877939
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 113
					}
				}
			}
		},
		[113] = {
			kind = 20,
			inputs = {
				staticIdVInput = 76877288
			},
			flowIn = {
				In = 0
			}
		},
		[114] = {
			kind = 19,
			inputs = {
				autoPathfindingVInput = true,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					344.709,
					0
				},
				targetPositionVInput = {
					46.899,
					58.389,
					1065.7
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 245
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
							value = 0,
							outWeight = 0,
							weightedMode = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							outWeight = 0,
							weightedMode = 0,
							time = 1,
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
		[115] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 2.5,
				blendExponentVInput = 3,
				fovVInput = 37,
				blendFuncVInput = "Cubic",
				positionVInput = {
					48.381,
					59.734,
					1059.894
				},
				rotationVInput = {
					4.372,
					340.976,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91168373,
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
						portId = "In",
						nodeId = 116
					}
				}
			}
		},
		[116] = {
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 117
					}
				}
			}
		},
		[117] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 5,
				blendExponentVInput = 3,
				fovVInput = 37,
				blendFuncVInput = "Cubic",
				positionVInput = {
					46.124,
					59.818,
					1063.189
				},
				rotationVInput = {
					6.091,
					1.431,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91175323,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[118] = {
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
						nodeId = 119
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 120
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 121
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 122
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 123
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 124
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 125
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 126
					}
				}
			}
		},
		[119] = {
			kind = 63,
			inputs = {
				positionVInput = {
					47.384,
					61.131,
					1067.815
				},
				rotationVInput = {
					34.629,
					306.703,
					354.546
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 100,
				spotLightInnerAngle = 80,
				radius = 8,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 120000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 0.85,
					r = 1,
					g = 0.9494264,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[120] = {
			kind = 63,
			inputs = {
				positionVInput = {
					46.571,
					60.063,
					1067.44
				},
				rotationVInput = {
					1.328,
					263.393,
					359.811
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 70,
				spotLightInnerAngle = 50,
				radius = 6,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 20000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 0.88,
					r = 1,
					g = 0.9495685,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[121] = {
			kind = 63,
			inputs = {
				positionVInput = {
					47.487,
					60.188,
					1066.593
				},
				rotationVInput = {
					31.134,
					207.472,
					357.418
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 70,
				spotLightInnerAngle = 50,
				radius = 10,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 10000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 0.85,
					r = 1,
					g = 0.9327034,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[122] = {
			kind = 63,
			inputs = {
				positionVInput = {
					46.865,
					60.329,
					1068.179
				},
				rotationVInput = {
					29.424,
					117.467,
					7.39
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 110,
				spotLightInnerAngle = 80,
				radius = 10,
				punctualLightUnit = 2,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 2,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 5000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 0.88,
					r = 1,
					g = 0.9622083,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[123] = {
			kind = 63,
			inputs = {
				positionVInput = {
					47.055,
					59.939,
					1067.448
				},
				rotationVInput = {
					28.235,
					135.317,
					358.053
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 70,
				spotLightInnerAngle = 50,
				radius = 2.65,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 20000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 0,
				color = {
					b = 0.88,
					r = 1,
					g = 0.9805413,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[124] = {
			kind = 63,
			inputs = {
				positionVInput = {
					50.321,
					59.445,
					1064.535
				},
				rotationVInput = {
					6.893,
					299.938,
					3.025
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 70,
				spotLightInnerAngle = 60,
				radius = 10,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 1500,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 1,
					r = 0.6,
					g = 0.7855532,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[125] = {
			kind = 63,
			inputs = {
				positionVInput = {
					43.327,
					59.859,
					1070.318
				},
				rotationVInput = {
					2.421,
					119.622,
					0.095
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 70,
				spotLightInnerAngle = 70,
				radius = 10,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 150000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				color = {
					b = 1,
					r = 0.6,
					g = 0.7978739,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[126] = {
			kind = 63,
			inputs = {
				positionVInput = {
					44.466,
					60.666,
					1066.167
				},
				rotationVInput = {
					24.701,
					46.768,
					349.713
				}
			},
			fields = {
				areaLightUnit = 1,
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				usePhysicalLightUnit = false,
				twoSide = false,
				temperature = 1500,
				spotLightOuterAngle = 95.9,
				spotLightInnerAngle = 69.3,
				radius = 4.88,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 10614,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 0,
				color = {
					b = 1,
					r = 0.6745283,
					g = 0.9205098,
					a = 1
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		[127] = {
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
						nodeId = 128
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 129
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 130
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 131
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 133
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 134
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 135
					}
				}
			}
		},
		[128] = {
			kind = 20,
			inputs = {
				staticIdVInput = 76877939
			},
			flowIn = {
				In = 0
			}
		},
		[129] = {
			kind = 20,
			inputs = {
				staticIdVInput = 76877288
			},
			flowIn = {
				In = 0
			}
		},
		[130] = {
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					23.484,
					0
				},
				targetPositionVInput = {
					46.611,
					58.39,
					1065.7
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
		[131] = {
			kind = 14,
			inputs = {
				staticIdVInput = 76707208,
				targetEulerAngleVInput = {
					0,
					137.35,
					0
				},
				targetPositionVInput = {
					45.782,
					58.398,
					1067.45
				}
			},
			fields = {
				reset = false,
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = 0
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
		[132] = {
			kind = 14,
			inputs = {
				staticIdVInput = 76707249,
				targetEulerAngleVInput = {
					0,
					170,
					0
				},
				targetPositionVInput = {
					46.19,
					58.401,
					1068.68
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
		[133] = {
			kind = 14,
			inputs = {
				staticIdVInput = 77239040,
				targetEulerAngleVInput = {
					0,
					276.081,
					0
				},
				targetPositionVInput = {
					47.898,
					58.392,
					1066.701
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
		[134] = {
			kind = 14,
			inputs = {
				staticIdVInput = 91114225,
				targetEulerAngleVInput = {
					0,
					199.717,
					0
				},
				targetPositionVInput = {
					47.627,
					58.395,
					1068.038
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
		[135] = {
			kind = 22,
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						portId = "In",
						nodeId = 136
					}
				}
			}
		},
		[136] = {
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
						nodeId = 137
					}
				}
			}
		},
		[137] = {
			kind = 10,
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
		[231] = {
			kind = 17,
			fields = {
				entityType = 1
			}
		},
		[244] = {
			kind = 17,
			inputs = {
				staticIdVInput = 91114225
			},
			fields = {
				entityType = 2
			}
		},
		[245] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[250] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[251] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[255] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		}
	},
	blackboard = {}
}
