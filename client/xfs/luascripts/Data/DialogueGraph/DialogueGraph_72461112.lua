-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_72461112.lua

return {
	startNodeId = 1,
	dialogueId = 72461112,
	schema = 1,
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
						nodeId = 2,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 34,
			valueIn = {
				staticIdVInput = {
					nodeId = 17,
					portId = "Value"
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
					blockCameraZoom = true,
					hideTopLogo = true,
					hideMarkShare = true,
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
					toplogoComList = {
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
						chat = true,
						callFriends = true,
						bubble = true
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				OnSkipStart = {
					{
						nodeId = 11,
						portId = "In"
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
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 401002
			},
			valueIn = {
				positionVInput = {
					nodeId = 18,
					portId = "Value"
				},
				rotationVInput = {
					nodeId = 19,
					portId = "Value"
				}
			},
			fields = {
				ignoreGravity = false,
				entityId = -1304919010
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 15,
						portId = "In"
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
					nodeId = 5,
					portId = "EntityID"
				},
				targetEulerAngleVInput = {
					nodeId = 23,
					portId = "Value"
				},
				targetPositionVInput = {
					nodeId = 22,
					portId = "Value"
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
							inWeight = 0,
							time = 0,
							inTangent = 0,
							outTangent = 1,
							outWeight = 0,
							weightedMode = 0,
							value = 0
						},
						{
							inWeight = 0,
							time = 1,
							inTangent = 1,
							outTangent = 0,
							outWeight = 0,
							weightedMode = 0,
							value = 1
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
						nodeId = 8,
						portId = "1"
					}
				},
				Out = {
					{
						nodeId = 7,
						portId = "In"
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
						nodeId = 8,
						portId = "0"
					}
				}
			}
		},
		{
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["0"] = 0,
				["1"] = 0
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
				blendVInput = 0.5
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
						nodeId = 11,
						portId = "In"
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
						nodeId = 12,
						portId = "In"
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
					nodeId = 24,
					portId = "Value"
				}
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
			kind = 23,
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
			kind = 23,
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
			kind = 3,
			inputs = {
				fovVInput = 60
			},
			valueIn = {
				positionVInput = {
					nodeId = 20,
					portId = "Value"
				},
				rotationVInput = {
					nodeId = 21,
					portId = "Value"
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 72461278,
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
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "BeSavedID"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "StartPos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "StartRot"
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
				variableName = "TargetPos"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "TargetRot"
			}
		},
		{
			kind = 44,
			fields = {
				variableName = "BeSavedID"
			}
		}
	},
	blackboard = {
		BeSavedID = 0,
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
		PlayerPos = {
			0,
			0,
			0
		},
		PlayerRot = {
			0,
			0,
			0
		},
		StartPos = {
			0,
			0,
			0
		},
		StartRot = {
			0,
			0,
			0
		},
		TargetPos = {
			0,
			0,
			0
		},
		TargetRot = {
			0,
			0,
			0
		}
	}
}
