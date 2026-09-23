-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91278308.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91278308,
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
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 5200042,
				defaultHideVInput = true
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 46
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 46
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1285998393
			},
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
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 3,
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 2
				},
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 47
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 47
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
							weightedMode = 0,
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0
						},
						{
							weightedMode = 0,
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1
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
						nodeId = 4
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
						nodeId = 5
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
				["1"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 17
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -1285998393,
				targetEulerAngleVInput = {
					0,
					120,
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
						nodeId = 7
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Sigh",
				animationLayerVInput = 4,
				staticIdVInput = -1285998393
			},
			fields = {
				templateId = 5200042,
				processingTime = 3.333,
				playAniType = 1,
				isLooping = false,
				entityType = 2
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108022,
				dialogsetCameraIdVInput = 91292517
			},
			fields = {
				matchAudioDuration = true,
				duration = 3.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Sigh",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5200042,
				animCfg = {
					[1] = "TalkUpper_Sigh",
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
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108023,
				dialogsetCameraIdVInput = 91292517
			},
			fields = {
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5200042
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -1447552602,
				targetEulerAngleVInput = {
					0,
					141.833,
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
				Out = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1447552602
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108024,
				dialogsetCameraIdVInput = 91292556
			},
			fields = {
				matchAudioDuration = true,
				duration = 3.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "Face_Lose",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				animCfg = {
					[1] = "Face_Lose",
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
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Sigh",
				animationLayerVInput = 4,
				staticIdVInput = -1285998393
			},
			fields = {
				templateId = 5200042,
				processingTime = 3.333,
				playAniType = 1,
				isLooping = false,
				entityType = 2
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108068,
				dialogsetCameraIdVInput = 91292556
			},
			fields = {
				matchAudioDuration = true,
				duration = 4.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				anim = "TalkUpper_Sigh",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 5200042,
				animCfg = {
					[1] = "TalkUpper_Sigh",
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
			kind = 22,
			inputs = {
				blendVInput = 1
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
			kind = 23,
			inputs = {
				blendOutTimeVInput = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = -1447552602,
				targetEulerAngleVInput = {
					0,
					-60,
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
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 41
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 33
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 2
				}
			},
			fields = {
				portCount = 3
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 18
				}
			},
			fields = {
				enableGroupLookAt = false,
				enableDefaultLookAt = true,
				cameraPreset = 2,
				resetOrientation = true,
				reactPreset = 0,
				nodeMode = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "0",
						nodeId = 20
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
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				DirectOut = {
					{
						portId = "In",
						nodeId = 22
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 3,
				staticIdVInput = -1447552602,
				speedVInput = 0.97,
				moveTypeVInput = 2
			},
			valueIn = {
				targetEulerAngleVInput = {
					portId = "OutEulerAngle",
					nodeId = 43
				},
				targetPositionVInput = {
					portId = "OutPosition",
					nodeId = 43
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
							weightedMode = 0,
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0
						},
						{
							weightedMode = 0,
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1
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
						nodeId = 23
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
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108020,
				dialogsetCameraIdVInput = 91292543,
				lookAtIdVInput = 5200042
			},
			fields = {
				matchAudioDuration = true,
				duration = 3.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1427968528,
				npcId = 0
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
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -867013800,
				staticIdVInput = -1447552602
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
				maxLimitTimeVInput = 10,
				staticIdVInput = -867013800,
				speedVInput = 0.846,
				moveTypeVInput = 4,
				targetEulerAngleVInput = {
					0,
					174.268,
					0
				},
				targetPositionVInput = {
					29.332,
					25.075,
					417.063
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
							weightedMode = 0,
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0
						},
						{
							weightedMode = 0,
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1
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
						nodeId = 27
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108021,
				dialogsetCameraIdVInput = 91292543
			},
			fields = {
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 2,
				npcStaticId = -1,
				npcId = 5200041
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
			kind = 12,
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
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				durationVInput = 0
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 2
				}
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
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1285998393,
				staticIdVInput = -1447552602
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
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1447552602,
				staticIdVInput = -1285998393
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
			kind = 53,
			inputs = {
				cameraIdVInput = 91292517
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
			kind = 16,
			inputs = {
				slotParamVInput = 5200041,
				virtualEntityTypeVInput = 2
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 44
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 44
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -867013800
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
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_LoveLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 33
				}
			},
			fields = {
				templateId = 5200041,
				processingTime = 2.25,
				playAniType = 1,
				isLooping = true,
				entityType = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "1",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 33
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
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
					resetAllActions = true,
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
					toplogoComList = {
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						battleRoom = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true
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
						nodeId = 16
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 37
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 38
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
						nodeId = 42
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
						nodeId = 35
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
					141.833,
					0
				},
				targetPositionVInput = {
					2.971,
					25.007,
					442.549
				}
			},
			fields = {
				setRotation = true,
				reset = false,
				setPosition = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 40
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 2,
				isResetValueInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 1
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 45
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 45
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1447552602
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 19
					}
				}
			}
		},
		{
			kind = 53,
			inputs = {
				cameraIdVInput = 91292543
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "2",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91292484,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91292481
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91292482,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91292481
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91297501,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91292481
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91297501,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91292481
			}
		},
		{
			kind = 43,
			inputs = {
				slotIDVInput = 91292483,
				sceneIDVinput = 501,
				dialogsetIDVInput = 91292481
			}
		}
	}
}
