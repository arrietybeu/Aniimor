-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91031941.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91031941,
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
						alert = true
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
						nodeId = 3
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
						nodeId = 4
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
						nodeId = 5
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
						nodeId = 16
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
						nodeId = 8
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 12
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 14
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0.1,
				staticIdVInput = 91032163
			},
			flowIn = {
				In = 0
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
			kind = 14,
			inputs = {
				staticIdVInput = 91032163,
				targetEulerAngleVInput = {
					0,
					1.72,
					0
				},
				targetPositionVInput = {
					-983.578,
					25.17,
					474.199
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
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0.1,
				staticIdVInput = 91032175
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
		{
			kind = 14,
			inputs = {
				staticIdVInput = 91032175,
				targetEulerAngleVInput = {
					0,
					59.671,
					0
				},
				targetPositionVInput = {
					-979.881,
					25.032,
					475.016
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
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0.1,
				staticIdVInput = 91032176
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
			kind = 14,
			inputs = {
				staticIdVInput = 91032176,
				targetEulerAngleVInput = {
					0,
					331.695,
					0
				},
				targetPositionVInput = {
					-981.324,
					24.968,
					473.671
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
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0.1,
				staticIdVInput = 91032178
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
			kind = 14,
			inputs = {
				staticIdVInput = 91032178,
				targetEulerAngleVInput = {
					0,
					32.952,
					0
				},
				targetPositionVInput = {
					-981.951,
					25.411,
					476.172
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
			kind = 20,
			inputs = {
				isResetValueInput = true,
				durationVInput = 0.1,
				staticIdVInput = 91032177
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
			kind = 14,
			inputs = {
				staticIdVInput = 91032177,
				targetEulerAngleVInput = {
					0,
					32.952,
					0
				},
				targetPositionVInput = {
					-981.951,
					25.411,
					476.172
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
						nodeId = 17
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Linear",
				positionVInput = {
					-981.389,
					27.22,
					478.544
				},
				rotationVInput = {
					27.858,
					181.093,
					0.012
				}
			},
			fields = {
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 0,
				fStop = 4,
				cameraId = 91031983,
				visualizeDOF = false,
				squeezeFactor = 1
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 70008086
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				portCount = 1,
				skipTime = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				matchAudioDuration = true,
				duration = 5.88,
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
						nodeId = 19
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
						nodeId = 20
					}
				},
				["2"] = {
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
						nodeId = 21
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
						nodeId = 22
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 23
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
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Env_SceneObject_Morphling_Appear.prefab",
				postionVInput = {
					-981.951,
					25.411,
					476.172
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0,
				staticIdVInput = 91032177
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
						nodeId = 25
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
						nodeId = 31
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 26
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 27
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 28
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 91032163,
				targetEulerAngleVInput = {
					0,
					144.949,
					0
				},
				targetPositionVInput = {
					-992.221,
					24.68,
					465.31
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
							weightedMode = 0,
							value = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				staticIdVInput = 91032175,
				targetEulerAngleVInput = {
					0,
					85.938,
					0
				},
				targetPositionVInput = {
					-979.3,
					24.67,
					484.01
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
							weightedMode = 0,
							value = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				staticIdVInput = 91032176,
				targetEulerAngleVInput = {
					0,
					90.813,
					0
				},
				targetPositionVInput = {
					-990.448,
					25.44,
					470.931
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
							weightedMode = 0,
							value = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Happy",
				speedVInput = 1.4,
				staticIdVInput = 91032177
			},
			fields = {
				templateId = 11033100,
				processingTime = 4.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				staticIdVInput = 91032177,
				targetEulerAngleVInput = {
					0,
					85.938,
					0
				},
				targetPositionVInput = {
					-979.3,
					24.67,
					484.01
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
							weightedMode = 0,
							value = 0,
							time = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1,
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
		{
			kind = 4,
			fields = {
				delayTime = 5
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
						nodeId = 33
					}
				}
			}
		},
		{
			kind = 21,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 70008089
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				portCount = 1,
				skipTime = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
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
						nodeId = 35
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
						nodeId = 36
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
						nodeId = 37
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
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 70008087
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				portCount = 1,
				skipTime = 0,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0.5,
				staticIdVInput = 91032178
			},
			flowIn = {
				In = 0
			}
		}
	}
}
