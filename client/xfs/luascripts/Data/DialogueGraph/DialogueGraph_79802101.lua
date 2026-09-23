-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79802101.lua

return {
	dialogueId = 79802101,
	schema = "v4",
	startNodeId = 2,
	nodes = {
		[0] = {
			kind = 6,
			flowIn = {
				End = true
			}
		},
		{
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
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 24,
			inputs = {
				switchToPetVInput = false,
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
			kind = 11,
			fields = {
				modeInfo = {
					blockEvent = true,
					modeType = 2,
					blockCameraZoom = true,
					hideTopLogo = true,
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = true,
					toplogoComList = {
						combat = true,
						chat = true,
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
						multiPlayer = true
					}
				}
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
				portCount = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 53,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 56,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					91.55,
					0
				},
				targetPositionVInput = {
					-488.449,
					56.897,
					773.709
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 63,
					portId = "EntityID"
				}
			},
			fields = {
				setRotation = true,
				setPosition = true
			},
			flowIn = {
				In = true
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
			kind = 5,
			inputs = {
				playableStateVInput = "Story_TakeItem"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400204,
				processingTime = 2.967,
				playAniType = 1
			},
			flowIn = {
				In = true
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
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400204,
				processingTime = 3,
				playAniType = 1
			},
			flowIn = {
				In = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304171
			},
			fields = {
				duration = 7.38,
				chatType = 3,
				npcId = 400204
			},
			flowIn = {
				In = true
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
				dialogueIdVInput = 3304278
			},
			fields = {
				duration = 2,
				chatType = 3,
				npcId = 400077
			},
			flowIn = {
				In = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304378
			},
			fields = {
				duration = 2,
				chatType = 3,
				npcId = 400204
			},
			flowIn = {
				In = true
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
				dialogueIdVInput = 3304379
			},
			fields = {
				duration = 2,
				chatType = 3,
				npcId = 400204
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
						nodeId = 15,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 48,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 49,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304172
			},
			fields = {
				duration = 5.12,
				chatType = 3,
				npcStaticId = -384626989,
				npcId = 400204
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304173
			},
			fields = {
				duration = 3.38,
				chatType = 3,
				npcStaticId = -384626989,
				npcId = 400204
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304019
			},
			fields = {
				duration = 9.88,
				chatType = 3,
				npcStaticId = 2,
				npcId = 0
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
				}
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 8
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
				},
				["1"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 45,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 46,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 47,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304174
			},
			fields = {
				duration = 4.62,
				chatType = 3,
				npcId = 400077
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
			kind = 2,
			fields = {
				portCount = 6
			},
			flowIn = {
				In = true
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
						nodeId = 39,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 42,
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
				dialogueIdVInput = 3304175
			},
			fields = {
				duration = 10.38,
				chatType = 3,
				npcId = 400204
			},
			flowIn = {
				In = true
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
			kind = 2,
			fields = {
				portCount = 7
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 36,
						portId = "In"
					}
				},
				["4"] = {
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
				dialogueIdVInput = 3304176
			},
			fields = {
				duration = 6.12,
				chatType = 3,
				npcStaticId = -1157077677,
				npcId = 400077
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				In = true
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 3304177
			},
			fields = {
				duration = 4.88,
				chatType = 3,
				portCount = 5,
				npcId = 400204
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 26,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 3304060
			},
			fields = {
				duration = 5.25,
				chatType = 3,
				portCount = 5,
				npcId = 400204
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 3304061
			},
			fields = {
				duration = 3,
				chatType = 3,
				portCount = 2,
				npcId = 400204
			},
			flowIn = {
				In = true
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
				In = true
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
						nodeId = 30,
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 31,
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
						nodeId = 32,
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
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 1,
						portId = "End"
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
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 21,
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					67.751,
					0
				},
				targetPositionVInput = {
					-488.688,
					56.897,
					773.271
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 64,
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
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					83.36,
					0
				},
				targetPositionVInput = {
					-488.755,
					56.897,
					774.053
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
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = -384626989,
				staticIdVInput = -1157077677
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-488.076,
					58.116,
					773.449
				},
				rotationVInput = {
					0,
					47.708,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16,
				cameraId = 91104271
			},
			flowIn = {
				In = true
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
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 4,
				positionVInput = {
					-488.036,
					58.116,
					773.411
				},
				rotationVInput = {
					0,
					46.039,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16,
				cameraId = 91104272
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					83.36,
					0
				},
				targetPositionVInput = {
					-488.648,
					56.897,
					773.978
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 64,
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
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Nod"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400204,
				processingTime = 1.433,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-487.615,
					58.121,
					772.938
				},
				rotationVInput = {
					0.634,
					298.162,
					0.158
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 150,
				fStop = 16,
				cameraId = 79903537
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 5,
				positionVInput = {
					-487.732,
					58.121,
					773.055
				},
				rotationVInput = {
					0.648,
					291.418,
					0.082
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 150,
				fStop = 16,
				cameraId = 90740505
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					83.36,
					0
				},
				targetPositionVInput = {
					-488.648,
					56.897,
					773.978
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 64,
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
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					68.244,
					0
				},
				targetPositionVInput = {
					-488.777,
					56.897,
					773.193
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
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
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Lefthand"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400077,
				processingTime = 2,
				playAniType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					120,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				},
				faceTransVInput = {
					nodeId = 63,
					portId = "BoneTransform"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-488.076,
					58.116,
					773.449
				},
				rotationVInput = {
					0,
					47.708,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16,
				cameraId = 84724350
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 50,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 4,
				positionVInput = {
					-488.036,
					58.116,
					773.411
				},
				rotationVInput = {
					0,
					46.039,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16,
				cameraId = 90740497
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 50,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-488.822,
					58.656,
					771.387
				},
				rotationVInput = {
					13.546,
					34.275,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200,
				fStop = 16,
				cameraId = 84724168
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 52,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 50,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 5,
				positionVInput = {
					-488.759,
					58.637,
					771.581
				},
				rotationVInput = {
					14.565,
					31.982,
					359.423
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 200,
				fStop = 4,
				cameraId = 81252742
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400204,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-487.34,
					56.897,
					773.906
				},
				rotationVInput = {
					0,
					192.09,
					0
				}
			},
			fields = {
				entityId = -384626989
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 55,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 63,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 53,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				slotParamVInput = 400077,
				virtualEntityTypeVInput = 2,
				positionVInput = {
					-488.699,
					56.897,
					773.165
				},
				rotationVInput = {
					0,
					87.449,
					0
				}
			},
			fields = {
				entityId = -1157077677
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 57,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				nodeMode = 1,
				enableDefaultLookAt = true,
				cameraPreset = 2,
				resetOrientation = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 54,
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
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-488.076,
					58.116,
					773.449
				},
				rotationVInput = {
					0,
					47.708,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16
			},
			flowOut = {
				Finish = {
					{
						nodeId = 60,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 4,
				positionVInput = {
					-488.036,
					58.116,
					773.411
				},
				rotationVInput = {
					0,
					46.039,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 85,
				fStop = 16
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				positionVInput = {
					-488.071,
					58.175,
					773.292
				},
				rotationVInput = {
					0,
					266.328,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 68,
				fStop = 16,
				cameraId = 84726560
			},
			flowOut = {
				Finish = {
					{
						nodeId = 62,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 45,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 2,
				blendTimeVInput = 3,
				positionVInput = {
					-488.072,
					58.175,
					773.332
				},
				rotationVInput = {
					0,
					265.253,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				sensorWidth = 230,
				openDof = true,
				focalDistance = 68,
				fStop = 16,
				cameraId = 90873675
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 17
		},
		{
			kind = 9
		}
	}
}
