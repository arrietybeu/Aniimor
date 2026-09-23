-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91046738.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91046738,
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
			kind = 11,
			fields = {
				modeInfo = {
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
					showHud = true,
					toplogoComList = {
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
						teamSpeech = true,
						quest = true
					}
				}
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
			kind = 22,
			inputs = {
				blendVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						nodeId = 5,
						portId = "In"
					}
				},
				Out = {
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
				portCount = 6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["1"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 10,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 14,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400204,
				positionVInput = {
					-495.758,
					56.856,
					778.375
				},
				rotationVInput = {
					0,
					305.335,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1348332447
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Righthand",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 6,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 1.3,
				aniStateList = {
					"Talk_Righthand",
					"Talk_Righthand",
					"Talk_Righthand"
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
					nodeId = 6,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 1.3
			},
			flowIn = {
				In = 0
			}
		},
		[10] = {
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-495.707,
					56.831,
					779.112
				},
				rotationVInput = {
					0,
					230,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1051151584
			},
			flowIn = {
				In = 0
			}
		},
		[11] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Shrug"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 10,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400180,
				processingTime = 3.167
			},
			flowIn = {
				In = 0
			}
		},
		[12] = {
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400066,
				positionVInput = {
					-637.213,
					48.048,
					851.638
				},
				rotationVInput = {
					0,
					272.046,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -2089878322
			},
			flowIn = {
				In = 0
			}
		},
		[13] = {
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					99.93,
					0
				},
				targetPositionVInput = {
					-496.385,
					56.802,
					778.937
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
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
		[14] = {
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400515,
				positionVInput = {
					-499.12,
					56.88,
					776.37
				},
				rotationVInput = {
					0,
					25.305,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -206426661
			},
			flowIn = {
				In = 0
			}
		},
		[15] = {
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 14,
					portId = "EntityID"
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 3,
				nodeMode = 1,
				enableGroupLookAt = true,
				enableDefaultLookAt = false,
				cameraPreset = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FOut = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		[16] = {
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
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		[17] = {
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 6201492
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -206426661,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 8.38,
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
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		[18] = {
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 6201493
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -206426661,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 7.88,
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
						nodeId = 19,
						portId = "In"
					}
				}
			}
		},
		[19] = {
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
						nodeId = 20,
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
						nodeId = 47,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 48,
						portId = "In"
					}
				}
			}
		},
		[20] = {
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6201174
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -206426661,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 5,
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
						nodeId = 21,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		[21] = {
			kind = 7,
			fields = {
				dialogueId = 6201175
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		[22] = {
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
						nodeId = 25,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 42,
						portId = "0"
					}
				}
			}
		},
		[23] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-497.243,
					58.486,
					777.409
				},
				rotationVInput = {
					12.719,
					42.021,
					0
				}
			},
			fields = {
				cameraId = 91101694,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 20.05
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		[24] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 10,
				positionVInput = {
					-497.268,
					58.324,
					777.382
				},
				rotationVInput = {
					12.719,
					42.021,
					0
				}
			},
			fields = {
				cameraId = 91346725,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 20.05
			},
			flowIn = {
				In = 0
			}
		},
		[25] = {
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 6201177
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1051151584,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 3,
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
						nodeId = 26,
						portId = "0"
					}
				}
			}
		},
		[26] = {
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		[27] = {
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
						nodeId = 28,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		[28] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201179
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1051151584,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 6.75,
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
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		[29] = {
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
						nodeId = 30,
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
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		[30] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201494
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1348332447,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 3.75,
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
						nodeId = 31,
						portId = "In"
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
						nodeId = 32,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		[32] = {
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 6201495
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1348332447,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 2,
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
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		[33] = {
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				resumeNearbyMonsterAIVInput = false,
				endSkipVInput = true,
				enablePlayerMoveVInput = false,
				enableEventVInput = false,
				showTopLogoVInput = false
			},
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
		[34] = {
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
						nodeId = 35,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		[35] = {
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
		[36] = {
			kind = 22,
			inputs = {
				blendVInput = 0.7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		[37] = {
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		[38] = {
			kind = 15,
			inputs = {
				staticIdVInput = -1348332447,
				lookAtEntityStaticIdVInput = -1051151584
			},
			flowIn = {
				In = 0
			}
		},
		[39] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-496.362,
					58.246,
					779.42
				},
				rotationVInput = {
					8.594,
					148.42,
					0
				}
			},
			fields = {
				cameraId = 91101691,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 110,
				fStop = 22.71
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		[40] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 9,
				positionVInput = {
					-496.31,
					58.231,
					779.335
				},
				rotationVInput = {
					8.594,
					148.42,
					0
				}
			},
			fields = {
				cameraId = 91346729,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 110,
				fStop = 22.71
			},
			flowIn = {
				In = 0
			}
		},
		[41] = {
			kind = 15,
			inputs = {
				staticIdVInput = -1051151584,
				lookAtEntityStaticIdVInput = -1348332447
			},
			flowIn = {
				In = 0
			}
		},
		[42] = {
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		[43] = {
			kind = 7,
			fields = {
				dialogueId = 6201176
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		[44] = {
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
						nodeId = 45,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 42,
						portId = "1"
					}
				}
			}
		},
		[45] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201178
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1051151584,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 4.38,
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
						nodeId = 26,
						portId = "1"
					}
				}
			}
		},
		[46] = {
			kind = 15,
			inputs = {
				staticIdVInput = -1051151584,
				lookAtEntityStaticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		[47] = {
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -1051151584
			},
			flowIn = {
				In = 0
			}
		},
		[48] = {
			kind = 15,
			inputs = {
				staticIdVInput = -1348332447,
				lookAtEntityStaticIdVInput = -1051151584
			},
			flowIn = {
				In = 0
			}
		},
		[49] = {
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
						nodeId = 53,
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
						nodeId = 50,
						portId = "In"
					}
				}
			}
		},
		[50] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-498.526,
					58.781,
					779.372
				},
				rotationVInput = {
					357.249,
					190.532,
					0
				}
			},
			fields = {
				cameraId = 91346732,
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
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		[51] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 8,
				positionVInput = {
					-498.651,
					59.121,
					778.712
				},
				rotationVInput = {
					357.249,
					190.704,
					0
				}
			},
			fields = {
				cameraId = 91346731,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 100,
				fStop = 23.89
			},
			flowIn = {
				In = 0
			}
		},
		[52] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true,
				staticIdVInput = -206426661,
				loopDurationVInput = 10
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 401059,
				processingTime = 2.333,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[53] = {
			kind = 4,
			fields = {
				delayTime = 0.6
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
		[54] = {
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 55,
						portId = "In"
					}
				}
			}
		},
		[55] = {
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
						nodeId = 15,
						portId = "In"
					}
				}
			}
		},
		[56] = {
			kind = 17,
			fields = {
				entityType = 0
			}
		}
	}
}
