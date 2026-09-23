-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90922136.lua

return {
	dialogueId = 90922136,
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
						nodeId = 3,
						portId = "In"
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
					alert = true,
					npc = true,
					vlog = true,
					teamSpeech = true,
					quest = true,
					photo = true,
					petFertility = true,
					petExchange = true,
					petChat = true,
					multiPlayer = true,
					combat = true,
					callFriends = true
				}
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
				portCount = 7
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
				},
				["1"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 52,
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
					54.122,
					0
				},
				targetPositionVInput = {
					34.31,
					100.394,
					872.312
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					100.946,
					0
				},
				targetPositionVInput = {
					37.22,
					100.406,
					875.41
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				reset = true,
				setRotation = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					272.713,
					0
				},
				targetPositionVInput = {
					40.95,
					100.304,
					875.27
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				reset = true,
				setRotation = true
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
				portCount = 2
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
				},
				["1"] = {
					{
						nodeId = 11,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Furious",
				duration = 999
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400800,
				processingTime = 2.5,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"IdleSpecial",
					"IdleSpecial",
					"IdleSpecial"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				positionVInput = {
					35.798,
					101.589,
					874.036
				},
				rotationVInput = {
					12.198,
					63.805,
					359.304
				}
			},
			fields = {
				cameraId = 90965758,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
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
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				blendTimeVInput = 2,
				fovVInput = 45,
				positionVInput = {
					35.415,
					101.482,
					873.875
				},
				rotationVInput = {
					11.812,
					63.906,
					359.346
				}
			},
			fields = {
				cameraId = 90965759,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
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
				portCount = 6
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
				},
				["3"] = {
					{
						nodeId = 50,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 47,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709082
			},
			fields = {
				chatType = 3,
				duration = 3
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
						nodeId = 17,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 44,
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
				["4"] = {
					{
						nodeId = 47,
						portId = "StopLip"
					}
				},
				["5"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709083
			},
			fields = {
				chatType = 3,
				duration = 3
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
				portCount = 6
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
						nodeId = 41,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 43,
						portId = "StopLip"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709084
			},
			fields = {
				chatType = 3,
				duration = 2
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
				portCount = 8
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
						nodeId = 36,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 37,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 40,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709085
			},
			fields = {
				chatType = 3,
				duration = 8
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
				portCount = 8
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
				["1"] = {
					{
						nodeId = 32,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 30,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 31,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 33,
						portId = "StopLip"
					}
				},
				["7"] = {
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
				dialogueIdVInput = 6709086
			},
			fields = {
				chatType = 3,
				duration = 6
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
			kind = 22,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 25,
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
						nodeId = 26,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 28,
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
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 21,
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
						nodeId = 29,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
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
					nodeId = 57,
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
					nodeId = 61,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				positionVInput = {
					35.479,
					101.017,
					874.717
				},
				rotationVInput = {
					353.388,
					82.212,
					359.763
				}
			},
			fields = {
				cameraId = 90966081,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Excited"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = true,
				StopLip = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				templateId = 4,
				aniStateList = {
					"Story_Akimbo01_Start",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_End"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400077,
				aniStateList = {
					"Story_Akimbo01_Start",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_End"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				positionVInput = {
					39.074,
					101.114,
					875.109
				},
				rotationVInput = {
					353.766,
					262.039,
					358.993
				}
			},
			fields = {
				cameraId = 90965742,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 57,
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
					nodeId = 56,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
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
					70,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
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
					75,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				positionVInput = {
					39.958,
					100.834,
					875.146
				},
				rotationVInput = {
					14.649,
					83.868,
					0
				}
			},
			fields = {
				cameraId = 90965490,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				blendTimeVInput = 3,
				fovVInput = 45,
				positionVInput = {
					39.958,
					100.834,
					875.146
				},
				rotationVInput = {
					14.649,
					83.868,
					0
				}
			},
			fields = {
				cameraId = 90965503,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 33,
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayLip = true
			},
			flowIn = {
				In = true,
				StopLip = true
			}
		},
		{
			kind = 26,
			inputs = {
				targetEulerAngleVInput = {
					0,
					153,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
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
					nodeId = 56,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 61,
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
					nodeId = 61,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Confused"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayLip = true,
				activePlayEmotion = true
			},
			flowIn = {
				In = true,
				StopLip = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 30,
				positionVInput = {
					42.128,
					100.56,
					874.636
				},
				rotationVInput = {
					353.92,
					283.951,
					359.987
				}
			},
			fields = {
				cameraId = 90965504,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 10,
				targetEulerAngleVInput = {
					0,
					60,
					0
				},
				targetPositionVInput = {
					37.436,
					100.448,
					874.375
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 61,
					portId = "EntityID"
				}
			},
			fields = {
				reset = true,
				finishToSteer = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							value = 0,
							inTangent = 0,
							time = 0,
							outTangent = 1,
							weightedMode = 0,
							outWeight = 0
						},
						{
							inWeight = 0,
							value = 1,
							inTangent = 1,
							time = 1,
							outTangent = 0,
							weightedMode = 0,
							outWeight = 0
						}
					}
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
					nodeId = 56,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 57,
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
					nodeId = 61,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
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
						nodeId = 53,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Tease_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 56,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400077,
				aniStateList = {
					"Story_Tease_Start",
					"Story_Tease_Loop",
					"Story_Tease_End"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				positionVInput = {
					36.151,
					101.906,
					871.844
				},
				rotationVInput = {
					11.039,
					37.01,
					0
				}
			},
			fields = {
				cameraId = 90965744,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200,
				fStop = 4
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90948935
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 90948943
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 57,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400800,
				processingTime = 2.5
			}
		},
		{
			kind = 41,
			fields = {
				portCount = 3
			}
		},
		{
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 59,
					portId = "EntityIDs"
				}
			},
			fields = {
				resetOrientation = true,
				nodeMode = 1,
				enableGroupLookAt = true,
				enableDefaultLookAt = true
			}
		},
		{
			kind = 9
		}
	}
}
