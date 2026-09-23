-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91050853.lua

return {
	startNodeId = 1,
	dialogueId = 91050853,
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
			kind = 11,
			fields = {
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
					hideUIWhiteList = {
						[180] = true
					},
					skipUIBlackList = {
						[5] = true
					},
					toplogoComList = {
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
						combat = true,
						chat = true
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
						nodeId = 5,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 4,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 46,
			valueIn = {
				["1"] = {
					nodeId = 48,
					portId = "animationCurveVOutput"
				}
			},
			fields = {
				volumeComponentCount = 1,
				volumeParamInfoCount = 1,
				volumeComponents = {
					{
						active = false,
						typeName = "VignetteComponent",
						parameters = {
							m_VignetteColor = {
								valueType = "color",
								overrideState = true,
								value = {
									a = 1,
									b = 0,
									r = 0,
									g = 0
								}
							},
							m_EdgeWidth = {
								value = 2,
								valueType = "float",
								overrideState = true
							},
							m_EdgeSoftness = {
								value = 0.75,
								valueType = "float",
								overrideState = true
							},
							m_VignetteAlpha = {
								value = 1,
								valueType = "float",
								overrideState = true
							},
							m_FisheyeFovDeg = {
								value = 0,
								valueType = "float",
								overrideState = false
							},
							m_FollowAspect = {
								value = true,
								valueType = "bool",
								overrideState = false
							}
						}
					}
				},
				volumeParamInfo = {
					{
						volumeTypeName = "VignetteComponent",
						params = {
							{
								paramIndex = 1,
								name = "宽度"
							}
						}
					}
				}
			},
			dynamicInputs = {
				"1"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.2
			},
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
						nodeId = 18,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					1,
					195.554,
					1
				},
				targetPositionVInput = {
					-1640.472,
					106.997,
					700.651
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 47,
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
			kind = 5,
			inputs = {
				applyRootMotionVInput = true,
				playableStateVInput = "Story_Getup"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 47,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400100,
				processingTime = 3.767,
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
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				enableCameraZoomVInput = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 10,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				modeInfo = {
					resetAllActions = false,
					blockEvent = false,
					modeType = 1,
					hideTopLogo = true,
					hideMarkShare = false,
					hideInteractionSign = true,
					showHud = true,
					blockCameraZoom = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = false,
					exitCatchMode = true,
					hideUIWhiteList = {
						[46] = true
					},
					toplogoComList = {
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = false,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true
					}
				}
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
						nodeId = 14,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 24,
			inputs = {
				switchToWalkVInput = true,
				speedVInput = 0.75
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.4
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.4
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
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Shiver_Start",
				playStartLoopEndVInput = true,
				playOnEntityVInput = true,
				loopDurationVInput = 5,
				animationLayerVInput = 4
			},
			fields = {
				entityType = 2,
				templateId = 400100,
				processingTime = 1.333,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Shiver_Start",
					"Shiver_Loop",
					"Shiver_End"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 16,
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
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "Shiver_Start",
				playStartLoopEndVInput = true,
				playOnEntityVInput = true,
				loopDurationVInput = 3,
				animationLayerVInput = 4
			},
			fields = {
				entityType = 2,
				templateId = 400100,
				processingTime = 1.333,
				playAniType = 1,
				isLooping = false,
				aniStateList = {
					"Shiver_Start",
					"Shiver_Loop",
					"Shiver_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 39,
			inputs = {
				pitchSpeedRatioVInput = 0.1,
				fovBlendFuncVInput = "Cubic",
				blendToFovVInput = 45,
				yawSpeedRatioVInput = 0.35,
				transitionSpeedVInput = 0,
				playerCamTransitionSpeedVInput = 2.5,
				playerCamShoulderVInput = {
					0.382,
					-0.1,
					2
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 32,
			fields = {
				eventName = "resetBGM"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260220470
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5.5,
				disableCamera = false,
				chatType = 6,
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26022047
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 22,
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
						nodeId = 23,
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
						nodeId = 24,
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
						nodeId = 25,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 26,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 41,
						portId = "Play"
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 0,
				cameraShakeItem = {
					flags = 0,
					random = false,
					initPhase = 0,
					shakeBias = 0,
					shakeAmplitude = 0.15,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					decayTime = 2,
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 0,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0,
								inWeight = 0,
								value = 1,
								weightedMode = 0
							},
							{
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0,
								inWeight = 0,
								value = 1,
								weightedMode = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0,
								inWeight = 0,
								value = 1,
								weightedMode = 0
							},
							{
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0,
								inWeight = 0,
								value = 1,
								weightedMode = 0
							}
						}
					},
					shakeDir = {
						0,
						0.2,
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
				delayTime = 1.2
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26022050
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 2.25,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				enableCameraZoomVInput = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				modeInfo = {
					resetAllActions = false,
					blockEvent = false,
					modeType = 1,
					hideTopLogo = true,
					hideMarkShare = false,
					hideInteractionSign = true,
					showHud = true,
					blockCameraZoom = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = false,
					exitCatchMode = true,
					hideUIWhiteList = {
						[46] = true
					},
					toplogoComList = {
						callFriends = true,
						bubble = true,
						alert = true,
						actionState = true,
						vlog = true,
						teamSpeech = true,
						quest = false,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						npc = true,
						multiPlayer = true,
						combat = true,
						chat = true
					}
				}
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
						nodeId = 32,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 121,
				param = {
					2602112,
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
					true,
					0
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 33,
						portId = "In"
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
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 24,
			inputs = {
				switchToLocomotionVInput = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260230001,
				disablePresetLookAtVInput = true
			},
			fields = {
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 6.12,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260230003
			},
			fields = {
				skipTime = 3,
				portCount = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2
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
						nodeId = 39,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				enableCameraZoomVInput = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 47,
			inputs = {
				cancelFocusToTargetVInput = true,
				cancelBlendFovVInput = true,
				fovBlendOutTimeVInput = 2,
				fovBlendOutFuncVInput = "EaseIn",
				cancelModifyYawSpeedRatioVInput = true,
				cancelModifyPitchSpeedRatioVInput = true
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
		{
			kind = 31,
			inputs = {
				audioEventVInput = "SFX_Novice_Earthquake01"
			},
			flowIn = {
				Play = 0
			}
		},
		[47] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[48] = {
			kind = 59,
			fields = {
				animationCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							time = 0,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 1.999939,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 2.746019,
							outTangent = 0.1174946,
							inTangent = 0.1174946,
							inWeight = 0,
							value = 0.4325165,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 4.47884,
							outTangent = -0.01289218,
							inTangent = -0.01289218,
							inWeight = 0,
							value = 0.8506042,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 6.482499,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.2488505,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 7.758335,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.5957549,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 8.973153,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.3635166,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 10.554,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.8042349,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 12.97342,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.1795261,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 13.55958,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.28123,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 14.39524,
							outTangent = -0.3442466,
							inTangent = -0.3442466,
							inWeight = 0,
							value = 0.06354927,
							weightedMode = 0
						},
						{
							outWeight = 0,
							time = 15.00103,
							outTangent = 0,
							inTangent = 0,
							inWeight = 0,
							value = 0.0002282123,
							weightedMode = 0
						}
					}
				}
			}
		}
	}
}
