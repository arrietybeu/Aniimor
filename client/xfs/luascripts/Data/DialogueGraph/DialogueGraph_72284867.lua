-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72284867.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 72284867,
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
					pauseNearbyMonsterAI = false,
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
						bubble = false,
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
				portCount = 2
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
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 58,
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
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "OutBag"
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 3,
				processingTime = 1
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
						portId = "In",
						nodeId = 7
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
						nodeId = 40
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				["2"] = {
					{
						portId = "In",
						nodeId = 41
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.45
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
			kind = 22,
			inputs = {
				blendVInput = 0.15
			},
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
			kind = 4,
			fields = {
				delayTime = 0.1
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
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				blendExponentVInput = 0,
				fovVInput = 36,
				positionVInput = {
					-1689.183,
					94.336,
					757.542
				},
				rotationVInput = {
					17.407,
					126.431,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 73751593,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						portId = "In",
						nodeId = 12
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 13
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendExponentVInput = 0,
				blendTimeVInput = 6,
				positionVInput = {
					-1688.688,
					93.32,
					757.114
				},
				rotationVInput = {
					2.8,
					124.39,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					portId = "BoneTransform",
					nodeId = 43
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 4,
				cameraId = 73750003,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.2
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
			kind = 27,
			fields = {
				uid = 180
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						portId = "closeUIFInput",
						nodeId = 16
					}
				},
				Out = {
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
				delayTime = 0.8
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
			kind = 27,
			fields = {
				uid = 180,
				param = {
					26022022,
					0,
					0,
					0,
					0,
					{
						-1686.22,
						93.55,
						754.59
					},
					{
						0,
						149.1,
						0
					},
					0,
					364
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						portId = "closeUIFInput",
						nodeId = 18
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 17
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
						nodeId = 18
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					26022023,
					0,
					0,
					0,
					0,
					{
						-1685.11,
						92.83,
						756.17
					},
					{
						0,
						95.1,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						portId = "closeUIFInput",
						nodeId = 19
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 35
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					260220230,
					0,
					0,
					1,
					0,
					{
						-1686.24,
						93.28,
						755.09
					},
					{
						0,
						141.4,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				closeUIFInput = 1,
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						portId = "In",
						nodeId = 21
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 20
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2.8
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "closeUIFInput",
						nodeId = 14
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
						nodeId = 22
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
						portId = "Play",
						nodeId = 33
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
						nodeId = 34
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.1
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
			kind = 32,
			fields = {
				eventName = "showPhoto",
				eventParam = {
					[1] = "$UI_Img_ItemView_1004100.png",
					[2] = {
						1004100
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
						nodeId = 25
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
						nodeId = 27
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
						nodeId = 30
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 28
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
						portId = "In",
						nodeId = 29
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 2,
				playableStateVInput = "IntoBag"
			},
			fields = {
				playAniType = 1,
				isLooping = false,
				entityType = 0,
				templateId = 3,
				processingTime = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 21,
			inputs = {
				blendTimeVInput = 1.6
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
			kind = 4,
			fields = {
				delayTime = 0.9
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
			kind = 31,
			inputs = {
				audioEventVInput = "ui_photo_shutter"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "Cubic",
				blendExponentVInput = 0,
				fovVInput = 35,
				positionVInput = {
					-1688.688,
					93.32,
					757.114
				},
				rotationVInput = {
					2.8,
					124.39,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					portId = "BoneTransform",
					nodeId = 44
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = true,
				focalDistance = 200,
				fStop = 4,
				cameraId = 91285011,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false
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
						portId = "In",
						nodeId = 36
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
						nodeId = 38
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
			kind = 4,
			fields = {
				delayTime = 1.4
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
			kind = 46,
			fields = {
				volumeComponentCount = 1,
				volumeComponents = {
					{
						typeName = "GlitchComponent",
						active = false,
						parameters = {
							m_GlitchSeed = {
								overrideState = true,
								valueType = "vector3",
								value = {
									x = 0.5,
									z = 1.2,
									y = 1.5
								}
							},
							m_GlitchStrength = {
								overrideState = true,
								value = 2,
								valueType = "float"
							},
							m_GlitchSpeed = {
								overrideState = true,
								value = 8,
								valueType = "float"
							},
							m_JitterSpeed = {
								overrideState = true,
								value = 2,
								valueType = "float"
							},
							m_GlitchDirectionStrength = {
								overrideState = true,
								valueType = "vector2",
								value = {
									x = 1,
									y = -0.25
								}
							},
							m_GlitchBlockNum = {
								overrideState = true,
								valueType = "vector4",
								value = {
									x = 8,
									w = 30,
									z = 11,
									y = 12
								}
							},
							m_GlitchBlockClip = {
								overrideState = true,
								value = 0.7,
								valueType = "float"
							},
							m_RGBSPlit = {
								overrideState = true,
								valueType = "vector3",
								value = {
									x = 1,
									z = 0.2,
									y = 0.1
								}
							},
							m_GhostFactor = {
								overrideState = true,
								value = 0.8,
								valueType = "float"
							},
							m_Noisy_Tilling = {
								overrideState = true,
								valueType = "vector2",
								value = {
									x = 0.04,
									y = 0.7
								}
							},
							m_NoisyOffset = {
								overrideState = true,
								value = 0,
								valueType = "float"
							}
						}
					}
				}
			},
			flowIn = {
				Stop = 1,
				In = 0
			},
			flowOut = {
				Out = {
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
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "Stop",
						nodeId = 38
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				blendTimeVInput = 18,
				positionVInput = {
					-1689.09,
					94.336,
					757.922
				},
				rotationVInput = {
					15,
					155.7,
					0
				}
			},
			fields = {
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200,
				fStop = 4,
				cameraId = 73721531,
				sensorWidth = 360,
				squeezeFactor = 1,
				visualizeDOF = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.6
			},
			flowIn = {
				In = 0
			}
		},
		[43] = {
			kind = 17,
			inputs = {
				staticIdVInput = 72462615
			},
			fields = {
				entityType = 2
			}
		},
		[44] = {
			kind = 17,
			inputs = {
				staticIdVInput = 72462615
			},
			fields = {
				entityType = 2
			}
		}
	}
}
