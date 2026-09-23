-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90822932.lua

return {
	schema = 1,
	startNodeId = 2,
	dialogueId = 90822932,
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
						nodeId = 3,
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
						quest = true,
						photo = true,
						petFertility = true,
						petExchange = true,
						petChat = true,
						multiPlayer = true,
						combat = true,
						chat = true,
						callFriends = true,
						bubble = true,
						alert = true,
						npc = true,
						actionState = true,
						vlog = true,
						teamSpeech = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 1,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
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
						nodeId = 46,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 44,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 45,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515003
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990063,
				matchAudioDuration = true,
				duration = 2.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
			kind = 7,
			fields = {
				dialogueId = 6515004
			},
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
			kind = 2,
			fields = {
				portCount = 10
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				disablePresetLookAtVInput = true,
				dialogueIdVInput = 6515005
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				anim = "Talk_Introduce",
				portCount = 1,
				npcStaticId = -1750243843,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Talk_Introduce",
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
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
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
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515006
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 9.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515007
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 11,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515008
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 9.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 15,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515009
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 8.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
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
				},
				["1"] = {
					{
						nodeId = 30,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515010
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 10.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
		{
			kind = 2,
			fields = {
				portCount = 10
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
				},
				["1"] = {
					{
						nodeId = 27,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515011
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 1,
				anim = "Daily_Pray_Start",
				portCount = 1,
				npcStaticId = -1750243843,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					"Daily_Pray_Start",
					"Daily_Pray_Loop",
					"Daily_Pray_End",
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
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 10
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
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6515012
			},
			fields = {
				blackScreenIntervalTime = 2,
				skipTime = 0,
				portCount = 1,
				npcStaticId = -1,
				npcId = 990010,
				matchAudioDuration = true,
				duration = 8.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
			kind = 21,
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					-19.756,
					122.971,
					-100.893
				},
				rotationVInput = {
					17.762,
					26.008,
					-0.001
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 91392497,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 4.9,
				positionVInput = {
					-19.756,
					122.971,
					-100.893
				},
				rotationVInput = {
					8.308,
					25.664,
					-0.001
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392498,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
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
					-19.461,
					102.351,
					-46.467
				},
				rotationVInput = {
					4.183,
					181.118,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 4.9,
				positionVInput = {
					-19.463,
					102.333,
					-46.723
				},
				rotationVInput = {
					3.839,
					180.087,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1750243843
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
					-22.946,
					103.026,
					-62.475
				},
				rotationVInput = {
					4.183,
					12.017,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 91392477,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 31,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 5.5,
				positionVInput = {
					-21.726,
					104.806,
					-62.259
				},
				rotationVInput = {
					10.371,
					355.344,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392484,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
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
					25.97,
					102.695,
					-58.167
				},
				rotationVInput = {
					19.653,
					287.037,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 91392482,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 5,
				positionVInput = {
					26.126,
					102.695,
					-57.658
				},
				rotationVInput = {
					19.653,
					287.381,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392483,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				positionVInput = {
					5.213,
					118.775,
					-91.964
				},
				rotationVInput = {
					26.184,
					326.363,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 91392452,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 6,
				positionVInput = {
					5.213,
					118.775,
					-91.964
				},
				rotationVInput = {
					21.887,
					332.035,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392456,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					12.511,
					110.057,
					-97.569
				},
				rotationVInput = {
					13.293,
					210.787,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 130,
				fStop = 20,
				cameraId = 90875632,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendTimeVInput = 4,
				positionVInput = {
					12.565,
					109.615,
					-97.479
				},
				rotationVInput = {
					12.261,
					210.443,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 130,
				fStop = 20,
				cameraId = 91392461,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 300
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 46,
			fields = {
				volumeComponentCount = 2,
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
									b = 1,
									g = 0.4360501,
									r = 0.1179245,
									a = 1
								}
							},
							m_EdgeWidth = {
								valueType = "float",
								value = 0.604,
								overrideState = true
							},
							m_EdgeSoftness = {
								valueType = "float",
								value = 0.118,
								overrideState = true
							},
							m_VignetteAlpha = {
								valueType = "float",
								value = 1,
								overrideState = true
							},
							m_FisheyeFovDeg = {
								valueType = "float",
								value = 22.6,
								overrideState = true
							},
							m_FollowAspect = {
								valueType = "bool",
								value = true,
								overrideState = true
							}
						}
					},
					{
						active = false,
						typeName = "GlitchComponent",
						parameters = {
							m_GlitchSeed = {
								valueType = "vector3",
								overrideState = true,
								value = {
									z = 1,
									y = 1,
									x = 1
								}
							},
							m_GlitchStrength = {
								valueType = "float",
								value = 0.27,
								overrideState = true
							},
							m_GlitchSpeed = {
								valueType = "float",
								value = 10,
								overrideState = true
							},
							m_JitterSpeed = {
								valueType = "float",
								value = 1.21,
								overrideState = true
							},
							m_GlitchDirectionStrength = {
								valueType = "vector2",
								overrideState = true,
								value = {
									y = 0,
									x = -1
								}
							},
							m_GlitchBlockNum = {
								valueType = "vector4",
								overrideState = true,
								value = {
									w = 10,
									z = 10,
									y = 10,
									x = 10
								}
							},
							m_GlitchBlockClip = {
								valueType = "float",
								value = 0,
								overrideState = true
							},
							m_RGBSPlit = {
								valueType = "vector3",
								overrideState = true,
								value = {
									z = 1,
									y = 0,
									x = -1
								}
							},
							m_GhostFactor = {
								valueType = "float",
								value = 0.299,
								overrideState = true
							},
							m_Noisy_Tilling = {
								valueType = "vector2",
								overrideState = true,
								value = {
									y = 1,
									x = 1
								}
							},
							m_NoisyOffset = {
								valueType = "float",
								value = 1,
								overrideState = true
							}
						}
					}
				},
				volumeParamInfo = {
					{
						volumeTypeName = "VignetteComponent",
						params = {}
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
					-19.461,
					102.351,
					-46.467
				},
				rotationVInput = {
					4.183,
					181.118,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 91392414,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
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
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 4.9,
				positionVInput = {
					-19.463,
					102.333,
					-46.723
				},
				rotationVInput = {
					3.839,
					180.087,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392451,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 28,
			inputs = {
				staticIdVInput = -1750243843
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
					15.351,
					103.971,
					-68.676
				},
				rotationVInput = {
					8.996,
					341.421,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 6.39,
				cameraId = 90875533,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 55
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 4.9,
				positionVInput = {
					15.351,
					103.971,
					-68.676
				},
				rotationVInput = {
					8.824,
					339.187,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 84,
				fStop = 8.23,
				cameraId = 91392192,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 50
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 990010,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-19.409,
					101.26,
					-47.545
				},
				rotationVInput = {
					0,
					0.5,
					0
				}
			},
			fields = {
				entityId = -1750243843,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 881113,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-19.49,
					101.26,
					-47.695
				}
			},
			fields = {
				entityId = -1627384995,
				ignoreGravity = false
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
					126.402,
					0
				},
				targetPositionVInput = {
					13.527,
					102.429,
					-66.192
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
		}
	}
}
