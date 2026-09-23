-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_73158708.lua

return {
	dialogueId = 73158708,
	schema = 1,
	startNodeId = 1,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 1
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
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 34,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 23
				}
			},
			flowIn = {
				In = 0
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
			kind = 34,
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 24
				}
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
						portId = "In",
						nodeId = 15
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				durationVInput = 0,
				isResetValueInput = true
			},
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 25
				}
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
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 401002,
				positionVInput = {
					-676.85,
					108.62,
					1534.75
				},
				rotationVInput = {
					0,
					150,
					0
				}
			},
			fields = {
				entityId = -2068890611,
				ignoreGravity = false
			},
			flowIn = {
				In = 0
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
			kind = 23,
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
			kind = 3,
			inputs = {
				fovVInput = 50
			},
			valueIn = {
				positionVInput = {
					portId = "Value",
					nodeId = 26
				},
				rotationVInput = {
					portId = "Value",
					nodeId = 27
				}
			},
			fields = {
				fStop = 4,
				cameraId = 73159038,
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
						portId = "In",
						nodeId = 10
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 7
				},
				targetEulerAngleVInput = {
					portId = "Value",
					nodeId = 28
				},
				targetPositionVInput = {
					portId = "Value",
					nodeId = 29
				}
			},
			fields = {
				finishToSteer = false,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							value = 0,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 1,
							outTangent = 0,
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
						nodeId = 20
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 11
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 10
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "2",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 3
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0,
				["2"] = 0
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
						portId = "In",
						nodeId = 14
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
						nodeId = 15
					}
				}
			}
		},
		{
			kind = 36,
			inputs = {
				retValueInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				fOutInput = {
					{
						portId = "In",
						nodeId = 16
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				isFadeInVInput = true,
				durationVInput = 0
			},
			valueIn = {
				staticIdVInput = {
					portId = "Value",
					nodeId = 32
				}
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
			kind = 10,
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
			kind = 21,
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
			kind = 23,
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
			kind = 36,
			inputs = {
				retValueInput = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				fOutInput = {
					{
						portId = "In",
						nodeId = 21
					}
				}
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2
			},
			valueIn = {
				entityIdVInput = {
					portId = "EntityID",
					nodeId = 7
				},
				targetEulerAngleVInput = {
					portId = "Value",
					nodeId = 30
				},
				targetPositionVInput = {
					portId = "Value",
					nodeId = 31
				}
			},
			fields = {
				finishToSteer = true,
				reset = false,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							value = 0,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 0,
							outTangent = 1,
							inTangent = 0
						},
						{
							value = 1,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 1,
							outTangent = 0,
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
						portId = "1",
						nodeId = 12
					}
				},
				Out = {
					{
						portId = "In",
						nodeId = 22
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "0",
						nodeId = 12
					}
				}
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "savehelmon"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "askhelphelmon"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "savehelmon"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "CameraPos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "CameraRot"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "FirstRot"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "FirstPos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "SecondRot"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "SecondPos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "savehelmon"
			}
		}
	},
	blackboard = {
		Scene = 3000,
		askhelphelmon = 0,
		savehelmon = 0,
		CameraPos = {
			0,
			0,
			0
		},
		CameraRot = {
			0,
			0,
			0
		},
		FirstPos = {
			0,
			0,
			0
		},
		FirstRot = {
			0,
			0,
			0
		},
		SecondPos = {
			0,
			0,
			0
		},
		SecondRot = {
			0,
			0,
			0
		}
	}
}
