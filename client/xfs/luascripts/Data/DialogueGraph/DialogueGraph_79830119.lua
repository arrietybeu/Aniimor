-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79830119.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 79830119,
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
						nodeId = 3
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 229
					}
				}
			}
		},
		{
			kind = 45,
			inputs = {
				timelineResIdVInput = "$P_TL_Grass_P6_IrisTectorumBossPostwar.prefab"
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				PreFinish = {
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
			kind = 24,
			inputs = {
				switchToLocomotionVInput = true,
				switchToPlayerVInput = true
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
			kind = 11,
			fields = {
				onSkipStartConnected = true,
				modeInfo = {
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
					hideTopLogo = true,
					toplogoComList = {
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
						alert = true,
						actionState = true
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
						nodeId = 7
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 27
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
				DirectOut = {
					{
						portId = "In",
						nodeId = 8
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
						nodeId = 11
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 9
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 24
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
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -841318630
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -291194007
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 12
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
						nodeId = 20
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 21
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 22
					}
				},
				["6"] = {
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
				delayTime = 0.5
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
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 45,
			inputs = {
				timelineResIdVInput = "$P_TL_Grass_P7_IrisTectorumBossDance.prefab"
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
				},
				PreFinish = {
					{
						portId = "In",
						nodeId = 19
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
						nodeId = 17
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
						nodeId = 18
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 32,
			fields = {
				eventName = "blackScreen",
				eventParam = {
					[1] = 174
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1017172349
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 21,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1017172349
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -224513300
			},
			flowIn = {
				In = 0
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
						portId = "In",
						nodeId = 49
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 28
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 48
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 33
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 30
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 38
					}
				},
				["7"] = {
					{
						portId = "In",
						nodeId = 42
					}
				},
				["8"] = {
					{
						portId = "In",
						nodeId = 45
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					44.941,
					12.158,
					1.694
				},
				rotationVInput = {
					14.91,
					254.6,
					0
				}
			},
			fields = {
				focalDistance = 228,
				fStop = 12,
				cameraId = 91377295,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 210,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 15,
				positionVInput = {
					44.729,
					12.101,
					1.635
				},
				rotationVInput = {
					14.394,
					254.6,
					0
				}
			},
			fields = {
				focalDistance = 313,
				fStop = 18.21,
				cameraId = 91377356,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
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
					42.241,
					10.175,
					0.541
				},
				rotationVInput = {
					0,
					275.309,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -841318630
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 31
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
						nodeId = 32
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -841318630,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400612,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					40.712,
					10.29,
					-0.666
				},
				rotationVInput = {
					0,
					329.82,
					0
				}
			},
			fields = {
				ignoreGravity = true,
				entityId = -1017172349
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 34
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
						nodeId = 35
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
						nodeId = 36
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
			kind = 15,
			inputs = {
				staticIdVInput = -1017172349,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 52,
			valueIn = {
				Value = {
					portId = "EntityID",
					nodeId = 33
				}
			},
			fields = {
				variableName = "myString"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400513,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					39.983,
					10.1,
					0.631
				},
				rotationVInput = {
					0,
					97.947,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1855918842
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 39
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
						nodeId = 40
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
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 52,
			valueIn = {
				Value = {
					portId = "EntityID",
					nodeId = 38
				}
			},
			fields = {
				variableName = "myString."
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 1,
				positionVInput = {
					42.288,
					10.189,
					1.501
				},
				rotationVInput = {
					0,
					264.08,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -224513300
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -224513300,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 200001,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					41.046,
					10.001,
					1.994
				},
				rotationVInput = {
					0,
					232.187,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -291194007
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
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -291194007,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 409999,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					41.519,
					11.036,
					0.745
				},
				rotationVInput = {
					0,
					243.167,
					0
				}
			},
			fields = {
				ignoreGravity = true,
				entityId = -1623264827
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
						portId = "In",
						nodeId = 51
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
						nodeId = 52
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
						nodeId = 53
					}
				},
				["1"] = {
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
				staticIdVInput = -1855918842,
				speedVInput = 0.8,
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true,
				loopDurationVInput = 87
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906259
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 5.38,
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
						portId = "In",
						nodeId = 55
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
						nodeId = 56
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 227
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 225
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 226
					}
				},
				["4"] = {
					{
						portId = "Stop",
						nodeId = 53
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906260,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 4.25,
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
						portId = "In",
						nodeId = 57
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
						nodeId = 58
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906261,
				lookAtIdVInput = 400513,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 7.62,
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
						portId = "In",
						nodeId = 59
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
						nodeId = 62
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
						nodeId = 221
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 224
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					40.989,
					11.164,
					1.025
				},
				rotationVInput = {
					359.784,
					246.006,
					0
				}
			},
			fields = {
				focalDistance = 117,
				fStop = 10,
				cameraId = 91377616,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 160,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 61
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 15,
				positionVInput = {
					41.074,
					11.226,
					0.784
				},
				rotationVInput = {
					1.159,
					260.101,
					0
				}
			},
			fields = {
				focalDistance = 117,
				fStop = 10,
				cameraId = 91377661,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 160,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906262
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 4.62,
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
						portId = "In",
						nodeId = 63
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 223
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3906263
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 64
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
						nodeId = 65
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 222
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906265
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 8.75,
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
						portId = "In",
						nodeId = 66
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
						nodeId = 67
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 218
					}
				},
				["2"] = {
					{
						portId = "Stop",
						nodeId = 221
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 220
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906266
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 7,
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
						portId = "In",
						nodeId = 68
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
						nodeId = 69
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 217
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906267,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 7.38,
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
						portId = "In",
						nodeId = 70
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
						nodeId = 71
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 214
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 216
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906268,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 1.5,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 4,
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
						portId = "In",
						nodeId = 72
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
						portId = "In",
						nodeId = 75
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 73
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 210
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 211
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 212
					}
				},
				["5"] = {
					{
						portId = "Stop",
						nodeId = 214
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 215
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
						nodeId = 74
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				animationLayerVInput = 4,
				staticIdVInput = -841318630,
				speedVInput = 0.8,
				playableStateVInput = "TalkUpper_Cheeksupport_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 10
			},
			fields = {
				templateId = 400077,
				processingTime = 3,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"TalkUpper_Cheeksupport_Start",
					"TalkUpper_Cheeksupport_Loop",
					"TalkUpper_Cheeksupport_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906269
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -841318630,
				npcId = 400077,
				matchAudioDuration = true,
				duration = 4.12,
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
						portId = "In",
						nodeId = 76
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906270
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 3.12,
				disableCamera = false,
				chatType = 10,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
						nodeId = 78
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 208
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906271
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -841318630,
				npcId = 400077,
				matchAudioDuration = true,
				duration = 5.25,
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
						portId = "In",
						nodeId = 79
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
						nodeId = 80
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 204
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 205
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 201
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 206
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906272,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
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
						portId = "In",
						nodeId = 81
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
						nodeId = 82
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 202
					}
				},
				["4"] = {
					{
						portId = "Stop",
						nodeId = 74
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906273,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -224513300,
				npcId = 0,
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
						portId = "In",
						nodeId = 83
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
						nodeId = 84
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 200
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 199
					}
				},
				["4"] = {
					{
						portId = "Stop",
						nodeId = 201
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906274,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 6.38,
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
						portId = "In",
						nodeId = 85
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906275,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 8.5,
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
						portId = "In",
						nodeId = 86
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906276,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 7,
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
						portId = "In",
						nodeId = 88
					}
				},
				ShowFinOut = {
					{
						portId = "In",
						nodeId = 87
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1458348359
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
				["1"] = {
					{
						portId = "In",
						nodeId = 89
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
						nodeId = 90
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
						nodeId = 94
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 91
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 93
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 198
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					40.835,
					11.436,
					0.587
				},
				rotationVInput = {
					5.284,
					184.127,
					-0.001
				}
			},
			fields = {
				focalDistance = 90,
				fStop = 10,
				cameraId = 91386626,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true
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
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 15,
				positionVInput = {
					40.828,
					11.43,
					0.483
				},
				rotationVInput = {
					2.19,
					183.611,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 18.9,
				cameraId = 91386628,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true,
				speedVInput = 0.7
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 239
				}
			},
			fields = {
				templateId = 400612,
				processingTime = 1.083,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906277,
				lookAtIdVInput = 400513
			},
			fields = {
				blackScreenPlayType = 0,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 2.88,
				disableCamera = false,
				chatType = 3,
				audioName = "VOX_Chapter01_Velouria_134",
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 95
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
						nodeId = 96
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 197
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 196
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906278,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 5.12,
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
						portId = "In",
						nodeId = 97
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
						nodeId = 98
					}
				},
				["1"] = {
					{
						portId = "Stop",
						nodeId = 93
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 194
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 195
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906279,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 9.38,
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
						portId = "In",
						nodeId = 99
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 191
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3906280
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 100
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
						nodeId = 101
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 190
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 185
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 187
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906282,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 1.2,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 5.38,
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
						portId = "In",
						nodeId = 102
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
						nodeId = 184
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 103
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906284,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 3.25,
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
						portId = "In",
						nodeId = 104
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
						nodeId = 105
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 181
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 182
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 183
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906285
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
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
						portId = "In",
						nodeId = 106
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
						nodeId = 107
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 179
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 180
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906286,
				lookAtIdVInput = 400513,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -224513300,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5.12,
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
						portId = "In",
						nodeId = 108
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
						nodeId = 109
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 177
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 176
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906287,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 10.12,
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
						portId = "In",
						nodeId = 110
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
						nodeId = 111
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 176
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906288,
				disablePresetLookAtVInput = true
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 9,
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
						portId = "In",
						nodeId = 112
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"TWIN_PET_CHOICE",
					nil,
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
						nodeId = 172
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
						nodeId = 115
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
						nodeId = 169
					}
				},
				["3"] = {
					{
						portId = "0",
						nodeId = 170
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 171
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					39.858,
					10.693,
					1.791
				},
				rotationVInput = {
					10.785,
					81.854,
					-0.001
				}
			},
			fields = {
				focalDistance = 130,
				fStop = 7.48,
				cameraId = 91386487,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 127,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906289
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
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
						portId = "In",
						nodeId = 116
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906290
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
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
						portId = "In",
						nodeId = 117
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
						nodeId = 118
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 167
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 168
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906293,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 9.38,
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
						portId = "In",
						nodeId = 119
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906294,
				lookAtIdVInput = 400077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 10.12,
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
						portId = "In",
						nodeId = 120
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
						nodeId = 121
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 166
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906295,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 7.75,
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
						portId = "In",
						nodeId = 122
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906296,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 9.38,
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
						portId = "In",
						nodeId = 123
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
						nodeId = 124
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 165
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906297,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 8.88,
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
						portId = "In",
						nodeId = 125
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
						nodeId = 126
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
						nodeId = 164
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906298,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 5.88,
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
						portId = "In",
						nodeId = 127
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
						nodeId = 128
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906299,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
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
						portId = "In",
						nodeId = 129
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
						nodeId = 130
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 161
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 162
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906300,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 8.88,
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
						portId = "In",
						nodeId = 131
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906301,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 4,
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
						portId = "In",
						nodeId = 132
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906302,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 5.5,
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
						portId = "In",
						nodeId = 133
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
						nodeId = 134
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 159
					}
				},
				["2"] = {
					{
						portId = "StopDof",
						nodeId = 159
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906303,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
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
						portId = "In",
						nodeId = 135
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906304,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 6.12,
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
						portId = "In",
						nodeId = 136
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906305,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
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
						portId = "In",
						nodeId = 137
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
						nodeId = 138
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 158
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 157
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906306,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 4.25,
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
						portId = "In",
						nodeId = 139
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906307,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 4.88,
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
						portId = "In",
						nodeId = 140
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
						nodeId = 142
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 141
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.57,
					11.321,
					0.062
				},
				rotationVInput = {
					6.831,
					281.759,
					-0.001
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 10.09,
				cameraId = 91387050,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 193,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906308,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 7.25,
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
						portId = "In",
						nodeId = 143
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
						nodeId = 144
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
						nodeId = 156
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906309,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 3.25,
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
						portId = "In",
						nodeId = 145
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906310,
				lookAtIdVInput = 400513
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1017172349,
				npcId = 400612,
				matchAudioDuration = true,
				duration = 2.75,
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
						portId = "In",
						nodeId = 146
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
						nodeId = 149
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 147
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 151
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 152
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 153
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 154
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.318,
					11.082,
					-0.054
				},
				rotationVInput = {
					350.502,
					285.712,
					-0.001
				}
			},
			fields = {
				focalDistance = 116,
				fStop = 15,
				cameraId = 91387064,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 144,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 148
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				blendTimeVInput = 3,
				positionVInput = {
					40.331,
					10.973,
					-0.144
				},
				rotationVInput = {
					346.549,
					291.385,
					-0.001
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 10.09,
				cameraId = 91430925,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 193,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906311,
				lookAtIdVInput = 400612
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1855918842,
				npcId = 400513,
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
						portId = "In",
						nodeId = 150
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
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Invite_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 99
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 241
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_Invite_Start",
					"EnvBehav_Invite_Loop",
					"EnvBehav_Invite_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -841318630
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -291194007
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -224513300
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
					40.313,
					11.27,
					0.501
				},
				rotationVInput = {
					357.377,
					161.438,
					-0.001
				}
			},
			fields = {
				focalDistance = 118,
				fStop = 5.08,
				cameraId = 91386834,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 74,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Promise_Start",
				playStartLoopEndVInput = true,
				speedVInput = 0.7,
				staticIdVInput = -1017172349
			},
			fields = {
				templateId = 400612,
				processingTime = 1.083,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Promise_Start",
					"Story_Promise_Loop",
					"Story_Promise_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 99,
				playableStateVInput = "EnvBehav_Firm"
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 244
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 4.667,
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
				fovVInput = 30,
				positionVInput = {
					38.658,
					11.027,
					2.297
				},
				rotationVInput = {
					356.346,
					152.671,
					-0.001
				}
			},
			fields = {
				focalDistance = 393,
				fStop = 11.98,
				cameraId = 91386979,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 196,
				recombineQuality = 0,
				openDof = true
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
					-22.096,
					13.46,
					8.925
				},
				rotationVInput = {
					3.394,
					205.059,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90871462,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				StopDof = 1,
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 160
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 60,
				blendTimeVInput = 15,
				positionVInput = {
					-25.445,
					13.46,
					10.052
				},
				rotationVInput = {
					3.566,
					189.073,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90871463,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.57,
					11.321,
					0.062
				},
				rotationVInput = {
					6.831,
					281.759,
					-0.001
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 10.09,
				cameraId = 91387049,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 193,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Firm_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 243
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_Firm_Start",
					"EnvBehav_Firm_Loop",
					"EnvBehav_Firm_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					38.658,
					11.027,
					2.297
				},
				rotationVInput = {
					356.346,
					152.671,
					-0.001
				}
			},
			fields = {
				focalDistance = 393,
				fStop = 11.98,
				cameraId = 91387057,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 196,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Talk_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 12
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 242
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_Talk_Start",
					"EnvBehav_Talk_Loop",
					"EnvBehav_Talk_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1855918842,
				targetEulerAngleVInput = {
					0,
					128.971,
					0
				},
				targetPositionVInput = {
					39.475,
					10.001,
					0.335
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
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					40.313,
					11.27,
					0.501
				},
				rotationVInput = {
					357.377,
					161.438,
					-0.001
				}
			},
			fields = {
				focalDistance = 118,
				fStop = 5.08,
				cameraId = 91386828,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 74,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					38.768,
					11.096,
					2.396
				},
				rotationVInput = {
					359.784,
					157.484,
					-0.001
				}
			},
			fields = {
				focalDistance = 449,
				fStop = 14.41,
				cameraId = 91386966,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 182,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Love",
				staticIdVInput = -1855918842,
				loopDurationVInput = 99
			},
			fields = {
				templateId = 400513,
				processingTime = 6,
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
				playableStateVInput = "Idle",
				staticIdVInput = -1855918842,
				loopDurationVInput = 99
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1855918842,
				targetEulerAngleVInput = {
					0,
					23.6,
					0
				},
				targetPositionVInput = {
					39.383,
					10.004,
					0.409
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
						nodeId = 173
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 175
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 169
					}
				},
				["3"] = {
					{
						portId = "1",
						nodeId = 170
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 171
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906291
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 0,
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
						portId = "In",
						nodeId = 174
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906292
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 7,
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
						portId = "In",
						nodeId = 117
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					39.858,
					10.693,
					1.791
				},
				rotationVInput = {
					10.785,
					81.854,
					-0.001
				}
			},
			fields = {
				focalDistance = 130,
				fStop = 7.48,
				cameraId = 91386498,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 127,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					37.399,
					11.459,
					1.116
				},
				rotationVInput = {
					9.753,
					104.543,
					-0.001
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 9.52,
				cameraId = 91386486,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 150,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 178
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				blendTimeVInput = 8,
				positionVInput = {
					37.154,
					11.502,
					1.18
				},
				rotationVInput = {
					9.753,
					104.543,
					-0.001
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 9.52,
				cameraId = 91386705,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 150,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.736,
					11.418,
					1.594
				},
				rotationVInput = {
					7.003,
					106.262,
					-0.001
				}
			},
			fields = {
				focalDistance = 166,
				fStop = 4.9,
				cameraId = 91386484,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 182,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -841318630,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					39.647,
					10.821,
					1.241
				},
				rotationVInput = {
					337.267,
					215.411,
					-0.001
				}
			},
			fields = {
				focalDistance = 115,
				fStop = 11.02,
				cameraId = 91386483,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 130,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.595,
					11.429,
					0.615
				},
				rotationVInput = {
					3.737,
					175.256,
					0
				}
			},
			fields = {
				focalDistance = 117,
				fStop = 11.02,
				cameraId = 91386391,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 3,
				speedVInput = 0.75,
				staticIdVInput = -1855918842,
				targetEulerAngleVInput = {
					0,
					270,
					0
				},
				targetPositionVInput = {
					39.116,
					10.005,
					0.631
				}
			},
			fields = {
				finishToSteer = false,
				reset = false,
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
				FinishOut = {
					{
						portId = "In",
						nodeId = 186
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Firm_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				staticIdVInput = -1855918842
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_Firm_Start",
					"EnvBehav_Firm_Loop",
					"EnvBehav_Firm_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
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
						nodeId = 188
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					40.118,
					10.633,
					1.535
				},
				rotationVInput = {
					345.689,
					212.145,
					-0.001
				}
			},
			fields = {
				focalDistance = 115,
				fStop = 11.02,
				cameraId = 91393330,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 189
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				blendTimeVInput = 4,
				positionVInput = {
					40.1,
					10.728,
					1.354
				},
				rotationVInput = {
					343.283,
					224.005,
					-0.001
				}
			},
			fields = {
				focalDistance = 199,
				fStop = 11.02,
				cameraId = 91393329,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3906281
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
						nodeId = 193
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 190
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 185
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 187
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3906283
			},
			fields = {
				portCount = 1,
				skipTime = 1.2,
				npcStaticId = -1855918842,
				npcId = 400513,
				matchAudioDuration = true,
				duration = 9.12,
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
						portId = "In",
						nodeId = 102
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 37,
				positionVInput = {
					43.172,
					11.908,
					2.574
				},
				rotationVInput = {
					15.941,
					227.27,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 18.9,
				cameraId = 91380934,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Talk"
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 240
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
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
				fovVInput = 27,
				positionVInput = {
					39.99,
					11.131,
					1.897
				},
				rotationVInput = {
					358.914,
					167.567,
					-0.001
				}
			},
			fields = {
				focalDistance = 147,
				fStop = 12,
				cameraId = 91380930,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 133,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1855918842,
				lookAtEntityStaticIdVInput = -1017172349
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 22,
				positionVInput = {
					41.705,
					11.092,
					1.04
				},
				rotationVInput = {
					357.206,
					252.777,
					0
				}
			},
			fields = {
				focalDistance = 228,
				fStop = 8,
				cameraId = 91380388,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 92,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1855918842,
				speedVInput = 0.8,
				playableStateVInput = "EnvBehav_Talk_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 4
			},
			fields = {
				templateId = 400513,
				processingTime = 1.267,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Give_Loop",
				staticIdVInput = -224513300
			},
			fields = {
				templateId = 151001,
				processingTime = 2.3,
				playAniType = 1,
				isLooping = true,
				entityType = 0
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					40.67,
					11.105,
					1.73
				},
				rotationVInput = {
					355.061,
					113.205,
					0
				}
			},
			fields = {
				focalDistance = 173,
				fStop = 21,
				cameraId = 91380360,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 150,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 203
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 8,
				positionVInput = {
					40.485,
					11.252,
					1.62
				},
				rotationVInput = {
					359.702,
					106.845,
					0
				}
			},
			fields = {
				focalDistance = 173,
				fStop = 21,
				cameraId = 91380390,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 150,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 26,
				positionVInput = {
					41.545,
					11.406,
					0.973
				},
				rotationVInput = {
					8.034,
					254.153,
					0
				}
			},
			fields = {
				focalDistance = 172,
				fStop = 27,
				cameraId = 91378624,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -224513300
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 560013,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					41.452,
					9.785,
					1.258
				},
				rotationVInput = {
					0,
					85.086,
					0
				}
			},
			fields = {
				ignoreGravity = true,
				entityId = -1458348359
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 207
					}
				}
			}
		},
		{
			kind = 80,
			inputs = {
				stateNameVInput = "Small_Up"
			},
			valueIn = {
				targetVInput = {
					portId = "BoneTrans",
					nodeId = 206
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 209
					}
				}
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -841318630
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -841318630,
				lookAtEntityStaticIdVInput = -1623264827
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -224513300,
				lookAtEntityStaticIdVInput = -841318630
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					41.365,
					11.597,
					2.34
				},
				rotationVInput = {
					10.097,
					147.171,
					0
				}
			},
			fields = {
				focalDistance = 115,
				fStop = 10,
				cameraId = 91378377,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 110,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 213
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 13,
				positionVInput = {
					41.103,
					11.568,
					1.872
				},
				rotationVInput = {
					9.238,
					132.732,
					0
				}
			},
			fields = {
				focalDistance = 115,
				fStop = 10,
				cameraId = 91381071,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 110,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_ShowLogo_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999,
				staticIdVInput = -1855918842
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_ShowLogo_Start",
					"Story_ShowLogo_Loop",
					"Story_ShowLogo_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -224513300,
				lookAtEntityStaticIdVInput = -841318630
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 32,
				blendTimeVInput = 2,
				positionVInput = {
					40.952,
					11.336,
					0.765
				},
				rotationVInput = {
					19.379,
					268.867,
					0
				}
			},
			fields = {
				focalDistance = 117,
				fStop = 10,
				cameraId = 91432441,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 160,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 32,
				positionVInput = {
					40.997,
					11.341,
					0.774
				},
				rotationVInput = {
					6.831,
					257.007,
					0
				}
			},
			fields = {
				focalDistance = 117,
				fStop = 10,
				cameraId = 91432445,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 160,
				recombineQuality = 0,
				openDof = true
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
					40.835,
					11.436,
					0.587
				},
				rotationVInput = {
					5.284,
					184.127,
					-0.001
				}
			},
			fields = {
				focalDistance = 90,
				fStop = 10,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 219
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 15,
				positionVInput = {
					40.828,
					11.43,
					0.483
				},
				rotationVInput = {
					2.19,
					183.611,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 18.9,
				cameraId = 91378368,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1017172349,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "EnvBehav_Apologize_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "Value",
					nodeId = 238
				}
			},
			fields = {
				templateId = 400513,
				processingTime = 0.883,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"EnvBehav_Apologize_Start",
					"EnvBehav_Apologize_Loop",
					"EnvBehav_Apologize_End"
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3906264
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "In",
						nodeId = 64
					}
				}
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1855918842,
				lookAtEntityStaticIdVInput = -1017172349
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = -1017172349,
				lookAtEntityStaticIdVInput = -1855918842
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				positionVInput = {
					39.99,
					11.131,
					1.897
				},
				rotationVInput = {
					358.914,
					167.567,
					-0.001
				}
			},
			fields = {
				focalDistance = 175,
				fStop = 9,
				cameraId = 91379785,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 130,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 228
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 27,
				blendTimeVInput = 15,
				positionVInput = {
					40.092,
					11.135,
					1.727
				},
				rotationVInput = {
					357.539,
					170.489,
					-0.001
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 18.9,
				cameraId = 91379865,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
			},
			flowIn = {
				In = 0
			}
		},
		[238] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		},
		[239] = {
			kind = 44,
			fields = {
				variableName = "myString"
			}
		},
		[240] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		},
		[241] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		},
		[242] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		},
		[243] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		},
		[244] = {
			kind = 44,
			fields = {
				variableName = "myString."
			}
		}
	},
	blackboard = {
		myString = "anl",
		["myString."] = "yrl"
	}
}
