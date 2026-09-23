-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91278303.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91278303,
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
					blockEvent = true,
					modeType = 2,
					toplogoComList = {
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
						multiPlayer = true,
						combat = true,
						chat = true,
						callFriends = true
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
						nodeId = 5
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
						portId = "In",
						nodeId = 4
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
				Out = {
					{
						portId = "End",
						nodeId = 0
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
						nodeId = 6
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
						nodeId = 7
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 34
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 36
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 5200041
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 37
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 37
				}
			},
			fields = {
				entityId = -1410401848,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_AngryLoop"
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 7
				}
			},
			fields = {
				templateId = 5200041,
				processingTime = 1.967,
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
						portId = "0",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 35,
			fields = {
				maxAwaitTime = -1,
				portCount = 3
			},
			flowIn = {
				["0"] = 0,
				["2"] = 0,
				["1"] = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 10
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
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					portId = "EntityIDs",
					nodeId = 33
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
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108004,
				dialogsetCameraIdVInput = 91296585
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 2.25,
				disableCamera = false,
				portCount = 2,
				skipTime = 0
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
			kind = 7,
			fields = {
				dialogueId = 9108005
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
				dialogueIdVInput = 9108006,
				dialogsetCameraIdVInput = 91296585
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 3.38,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108007,
				dialogsetCameraIdVInput = 91296595
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 5.75,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 9108008
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 8.5,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108009
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200041,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 4.62,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 91278017,
				isResetValueInput = true,
				durationVInput = 0
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = -1410401848,
				moveTypeVInput = 4,
				targetPositionVInput = {
					36.662,
					25,
					509.465
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
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							time = 0,
							value = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1,
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
				Out = {
					{
						portId = "In",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108010,
				dialogsetCameraIdVInput = 91296637
			},
			fields = {
				npcStaticId = -1,
				npcId = 5200041,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 2,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108011
			},
			fields = {
				npcStaticId = -83288512,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 2.62,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
				portCount = 2
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
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108012
			},
			fields = {
				npcStaticId = -83288512,
				duration = 4.5,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				npcId = 5200042,
				disableCamera = false,
				portCount = 1,
				anim = "TalkUpper_PointTo01",
				skipTime = 0,
				animCfg = {
					[1] = "TalkUpper_PointTo01",
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
						nodeId = 26
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108061,
				dialogsetCameraIdVInput = 91296585
			},
			fields = {
				npcStaticId = -83288512,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 6.62,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
				dialogueIdVInput = 9108062
			},
			fields = {
				npcStaticId = -83288512,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 7.62,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 9108063,
				dialogsetCameraIdVInput = 91296637
			},
			fields = {
				npcStaticId = -83288512,
				npcId = 5200042,
				matchAudioDuration = true,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				duration = 5.25,
				disableCamera = false,
				portCount = 1,
				skipTime = 0
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
						nodeId = 30
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
			kind = 5,
			inputs = {
				staticIdVInput = -83288512,
				playableStateVInput = "TalkUpper_Sigh",
				defaultTransStateVInput = "Idle",
				animationLayerVInput = 4
			},
			fields = {
				templateId = 5200042,
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
			kind = 5,
			inputs = {
				staticIdVInput = -83288512,
				playableStateVInput = "TalkUpper_PointTo01",
				defaultTransStateVInput = "Idle",
				animationLayerVInput = 4
			},
			fields = {
				templateId = 5200042,
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
			kind = 41,
			valueIn = {
				["1EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 34
				},
				["2EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 7
				},
				["3EntityIDVInput"] = {
					portId = "EntityID",
					nodeId = 39
				}
			},
			fields = {
				portCount = 3
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 5200042
			},
			valueIn = {
				positionVInput = {
					portId = "OutPosition",
					nodeId = 38
				},
				rotationVInput = {
					portId = "OutEulerAngle",
					nodeId = 38
				}
			},
			fields = {
				entityId = -83288512,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 5,
				playStartLoopEndVInput = true,
				playableStateVInput = "TalkUpper_Sigh_Start",
				animationLayerVInput = 4
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 34
				}
			},
			fields = {
				templateId = 5200042,
				processingTime = 1.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"TalkUpper_Sigh_Start",
					"TalkUpper_Sigh_Loop",
					"TalkUpper_Sigh_End"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "1",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 60,
			inputs = {
				exitTypeVInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "2",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 43,
			inputs = {
				sceneIDVinput = 501,
				dialogsetIDVInput = 91296548,
				slotIDVInput = 91296671
			}
		},
		{
			kind = 43,
			inputs = {
				sceneIDVinput = 501,
				dialogsetIDVInput = 91296548,
				slotIDVInput = 91296550
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 0
			}
		}
	}
}
