-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72285049.lua

return {
	startNodeId = 1,
	dialogueId = 72285049,
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
				onSkipStartConnected = true,
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
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					toplogoComList = {
						combat = true,
						chat = true,
						callFriends = true,
						bubble = false,
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
						multiPlayer = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 0,
						portId = "End"
					}
				},
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
				portCount = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 4,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 6,
						portId = "In"
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
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "OutBag",
				staticIdVInput = 2
			},
			fields = {
				isLooping = false,
				entityType = 0,
				templateId = 3,
				processingTime = 1,
				playAniType = 1
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
						nodeId = 7,
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
						nodeId = 47,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 8,
						portId = "In"
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
						nodeId = 9,
						portId = "In"
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
						nodeId = 10,
						portId = "In"
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
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 40,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 0,
				positionVInput = {
					-1737.276,
					102.6,
					784.795
				},
				rotationVInput = {
					7.9,
					229,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90830584,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 6,
				fovVInput = 36,
				blendExponentVInput = 0,
				positionVInput = {
					-1737.737,
					101.8,
					784.721
				},
				rotationVInput = {
					355.69,
					220.5,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					nodeId = 49,
					portId = "BoneTransform"
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90830586,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
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
						nodeId = 14,
						portId = "In"
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
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 16,
						portId = "closeUIFInput"
					}
				},
				Out = {
					{
						nodeId = 15,
						portId = "In"
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
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					26022026,
					1,
					0,
					0,
					0,
					{
						-1740.67,
						102.53,
						782.93
					},
					{
						0,
						271.63,
						0
					},
					0,
					535
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 17,
						portId = "closeUIFInput"
					}
				},
				Out = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					26022027,
					1,
					0,
					0,
					0,
					{
						-1740.64,
						102.05,
						783.13
					},
					{
						0,
						265.06,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 18,
						portId = "closeUIFInput"
					}
				},
				Out = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					26022028,
					0,
					0,
					0,
					0,
					{
						-1739.63,
						101.9,
						782.26
					},
					{
						0,
						213.9,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 19,
						portId = "closeUIFInput"
					}
				},
				Out = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					260220280,
					0,
					0,
					0,
					0,
					{
						-1738.94,
						102.18,
						782.57
					},
					{
						0,
						216.6,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 20,
						portId = "closeUIFInput"
					}
				},
				Out = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 180,
				param = {
					260220281,
					0,
					0,
					0,
					0,
					{
						-1739.85,
						102.4,
						782.87
					},
					{
						0,
						-118.9,
						0
					},
					0,
					0
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 22,
						portId = "In"
					}
				},
				Out = {
					{
						nodeId = 21,
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
						nodeId = 14,
						portId = "closeUIFInput"
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
						nodeId = 23,
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
						nodeId = 24,
						portId = "Play"
					}
				},
				["1"] = {
					{
						nodeId = 25,
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
			kind = 31,
			inputs = {
				audioEventVInput = "ui_photo_shutter"
			},
			flowIn = {
				Play = 0
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
						nodeId = 26,
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
			kind = 32,
			fields = {
				eventName = "showPhoto",
				eventParam = {
					[1] = "$UI_Img_ItemView_1001100.png",
					[2] = {
						1001100
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 28,
						portId = "In"
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
						nodeId = 29,
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
						nodeId = 32,
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
						nodeId = 31,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IntoBag",
				staticIdVInput = 2
			},
			fields = {
				isLooping = false,
				entityType = 0,
				templateId = 3,
				processingTime = 1,
				playAniType = 1
			},
			flowIn = {
				In = 0
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
						nodeId = 33,
						portId = "In"
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
						nodeId = 34,
						portId = "In"
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
						nodeId = 0,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 36,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 0,
				positionVInput = {
					-1737.737,
					101.8,
					784.721
				},
				rotationVInput = {
					355.69,
					220.5,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					nodeId = 50,
					portId = "BoneTransform"
				}
			},
			fields = {
				fStop = 4,
				cameraId = 91285036,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
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
						nodeId = 20,
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
			},
			flowOut = {
				Out = {
					{
						nodeId = 38,
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
						nodeId = 40,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 19,
						portId = "In"
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
						active = true,
						parameters = {
							m_GlitchSeed = {
								valueType = "vector3",
								overrideState = true,
								value = {
									y = 1.2,
									x = 1,
									z = 1.2
								}
							},
							m_GlitchStrength = {
								valueType = "float",
								value = 2,
								overrideState = true
							},
							m_GlitchSpeed = {
								valueType = "float",
								value = 12,
								overrideState = true
							},
							m_JitterSpeed = {
								valueType = "float",
								value = 2,
								overrideState = true
							},
							m_GlitchDirectionStrength = {
								valueType = "vector2",
								overrideState = true,
								value = {
									y = -0.25,
									x = 1
								}
							},
							m_GlitchBlockNum = {
								valueType = "vector4",
								overrideState = true,
								value = {
									y = 12,
									x = 8,
									w = 30,
									z = 11
								}
							},
							m_GlitchBlockClip = {
								valueType = "float",
								value = 0.7,
								overrideState = true
							},
							m_RGBSPlit = {
								valueType = "vector3",
								overrideState = true,
								value = {
									y = 0.1,
									x = 0,
									z = 0.2
								}
							},
							m_GhostFactor = {
								valueType = "float",
								value = 0.8,
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
								value = 0,
								overrideState = true
							}
						}
					}
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
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
			kind = 4,
			fields = {
				delayTime = 2.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 40,
						portId = "Stop"
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
						nodeId = 18,
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
						nodeId = 44,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 45,
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
			kind = 46,
			fields = {
				volumeComponentCount = 1,
				volumeComponents = {
					{
						typeName = "GlitchComponent",
						active = false,
						parameters = {
							m_GlitchSeed = {
								valueType = "vector3",
								overrideState = true,
								value = {
									y = 1,
									x = 1,
									z = 1
								}
							},
							m_GlitchStrength = {
								valueType = "float",
								value = 2,
								overrideState = true
							},
							m_GlitchSpeed = {
								valueType = "float",
								value = 12,
								overrideState = true
							},
							m_JitterSpeed = {
								valueType = "float",
								value = 1,
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
									y = 10,
									x = 10,
									w = 10,
									z = 10
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
									y = 0,
									x = -1,
									z = 1
								}
							},
							m_GhostFactor = {
								valueType = "float",
								value = 1,
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
								value = 1.2,
								overrideState = true
							}
						}
					}
				}
			},
			flowIn = {
				In = 0,
				Stop = 1
			},
			flowOut = {
				Out = {
					{
						nodeId = 46,
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
			},
			flowOut = {
				Out = {
					{
						nodeId = 45,
						portId = "Stop"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 20,
				fovVInput = 23,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1731.297,
					102.57,
					786.808
				},
				rotationVInput = {
					2.58,
					241.356,
					0.323
				}
			},
			fields = {
				fStop = 4,
				cameraId = 73722353,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[49] = {
			kind = 17,
			inputs = {
				staticIdVInput = 60994107
			},
			fields = {
				entityType = 2
			}
		},
		[50] = {
			kind = 17,
			inputs = {
				staticIdVInput = 60994107
			},
			fields = {
				entityType = 2
			}
		}
	}
}
