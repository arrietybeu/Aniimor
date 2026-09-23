-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91023176.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 91023176,
	nodes = {
		[0] = {
			kind = 6,
			flowIn = {
				End = true
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
			kind = 18,
			inputs = {
				startSkipVInput = true,
				showHUDVInput = true,
				pauseNearbyMonsterAIVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				enhanceAmbientIntensityVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				applyStateConflictVInput = true
			},
			fields = {
				topLogoComs = {
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
			},
			flowIn = {
				In = true
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
			kind = 60,
			inputs = {
				enterTypeVInput = 2,
				exitTypeVInput = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 4
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 6
					}
				},
				["1"] = {
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
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 1,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-31.35,
					39.622,
					448.27
				},
				rotationVInput = {
					0,
					330,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = true
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
			kind = 5,
			inputs = {
				applyRootMotionVInput = true,
				playableStateVInput = "Behav_Angry",
				playOnEntityVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			fields = {
				playAniType = 1,
				entityType = 1
			},
			flowIn = {
				In = true
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
				applyRootMotionVInput = true,
				playableStateVInput = "Attack01",
				playOnEntityVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			fields = {
				playAniType = 1,
				entityType = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 10
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 9
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 1,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-32.056,
					39.622,
					449.493
				},
				rotationVInput = {
					0,
					330,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91028154,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 2
			},
			flowIn = {
				In = true
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
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				applyRootMotionVInput = true,
				playableStateVInput = "Attack02",
				playOnEntityVInput = true
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 31
				}
			},
			fields = {
				playAniType = 1,
				entityType = 1
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 13
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
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 1,
				positionVInput = {
					-29.335,
					39.622,
					444.78
				},
				rotationVInput = {
					0,
					330,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91030709,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
			kind = 4,
			fields = {
				delayTime = 1
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 17
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 36,
			inputs = {
				keyValueInput = 5
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = true
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
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 2,
				positionVInput = {
					-29.335,
					51,
					444.78
				},
				rotationVInput = {
					0,
					330,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 91028153,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = true
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
			kind = 56,
			fields = {
				cameraShakeItem = {
					flags = 0,
					shakeRadius = -1,
					decayTime = 2,
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 0,
					random = false,
					initPhase = 0,
					shakeBias = 0,
					shakeAmplitude = 1,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 0,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							},
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 1,
								value = 1,
								weightedMode = 0,
								outWeight = 0
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
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 0,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							},
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 1,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							}
						}
					},
					shakeDir = {
						0,
						1,
						0
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					flags = 0,
					shakeRadius = -1,
					decayTime = 2,
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					shakeFrequency = 6,
					shakeDissipation = 28,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 0,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							},
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 1,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 0,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							},
							{
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								time = 1,
								value = 1,
								weightedMode = 0,
								outWeight = 0
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
					}
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "battle_pets_pikachu_attack_common01"
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
				delayTime = 0.15
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 24
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "battle_pets_pikachu_attack_common01"
			},
			flowIn = {
				Play = true
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
			kind = 4,
			fields = {
				delayTime = 0.15
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 26
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "battle_pets_pikachu_attack_common01"
			},
			flowIn = {
				Play = true
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
			kind = 4,
			fields = {
				delayTime = 0.15
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 28
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "battle_pets_pikachu_attack_common01"
			},
			flowIn = {
				Play = true
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
			kind = 4,
			fields = {
				delayTime = 0.15
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						portId = "Play",
						nodeId = 30
					}
				}
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "battle_pets_pikachu_attack_common01"
			},
			flowIn = {
				Play = true
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 1
			}
		},
		{
			kind = 9,
			fields = {
				entityType = 1
			}
		}
	}
}
