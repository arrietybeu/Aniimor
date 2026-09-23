-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_52754291.lua

return {
	dialogueId = 52754291,
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
						nodeId = 4
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 12
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 45
					}
				},
				["6"] = {
					{
						portId = "In",
						nodeId = 47
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				fovVInput = 48,
				blendTimeVInput = 2,
				positionVInput = {
					-1657.339,
					96.189,
					797.716
				},
				rotationVInput = {
					353.4,
					226.9,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91311302,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				fovVInput = 50,
				blendTimeVInput = 18,
				positionVInput = {
					-1656.559,
					95.9,
					796.6
				},
				rotationVInput = {
					342.8,
					251.5,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91311301,
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
			kind = 19,
			inputs = {
				staticIdVInput = 1,
				targetEulerAngleVInput = {
					0,
					255.81,
					0
				},
				targetPositionVInput = {
					-1656.709,
					94.692,
					795.765
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
							outTangent = 1,
							value = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0,
							inTangent = 0
						},
						{
							outTangent = 0,
							value = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1,
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
			kind = 11,
			fields = {
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
				Out = {
					{
						portId = "In",
						nodeId = 8
					}
				}
			}
		},
		{
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
						portId = "In",
						nodeId = 9
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
						nodeId = 17
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
						nodeId = 13
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 42
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 15
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
						portId = "Stop",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 74,
			inputs = {
				windEffectResIDVInput = "$Eff_Env_CETutotial_Wind_HoleWind.prefab",
				maxSpeedVInput = 0.35,
				maxIntensityVInput = 5,
				endPositionVInput = {
					-1664.361,
					94.766,
					798.377
				},
				startPositionVInput = {
					-1661.919,
					94.488,
					774.358
				}
			},
			dynamicInputs = {
				"maxIntensityDVInput",
				"maxSpeedDVInput"
			},
			flowIn = {
				Stop = 1,
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 6
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
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 46
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 46
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 9
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
			kind = 49,
			valueIn = {
				effectIdVInput = {
					portId = "EffectID",
					nodeId = 48
				},
				generatorIdVInput = {
					portId = "GeneratorID",
					nodeId = 48
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
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
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26021020
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
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
						nodeId = 19
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
						nodeId = 20
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
						nodeId = 27
					}
				},
				["1"] = {
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
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 46,
				blendTimeVInput = 2.5,
				positionVInput = {
					-1654.889,
					95.8,
					797.391
				},
				rotationVInput = {
					354.238,
					245.851,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91311281,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
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
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				fovVInput = 46,
				blendTimeVInput = 25,
				positionVInput = {
					-1654.973,
					95.8,
					797.551
				},
				rotationVInput = {
					356.988,
					240.351,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91311294,
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
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					243.768,
					0
				},
				targetPositionVInput = {
					-1656.43,
					94.627,
					796.739
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
						nodeId = 25
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 2,
				speedVInput = 0.75,
				maxLimitTimeVInput = 10,
				autoPathfindingVInput = true,
				targetEulerAngleVInput = {
					0,
					243.768,
					0
				},
				targetPositionVInput = {
					-1657.3,
					94.681,
					796.31
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
							outTangent = 1,
							value = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0,
							inTangent = 0
						},
						{
							outTangent = 0,
							value = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1,
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
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Daily_Overlook_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 0.5,
				staticIdVInput = 2
			},
			fields = {
				processingTime = 3.033,
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 3,
				aniStateList = {
					"Daily_Overlook_Start",
					"Daily_Overlook_Loop",
					"Daily_Overlook_End"
				}
			},
			flowIn = {
				In = 0
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
						nodeId = 28
					}
				}
			}
		},
		{
			kind = 26,
			inputs = {
				staticIdVInput = 69185470,
				durationVInput = 1,
				targetEulerAngleVInput = {
					0,
					101.46,
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
						nodeId = 29
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
						nodeId = 30
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 31
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 33
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playOnEntityVInput = true,
				animationLayerVInput = 4,
				playableStateVInput = "TalkUpper_PointTo02",
				staticIdVInput = 69185470
			},
			fields = {
				processingTime = 4.667,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				templateId = 400100
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 69185470
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
				lookAtEntityStaticIdVInput = 69185470,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26021021
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 1,
				portCount = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 9.25,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26021022
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 1,
				portCount = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 4.62,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26021023
			},
			fields = {
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 4.62,
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
						nodeId = 36
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
						nodeId = 37
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 31
					}
				},
				["5"] = {
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
				dialogueIdVInput = 26021024
			},
			fields = {
				blackScreenPlayType = 0,
				anim = "Emotion_Firm_Start",
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				animCfg = {
					"Emotion_Firm_Start",
					"Emotion_Firm_Loop",
					"Emotion_Firm_End",
					{
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
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26021025
			},
			fields = {
				blackScreenPlayType = 0,
				anim = "Emotion_ShakeHead",
				blackScreenIntervalTime = 2,
				chatType = 3,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 400100,
				matchAudioDuration = true,
				duration = 5.12,
				disableCamera = false,
				animCfg = {
					[1] = "Emotion_ShakeHead",
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
						nodeId = 39
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
						nodeId = 40
					}
				}
			}
		},
		{
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
						portId = "In",
						nodeId = 41
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
						nodeId = 43
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 69185470,
				targetEulerAngleVInput = {
					0,
					237.24,
					0
				},
				targetPositionVInput = {
					-1655.937,
					94.439,
					798.448
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
						nodeId = 44
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 69185470,
				speedVInput = 0.75,
				maxLimitTimeVInput = 20,
				targetEulerAngleVInput = {
					0,
					239.68,
					0
				},
				targetPositionVInput = {
					-1658.64,
					94.78,
					796.5
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
							outTangent = 1,
							value = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 0,
							inTangent = 0
						},
						{
							outTangent = 0,
							value = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							time = 1,
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
				delayTime = 2
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
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Env_CETutotial_Wind_HoleWind.prefab",
				postionVInput = {
					-1667.356,
					92.742,
					781.147
				},
				rotationVInput = {
					-10.748,
					-37.62,
					0
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
						nodeId = 48
					}
				}
			}
		},
		{
			kind = 37,
			inputs = {
				effectKeyVInput = "$Eff_Env_CETutotial_Wind_HoleWind.prefab",
				postionVInput = {
					-1682.04,
					95.242,
					783.148
				},
				rotationVInput = {
					-7.351,
					-42.488,
					0
				}
			},
			fields = {
				playOne = true
			},
			flowIn = {
				In = 0
			}
		}
	}
}
