-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79889537.lua

return {
	startNodeId = 1,
	dialogueId = 79889537,
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
						nodeId = 3,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 190,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 191,
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
					hideMarkShare = true,
					hideUIWhiteList = {
						[121] = true
					},
					toplogoComList = {
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
						actionState = true,
						vlog = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 5,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 19,
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
						nodeId = 6,
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
						nodeId = 7,
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
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				endSkipVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 9,
						portId = "In"
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
				["0"] = {
					{
						nodeId = 10,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 17,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 14,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 15,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 18,
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
						nodeId = 11,
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
			kind = 21,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -468231986
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1743896043
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = -1415202851
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 27,
			fields = {
				uid = 121,
				param = {
					5701082,
					0,
					{
						0,
						0,
						0
					},
					{
						0,
						0,
						0
					},
					{
						0,
						0,
						0
					},
					true,
					false,
					0
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 79337005
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				staticIdVInput = 71926584
			},
			flowIn = {
				In = 0
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
						nodeId = 20,
						portId = "0"
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
				["2"] = 0,
				["1"] = 0,
				["0"] = 0
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
						nodeId = 188,
						portId = "In"
					}
				},
				Out = {
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
				portCount = 3
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
						nodeId = 186,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 187,
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
						nodeId = 34,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400077,
				positionVInput = {
					-634.236,
					48.168,
					853.195
				},
				rotationVInput = {
					0,
					166.223,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1743896043
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				durationVInput = 2,
				staticIdVInput = -1743896043
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79337005,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
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
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1743896043,
				playableStateVInput = "Story_FoldArms_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400077,
				processingTime = 0,
				playAniType = 1,
				aniStateList = {
					"Story_FoldArms_Start",
					"Story_FoldArms_Loop",
					"Story_FoldArms_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 200001,
				positionVInput = {
					-633.416,
					48.276,
					853.649
				},
				rotationVInput = {
					0,
					188.09,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1104119422
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.129,
				staticIdVInput = -1104119422,
				targetEulerAngleVInput = {
					0,
					198.87,
					0
				},
				targetPositionVInput = {
					-633.695,
					48.026,
					851.942
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
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
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
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79337005,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 31,
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
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				speedVInput = 2,
				playableStateVInput = "Story_ShakeHead",
				staticIdVInput = -1104119422
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 200001,
				processingTime = 2,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1350180127,
				lookAtEntityIdVInput = -1350180127,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304070
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3.62,
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
						nodeId = 35,
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
						nodeId = 36,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 184,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304071
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400077,
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
						nodeId = 37,
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
						nodeId = 38,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 182,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 183,
						portId = "In"
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
						nodeId = 39,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 181,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304073
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
				matchAudioDuration = true,
				duration = 5.62,
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
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3907913
			},
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
			kind = 12,
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
				portCount = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 179,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 180,
						portId = "In"
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
						nodeId = 44,
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
						nodeId = 45,
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
					hideMarkShare = true,
					hideUIWhiteList = {
						[121] = true
					},
					toplogoComList = {
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
						actionState = true,
						vlog = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 8,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 46,
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
						nodeId = 176,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 177,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 178,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 47,
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
					hideMarkShare = true,
					hideUIWhiteList = {
						[190] = true
					},
					toplogoComList = {
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
						actionState = true,
						vlog = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 175,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 48,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 22,
			inputs = {
				blendVInput = 0.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
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
				portCount = 9
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 70,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 72,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 75,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 50,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 68,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 76,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 173,
						portId = "In"
					}
				},
				["8"] = {
					{
						nodeId = 174,
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
					139.97,
					0
				},
				targetPositionVInput = {
					-636.698,
					48.032,
					850.512
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
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-637.72,
					49.392,
					852.082
				},
				rotationVInput = {
					40.369,
					81.214,
					-0.002
				}
			},
			fields = {
				cameraId = 84206173,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 230,
				fStop = 18.21
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 52,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 2.3,
				fovVInput = 35,
				positionVInput = {
					-637.67,
					49.348,
					852.09
				},
				rotationVInput = {
					40.369,
					81.214,
					-0.002
				}
			},
			fields = {
				cameraId = 84234370,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 230,
				fStop = 18.21
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 53,
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
						nodeId = 55,
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
						nodeId = 62,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					139.96,
					0
				},
				targetPositionVInput = {
					-636.57,
					48.023,
					850.497
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
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 58,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 56,
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
						nodeId = 57,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-636.46,
					48.949,
					850.143
				},
				rotationVInput = {
					18.942,
					100.275,
					0
				}
			},
			fields = {
				cameraId = 84190031,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304074
			},
			fields = {
				portCount = 2,
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
						nodeId = 59,
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
						nodeId = 60,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1202062510
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1415202851,
				targetEulerAngleVInput = {
					0,
					300.855,
					0
				},
				targetPositionVInput = {
					-635.479,
					48.686,
					849.127
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
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				staticIdVInput = -1104119422,
				targetEulerAngleVInput = {
					0,
					167.73,
					0
				},
				targetPositionVInput = {
					-636.021,
					48.007,
					851.215
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
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
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
				speedVInput = 1.25,
				staticIdVInput = -1743896043,
				targetEulerAngleVInput = {
					0,
					170.702,
					0
				},
				targetPositionVInput = {
					-635.268,
					48.019,
					851.574
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
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
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
						nodeId = 64,
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
						nodeId = 65,
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
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -468231986,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -468231986,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -468231986,
				staticIdVInput = -1743896043
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.7
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
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 600047,
				positionVInput = {
					-636.544,
					48.173,
					852.374
				},
				rotationVInput = {
					62.527,
					118.119,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1202062510
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
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 57,
			inputs = {
				isIdyllVInput = true,
				playerEntIdVInput = -1415202851,
				petEntIdVInput = -468231986
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 73,
						portId = "In"
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
						nodeId = 74,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -468231986,
				targetEulerAngleVInput = {
					0,
					288.859,
					0
				},
				targetPositionVInput = {
					-634.74,
					47.94,
					849.845
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
		{
			kind = 5,
			inputs = {
				speedVInput = 1.1,
				loopDurationVInput = 2.01,
				playableStateVInput = "EnvBehav_Sleep_End",
				staticIdVInput = -468231986
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400203,
				processingTime = 8,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5.5
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
						nodeId = 78,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 79,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 57,
			inputs = {
				isIdyllVInput = true,
				switchToPetVInput = false,
				playerEntIdVInput = -1415202851,
				petEntIdVInput = -468231986
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
						nodeId = 80,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 167,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 169,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 168,
						portId = "In"
					}
				},
				["8"] = {
					{
						nodeId = 172,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304075
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 81,
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
						nodeId = 82,
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
						nodeId = 83,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 167,
						portId = "closeUIFInput"
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
						nodeId = 84,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 85,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 162,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 165,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 163,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 161,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 164,
						portId = "In"
					}
				},
				["7"] = {
					{
						nodeId = 166,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 35,
				positionVInput = {
					-636.286,
					49.395,
					848.92
				},
				rotationVInput = {
					1.491,
					3.008,
					0.177
				}
			},
			fields = {
				cameraId = 84191171,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 140,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400204,
				dialogueIdVInput = 3304076
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5.75,
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
						nodeId = 86,
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
						nodeId = 87,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 157,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 155,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 156,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 160,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 161,
						portId = "StopEmotion"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304018
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 88,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304077
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 89,
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
						nodeId = 93,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 92,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 91,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 90,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1743896043,
				facialEmotionVInput = "Smile"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0,
				StopEmotion = 1
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = -1743896043
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400077,
				processingTime = 3.2,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 35,
				positionVInput = {
					-635.789,
					49.27,
					850.379
				},
				rotationVInput = {
					1.995,
					20.678,
					358.847
				}
			},
			fields = {
				cameraId = 84193687,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 116,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400204,
				dialogueIdVInput = 3304078
			},
			fields = {
				portCount = 3,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400077,
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
						nodeId = 94,
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
						nodeId = 97,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 95,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 90,
						portId = "StopEmotion"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 30,
				positionVInput = {
					-637.369,
					49.718,
					849.349
				},
				rotationVInput = {
					19.605,
					91.505,
					0
				}
			},
			fields = {
				cameraId = 90845899,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 3,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 3304079
			},
			fields = {
				blackScreenPlayType = 0,
				portCount = 3,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				audioName = "VOX_Chapter01_Sunia_004",
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 98,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 149,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3304080
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 99,
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
						nodeId = 100,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 101,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 2.667,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304082
			},
			fields = {
				blackScreenPlayType = 0,
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 8.38,
				disableCamera = false,
				chatType = 3,
				audioName = "VOX_Chapter01_Sunia_005",
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 102,
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
						nodeId = 103,
						portId = "In"
					}
				},
				["1"] = {
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
				playableStateVInput = "Talk_Lefthand",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 2,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400077,
				dialogueIdVInput = 3304084
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 9.25,
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
						nodeId = 105,
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
						nodeId = 106,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 147,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 148,
						portId = "In"
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
						nodeId = 145,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 107,
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
						nodeId = 108,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 144,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400204,
				dialogueIdVInput = 3304085
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
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
						nodeId = 109,
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
						nodeId = 111,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 110,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 30,
				positionVInput = {
					-637.369,
					49.718,
					849.349
				},
				rotationVInput = {
					19.605,
					91.505,
					0
				}
			},
			fields = {
				cameraId = 90845730,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304087
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 8,
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
						nodeId = 112,
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
						nodeId = 113,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 139,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 140,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 141,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 142,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 143,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304088
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400077,
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
						nodeId = 114,
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
						nodeId = 119,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 115,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 117,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 118,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 137,
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
						nodeId = 116,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 30,
				positionVInput = {
					-637.369,
					49.718,
					849.349
				},
				rotationVInput = {
					19.605,
					91.505,
					0
				}
			},
			fields = {
				cameraId = 90845790,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 2.683,
				playAniType = 1
			},
			flowIn = {
				In = 0,
				Stop = 1
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1415202851,
				facialEmotionVInput = "Serious"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304089
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 10.62,
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
						nodeId = 120,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304090
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 121,
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
						nodeId = 122,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 135,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 117,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400077,
				dialogueIdVInput = 3304091
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 123,
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
						nodeId = 124,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 136,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 135,
						portId = "StopEmotion"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304092
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
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
						nodeId = 125,
						portId = "In"
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
				["0"] = {
					{
						nodeId = 126,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 134,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 127,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 129,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 131,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 132,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 133,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304093
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
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
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				durationVInput = 0.7,
				staticIdVInput = -468231986,
				targetEulerAngleVInput = {
					0,
					180,
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
						nodeId = 128,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 9,
				autoPathfindingVInput = true,
				staticIdVInput = -468231986,
				targetPositionVInput = {
					-622.256,
					48.224,
					841.693
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
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
						}
					}
				}
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
					-638.882,
					49.377,
					849.82
				},
				rotationVInput = {
					358.73,
					104.109,
					358.847
				}
			},
			fields = {
				cameraId = 91282055,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 130,
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
					-638.339,
					49.675,
					849.675
				},
				rotationVInput = {
					358.902,
					106.856,
					358.847
				}
			},
			fields = {
				cameraId = 91282063,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 1561,
				fStop = 32
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 19,
			inputs = {
				maxLimitTimeVInput = 9,
				speedVInput = 0.75,
				autoPathfindingVInput = true,
				staticIdVInput = -1743896043,
				targetEulerAngleVInput = {
					0,
					124.366,
					0
				},
				targetPositionVInput = {
					-623.849,
					48.224,
					840.693
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
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
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
				speedVInput = 0.75,
				autoPathfindingVInput = true,
				staticIdVInput = 2,
				targetPositionVInput = {
					-631.256,
					48.224,
					847.693
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
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
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
				maxLimitTimeVInput = 9,
				speedVInput = 1.12,
				autoPathfindingVInput = true,
				staticIdVInput = -1104119422,
				targetPositionVInput = {
					-631.256,
					48.224,
					847.693
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
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
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
				maxLimitTimeVInput = 9,
				speedVInput = 0.936,
				autoPathfindingVInput = true,
				staticIdVInput = -1415202851,
				targetEulerAngleVInput = {
					0,
					124.366,
					0
				},
				targetPositionVInput = {
					-623.849,
					48.224,
					840.693
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
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
						}
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1415202851,
				facialEmotionVInput = "Shy"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0,
				StopEmotion = 1
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1415202851
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
						nodeId = 138,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = -1415202851
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				positionVInput = {
					-635.869,
					49.516,
					848.196
				},
				rotationVInput = {
					13.229,
					3.544,
					0.724
				}
			},
			fields = {
				cameraId = 91303892,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 144,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 115,
				fStop = 8.1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1743896043,
				staticIdVInput = -1415202851
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1743896043,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = -1743896043
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1743896043,
				facialEmotionVInput = "Excited"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_ShakeHead",
				staticIdVInput = -1104119422
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 500030,
				processingTime = 1,
				playAniType = 1
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
				["0"] = {
					{
						nodeId = 146,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 144,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400204,
				dialogueIdVInput = 3304086
			},
			fields = {
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
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
						nodeId = 109,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 30,
				positionVInput = {
					-636.157,
					49.061,
					848.799
				},
				rotationVInput = {
					17.715,
					2.64,
					0
				}
			},
			fields = {
				cameraId = 90762661,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 150,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1415202851,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 3304081
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 150,
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
						nodeId = 151,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 152,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Introduce",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 2.667,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304083
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 8.12,
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
						nodeId = 153,
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
						nodeId = 104,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 154,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Righthand",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 2,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1415202851,
				playableStateVInput = "Talk_Shrug",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 3.433,
				playAniType = 1,
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
				playableStateVInput = "Talk_Lefthand",
				staticIdVInput = -1415202851
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 3.433,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 35,
				positionVInput = {
					-639.369,
					49.767,
					850.665
				},
				rotationVInput = {
					14.072,
					93.578,
					358.207
				}
			},
			fields = {
				cameraId = 84191170,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160,
				fStop = 16
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 158,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 159,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 3,
				fovVInput = 35,
				blendExponentVInput = 0,
				positionVInput = {
					-639.369,
					49.767,
					850.665
				},
				rotationVInput = {
					11.323,
					97.791,
					358.227
				}
			},
			fields = {
				cameraId = 90845728,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 160,
				fStop = 16
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = -1743896043,
				targetEulerAngleVInput = {
					0,
					170.704,
					0
				},
				targetPositionVInput = {
					-635.358,
					48.02,
					851.606
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
		{
			kind = 33,
			inputs = {
				entityIdVInput = -1415202851,
				facialEmotionVInput = "Smile"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 33,
			inputs = {
				entityIdVInput = 2,
				facialEmotionVInput = "Confused"
			},
			fields = {
				noBlink = false,
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = 0,
				StopEmotion = 1
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1415202851,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = -1415202851
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1415202851,
				staticIdVInput = -1743896043
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
				animationLayerVInput = 4,
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 0,
				templateId = 4,
				processingTime = 5.333,
				playAniType = 1,
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
			kind = 14,
			inputs = {
				staticIdVInput = -468231986,
				targetEulerAngleVInput = {
					0,
					288.859,
					0
				},
				targetPositionVInput = {
					-634.61,
					47.954,
					849.616
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
		{
			kind = 27,
			fields = {
				uid = 306,
				param = {
					name = "CHARACTER_APPEARANCE_NAME_Sunia",
					title = "CHARACTER_APPEARANCE_DESC_Sunia",
					pos = {
						-1000,
						0,
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
				blendExponentVInput = 0,
				blendTimeVInput = 3,
				positionVInput = {
					-636.891,
					49.345,
					849.935
				},
				rotationVInput = {
					12.869,
					106.68,
					358.216
				}
			},
			fields = {
				cameraId = 84220053,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 230,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 120,
				fStop = 16
			},
			flowIn = {
				In = 0
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
						nodeId = 171,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 170,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = -1415202851,
				playableStateVInput = "Emotion_Confused_Start",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400204,
				processingTime = 7.117,
				playAniType = 1,
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
			kind = 33,
			inputs = {
				entityIdVInput = -1415202851,
				facialEmotionVInput = "Surprised"
			},
			fields = {
				noBlink = true,
				activePlayLip = true,
				activePlayEmotion = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -1415202851,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = 71926584
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1115081540
			},
			flowIn = {
				In = 0
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
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400066,
				positionVInput = {
					-623.459,
					48.391,
					836.861
				},
				rotationVInput = {
					0,
					137.554,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -468231986
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400204,
				positionVInput = {
					-623.459,
					48.391,
					836.861
				},
				rotationVInput = {
					0,
					137.554,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1415202851
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				staticIdVInput = -1672610893
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Skill_RoarAttack",
				staticIdVInput = -1104119422
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 1110075,
				processingTime = 2.417,
				playAniType = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79337005,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304072
			},
			fields = {
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400062,
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
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = -1104119422
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 25,
				positionVInput = {
					-635.461,
					49.562,
					851.132
				},
				rotationVInput = {
					31.252,
					73.321,
					1.566
				}
			},
			fields = {
				cameraId = 91305731,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 120,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 166,
				fStop = 9.77
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 35,
				positionVInput = {
					-635.427,
					49.786,
					854.326
				},
				rotationVInput = {
					14.745,
					154.715,
					0
				}
			},
			fields = {
				cameraId = 91305417,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 120,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 166,
				fStop = 9.77
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 185,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				fovVInput = 35,
				blendTimeVInput = 16,
				positionVInput = {
					-635.852,
					49.675,
					854.477
				},
				rotationVInput = {
					16.672,
					144.745,
					0
				}
			},
			fields = {
				cameraId = 91305730,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 120,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 300,
				fStop = 10.77
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
					136.968,
					0
				},
				targetPositionVInput = {
					-635.101,
					48.078,
					852.508
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
							outWeight = 0,
							value = 0,
							outTangent = 1,
							inTangent = 0,
							inWeight = 0,
							time = 0,
							weightedMode = 0
						},
						{
							outWeight = 0,
							value = 1,
							outTangent = 0,
							inTangent = 1,
							inWeight = 0,
							time = 1,
							weightedMode = 0
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
				staticIdVInput = -1672610893,
				loopDurationVInput = 999,
				playableStateVInput = "Behav_SleepLoop",
				playStartLoopEndVInput = true
			},
			fields = {
				isLooping = false,
				entityType = 2,
				templateId = 400066,
				processingTime = 0,
				playAniType = 1,
				aniStateList = {
					"Behav_SleepLoop",
					"Behav_SleepLoop",
					"Behav_SleepLoop"
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
					-636.002,
					49.523,
					852.174
				},
				rotationVInput = {
					28.62,
					112.4,
					0
				}
			},
			fields = {
				cameraId = 91305419,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 170,
				fStop = 7
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 189,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 6,
				fovVInput = 30,
				positionVInput = {
					-635.16,
					49.026,
					851.827
				},
				rotationVInput = {
					28.62,
					112.4,
					0
				}
			},
			fields = {
				cameraId = 91397297,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 78,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 170,
				fStop = 7
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400066,
				positionVInput = {
					-633.93,
					47.94,
					849.6
				},
				rotationVInput = {
					0,
					317.677,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1672610893
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 20,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 600046,
				positionVInput = {
					-633.883,
					48.004,
					851.315
				},
				rotationVInput = {
					0,
					137.554,
					0
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1115081540
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 20,
						portId = "2"
					}
				}
			}
		}
	}
}
