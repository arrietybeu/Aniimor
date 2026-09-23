-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79541412.lua

return {
	dialogueId = 79541412,
	schema = "v4",
	startNodeId = 1,
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
						nodeId = 2,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 18,
			inputs = {
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				applyStateConflictVInput = true,
				startSkipVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				clearEventInputVInput = true
			},
			fields = {
				topLogoComs = {
					multiPlayer = true,
					callFriends = true,
					petChat = true,
					combat = true,
					bubble = true,
					petFertility = true,
					npc = true,
					chat = true,
					alert = true
				}
			},
			flowIn = {
				In = true
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
			kind = 24,
			inputs = {
				switchToPlayerVInput = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
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
				In = true
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
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 26,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 25,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					181.795,
					0
				},
				targetPositionVInput = {
					-495.974,
					56.81,
					779.432
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 37,
					portId = "EntityID"
				}
			},
			fields = {
				setRotation = true,
				setPosition = true
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
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.5
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				delayTime = 0.5
			},
			flowIn = {
				In = true
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 40,
					portId = "EntityID"
				}
			},
			fields = {
				resetOrientation = true,
				reactPreset = 3,
				nodeMode = 1,
				enableGroupLookAt = true,
				cameraPreset = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FOut = {
					{
						nodeId = 12,
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
				In = true
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
			kind = 2,
			fields = {
				portCount = 4
			},
			flowIn = {
				In = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201182
			},
			fields = {
				skipTime = 3,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 8,
				chatType = 3,
				blackScreenPlayType = 1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 15,
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 16,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201183
			},
			fields = {
				blackScreenIntervalTime = 3,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 4,
				chatType = 7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 17,
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				},
				["2"] = {
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
				dialogueIdVInput = 6201187
			},
			fields = {
				npcId = 401059,
				duration = 9,
				chatType = 3,
				npcStaticId = 79673718
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201188
			},
			fields = {
				npcId = 401059,
				duration = 2,
				chatType = 3,
				npcStaticId = 79673718
			},
			flowIn = {
				In = true
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
			kind = 10,
			inputs = {
				endSkipVInput = true
			},
			flowIn = {
				In = true
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
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-497.165,
					59.281,
					776.968
				},
				rotationVInput = {
					6.464,
					213.106,
					0
				}
			},
			fields = {
				focalDistance = 180,
				cameraId = 85634951,
				fStop = 9.93,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 9,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.522,
					59.281,
					777.324
				},
				rotationVInput = {
					6.979,
					177.525,
					0
				}
			},
			fields = {
				focalDistance = 120,
				cameraId = 85429709,
				fStop = 9.94,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			},
			flowIn = {
				In = true
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
						nodeId = 24,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-497.594,
					59.332,
					777.494
				},
				rotationVInput = {
					5.261,
					202.62,
					0
				}
			},
			fields = {
				focalDistance = 200,
				cameraId = 83734517,
				fStop = 9.93,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.272,
					58.144,
					776.201
				},
				rotationVInput = {
					11.465,
					63.979,
					0
				}
			},
			fields = {
				focalDistance = 120,
				cameraId = 83777891,
				fStop = 5.42,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				staticIdVInput = 80375396,
				targetEulerAngleVInput = {
					0,
					180,
					0
				},
				targetPositionVInput = {
					-497.222,
					56.854,
					776.971
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 40,
					portId = "EntityID"
				}
			},
			fields = {
				finishToSteer = true,
				speedCurve = {
					preWrapMode = 8,
					postWrapMode = 8,
					keys = {
						{
							value = 0,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							time = 0
						},
						{
							value = 1,
							weightedMode = 0,
							outWeight = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							time = 1
						}
					}
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 80375396,
				playableStateVInput = "Daily_Smell_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 5
			},
			fields = {
				entityType = 2,
				templateId = 400204,
				processingTime = 2.4,
				playAniType = 1,
				aniStateList = {
					"Daily_Smell_Start",
					"Daily_Smell_Loop",
					"Daily_SmellEnd"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-497.991,
					58.323,
					779.679
				},
				rotationVInput = {
					11.121,
					141.328,
					0
				}
			},
			fields = {
				focalDistance = 200,
				cameraId = 83733567,
				fStop = 4,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Talk_Start",
				playStartLoopEndVInput = true,
				staticIdVInput = 80375309
			},
			fields = {
				entityType = 2,
				templateId = 401059,
				processingTime = 12.483,
				playAniType = 1,
				aniStateList = {
					"Story_Talk_Start",
					"Story_Talk_Loop",
					"Story_Talk_End"
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.544,
					58.057,
					777.708
				},
				rotationVInput = {
					357.558,
					203.685,
					0.002
				}
			},
			fields = {
				focalDistance = 100,
				cameraId = 85429697,
				fStop = 6.67,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 12
			},
			flowOut = {
				Out = {
					{
						nodeId = 32,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 6,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.544,
					58.057,
					777.708
				},
				rotationVInput = {
					356.354,
					186.84,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				cameraId = 85425010,
				fStop = 4,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 38,
			inputs = {
				maxLimitTimeVInput = 5,
				targetPositionVInput = {
					-497.222,
					56.854,
					776.971
				}
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-494.695,
					56.897,
					778.012
				}
			},
			fields = {
				entityId = -1348932551
			}
		},
		{
			kind = 20,
			inputs = {
				isFadeInVInput = true,
				durationVInput = 0,
				staticIdVInput = 80375396,
				isResetValueInput = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-497.06,
					56.854,
					777.14
				},
				rotationVInput = {
					0,
					240.342,
					0
				}
			},
			fields = {
				entityId = -1496434987
			}
		},
		{
			kind = 17
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 401059,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-499.12,
					56.884,
					776.37
				},
				rotationVInput = {
					0,
					24.431,
					0
				}
			},
			fields = {
				entityId = -207286955
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-497.306,
					56.848,
					776.997
				},
				rotationVInput = {
					0,
					210,
					0
				}
			},
			fields = {
				entityId = -1759779038
			}
		},
		{
			kind = 17,
			inputs = {
				staticIdVInput = 80375396
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201183
			},
			fields = {
				blackScreenIntervalTime = 3,
				npcStaticId = 79673718,
				npcId = 401059,
				duration = 4,
				chatType = 7
			}
		}
	}
}
