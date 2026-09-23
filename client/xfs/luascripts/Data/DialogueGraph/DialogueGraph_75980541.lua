-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_75980541.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 75980541,
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
				blockEventVInput = true,
				blockCameraZoomVInput = true,
				showHUDVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				enhanceAmbientIntensityVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true
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
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 5
			},
			flowIn = {
				In = true
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
			kind = 4,
			fields = {
				delayTime = 8
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
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					59.179,
					0.468,
					20.652
				},
				rotationVInput = {
					344.895,
					74.478,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					portId = "BoneTransform",
					nodeId = 11
				}
			},
			fields = {
				openDof = true,
				focalDistance = 3086,
				fStop = 4,
				cameraId = 76005254,
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
						nodeId = 7
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
						nodeId = 8
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					59.179,
					0.468,
					20.652
				},
				rotationVInput = {
					344.895,
					74.478,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					portId = "BoneTransform",
					nodeId = 12
				}
			},
			fields = {
				openDof = true,
				focalDistance = 1,
				fStop = 4,
				cameraId = 76007616,
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
						nodeId = 9
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
			}
		},
		{
			kind = 46,
			fields = {
				volumeComponentCount = 1,
				volumeParamInfoCount = 1,
				volumeComponents = {
					{
						active = false,
						typeName = "DiaphragmDepthOfFieldComponent",
						parameters = {
							m_FocalDistance = {
								value = 1,
								valueType = "float",
								overrideState = true
							},
							m_FStop = {
								value = 1,
								valueType = "float",
								overrideState = true
							},
							m_SensorWidth = {
								value = 24.576,
								valueType = "float",
								overrideState = true
							},
							m_SqueezeFactor = {
								value = 1,
								valueType = "float",
								overrideState = true
							},
							m_DepthBlurAmount = {
								value = 1,
								valueType = "float",
								overrideState = true
							},
							m_DepthBlurRadius = {
								value = 0,
								valueType = "float",
								overrideState = true
							},
							m_RecombineQuality = {
								value = 0,
								valueType = "int",
								overrideState = true
							},
							m_SmoothGather = {
								value = false,
								valueType = "bool",
								overrideState = false
							},
							m_VisualizeDOF = {
								value = false,
								valueType = "bool",
								overrideState = true
							}
						}
					}
				},
				volumeParamInfo = {
					{
						volumeTypeName = "DiaphragmDepthOfFieldComponent",
						params = {
							{
								name = "Focal Distance",
								paramIndex = 0
							}
						}
					}
				}
			},
			dynamicInputs = {
				"0"
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 75188143
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 75315139
			},
			fields = {
				entityType = 2
			}
		}
	}
}
