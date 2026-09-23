-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_53812182.lua

return {
	schema = 1,
	dialogueId = 53812182,
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
				modeInfo = {
					hideInteractionSign = true,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = false,
					blockEvent = false,
					modeType = 1,
					blockCameraZoom = false,
					hideTopLogo = true,
					hideMarkShare = false,
					hideUIWhiteList = {
						[5] = true
					},
					toplogoComList = {
						teamSpeech = true,
						quest = false,
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
				portCount = 6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 4
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 7
					}
				},
				["4"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				["5"] = {
					{
						portId = "In",
						nodeId = 5
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				speedVInput = 1.25,
				moveTypeVInput = 2,
				maxLimitTimeVInput = 20,
				autoPathfindingVInput = true,
				targetEulerAngleVInput = {
					0,
					163.4,
					0
				},
				targetPositionVInput = {
					-1720.052,
					90.748,
					582.67
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 79
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							inTangent = 0,
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							value = 0,
							weightedMode = 0
						},
						{
							inTangent = 1,
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							value = 1,
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
			kind = 39,
			inputs = {
				blendToFovVInput = 30,
				transitionSpeedVInput = 0,
				targetZoomVInput = 0.5,
				pitchSpeedRatioVInput = 0.25,
				fovBlendTimeVInput = 1.5,
				fovBlendFuncVInput = "Linear",
				shoulderVInput = {
					0,
					0,
					2
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
				moveTypeVInput = 2,
				maxLimitTimeVInput = 20,
				autoPathfindingVInput = true,
				targetEulerAngleVInput = {
					0,
					163.4,
					0
				},
				targetPositionVInput = {
					-1719.206,
					90.778,
					583.193
				}
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 85
				}
			},
			fields = {
				reset = false,
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							inTangent = 0,
							time = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							value = 0,
							weightedMode = 0
						},
						{
							inTangent = 1,
							time = 1,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							value = 1,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26023057
			},
			fields = {
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
						nodeId = 9
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
						nodeId = 10
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
						nodeId = 11
					}
				},
				["2"] = {
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
				dialogueIdVInput = 26023056
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 6,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
						nodeId = 13
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
						nodeId = 14
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
						portId = "Play",
						nodeId = 16
					}
				},
				["3"] = {
					{
						portId = "In",
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 0,
				cameraShakeItem = {
					decayTime = 4,
					flags = 0,
					random = false,
					shakeBias = 0,
					shakeAmplitude = 0.3,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadius = -1,
					initPhase = 0,
					sustainTime = 3,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 0,
					shakeRadiusCurve = {
						preWrapMode = 8,
						postWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								value = 1,
								weightedMode = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
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
						preWrapMode = 8,
						postWrapMode = 8,
						keys = {
							{
								inTangent = 0,
								time = 0,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								value = 1,
								weightedMode = 0
							},
							{
								inTangent = 0,
								time = 1,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								value = 1,
								weightedMode = 0
							}
						}
					},
					shakeDir = {
						0.2,
						0.2,
						-0.2
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "SFX_Novice_Earthquake"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26023058
			},
			fields = {
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26023059
			},
			fields = {
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
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
						nodeId = 21
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
						nodeId = 22
					}
				}
			}
		},
		{
			kind = 47,
			inputs = {
				cancelModifyPitchSpeedRatioVInput = true,
				cancelBlendFovVInput = true,
				fovBlendOutFuncVInput = "Linear",
				cancelModifyYawSpeedRatioVInput = true
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
		[79] = {
			kind = 9,
			inputs = {
				staticIdVInput = 79379146
			},
			fields = {
				entityType = 2
			}
		},
		[85] = {
			kind = 9,
			inputs = {
				staticIdVInput = 79379149
			},
			fields = {
				entityType = 2
			}
		}
	}
}
