-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_79541728.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 79541728,
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
						nodeId = 3,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 58,
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 18,
			inputs = {
				blockEventVInput = true,
				applyStateConflictVInput = true,
				startSkipVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true,
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true
			},
			fields = {
				topLogoComs = {
					alert = true,
					petExchange = true,
					multiPlayer = true,
					callFriends = true,
					petChat = true,
					combat = true,
					bubble = true,
					petFertility = true,
					npc = true,
					chat = true
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
						nodeId = 6,
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
						nodeId = 24,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 7,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 15,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 19,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 108,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 109,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 401059,
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
				entityId = -34832840
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				loopDurationVInput = 90,
				playableStateVInput = "Behav_DoubtStart",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 401059,
				processingTime = 1.083,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 9.683,
				playAniType = 1,
				entityType = 2,
				templateId = 401059
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_HappyStart",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 401059,
				processingTime = 1.083,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Behav_HappyStart",
					"Behav_HappyLoop",
					"Behav_HappyEnd"
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_Happy",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 7,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 401059,
				processingTime = 1.083,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Behav_Happy",
					"Behav_Happy",
					"Behav_Happy"
				}
			}
		},
		{
			kind = 15,
			inputs = {
				staticIdVInput = 2
			},
			valueIn = {
				lookAtEntityIdVInput = {
					nodeId = 7,
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
					nodeId = 20,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 7,
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
					nodeId = 15,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 7,
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
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400204,
				positionVInput = {
					-497.308,
					56.85,
					777
				},
				rotationVInput = {
					0,
					210,
					0
				}
			},
			fields = {
				entityId = -1081141270
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Cheeksupport"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 4.9,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Serious"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayEmotion = true,
				activePlayLip = true
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Deny"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 3,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.892,
					59.27,
					780.668
				},
				rotationVInput = {
					18.184,
					161.401,
					0.003
				}
			},
			fields = {
				fStop = 6.01,
				cameraId = 84045289,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 228
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-497.25,
					56.818,
					777.93
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -1450504535
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Shrug_Start",
				playStartLoopEndVInput = true
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 20,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 5.2,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Talk_Shrug_Start",
					"Talk_Shrug_Loop",
					"Talk_Shrug_End"
				}
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Crossingarms"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 20,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 5.2,
				playAniType = 1,
				entityType = 2,
				templateId = 400204
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 33,
			inputs = {
				facialEmotionVInput = "Serious"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 20,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayEmotion = true,
				activePlayLip = true
			},
			flowIn = {
				In = true,
				StopLip = true
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
						nodeId = 25,
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
						nodeId = 26,
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
						nodeId = 27,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 14,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 107,
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
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 13,
			fields = {
				enableGroupLookAt = true,
				resetOrientation = true,
				reactPreset = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FOut = {
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
				dialogueIdVInput = 6201224
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 6201225,
				lookAtIdVInput = 401059
			},
			fields = {
				portCount = 2,
				npcStaticId = 79229264,
				npcId = 400180,
				duration = 7,
				chatType = 3
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6201226
			},
			fields = {
				portCount = 2,
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
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
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201227
			},
			flowIn = {
				In = true
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
						nodeId = 34,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201229
			},
			fields = {
				npcStaticId = 2,
				npcId = 401059,
				duration = 6,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
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
				["0"] = true,
				["1"] = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 36,
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
						nodeId = 37,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 103,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 8,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201231
			},
			fields = {
				npcStaticId = 2,
				npcId = 401059,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201232
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 8,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 39,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201233
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 12,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6201234
			},
			fields = {
				portCount = 2,
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 8,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 99,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201235
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 42,
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
						nodeId = 44,
						portId = "In"
					}
				},
				["1"] = {
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
				blendTimeVInput = 15.2,
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-499.162,
					59.171,
					777.121
				},
				rotationVInput = {
					356.87,
					173.26,
					0.003
				}
			},
			fields = {
				fStop = 31.99,
				cameraId = 84058503,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 100
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201237
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 10,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 45,
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
				["0"] = true,
				["1"] = true
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201239
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 12,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 6201240
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 11,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 48,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201241
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
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
				dialogueIdVInput = 6201242
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 12,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 50,
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
						nodeId = 51,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 98,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 21,
						portId = "In"
					}
				},
				["3"] = {
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
				dialogueIdVInput = 6201243
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400180,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 52,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201244,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400180,
				duration = 11,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 53,
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
						nodeId = 55,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-497.817,
					58.411,
					780.363
				},
				rotationVInput = {
					359.62,
					186.152,
					0.003
				}
			},
			fields = {
				fStop = 8.68,
				cameraId = 84051395,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201245
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 6,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 56,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201246
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 11,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 57,
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
						nodeId = 59,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 58,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.92,
					58.331,
					776.644
				},
				rotationVInput = {
					13.715,
					58.613,
					0.004
				}
			},
			fields = {
				fStop = 8.35,
				cameraId = 84051713,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201247,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400180,
				duration = 8,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 60,
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
						nodeId = 62,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.473,
					58.649,
					779.158
				},
				rotationVInput = {
					3.23,
					180.308,
					0.003
				}
			},
			fields = {
				fStop = 7.34,
				cameraId = 84051806,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201248
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 8,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 63,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201249
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 2,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 64,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201250
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 6,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201251,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 0,
				duration = 4,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 66,
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
						nodeId = 68,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 67,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-499.348,
					59.108,
					778.108
				},
				rotationVInput = {
					359.792,
					180.136,
					0.003
				}
			},
			fields = {
				fStop = 6.42,
				cameraId = 84051988,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201252
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 10,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 69,
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
						nodeId = 70,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 97,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 17,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 23,
						portId = "StopLip"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201253
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 10,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 71,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201254,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 10,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 72,
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
						nodeId = 74,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 73,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-499.348,
					59.108,
					778.108
				},
				rotationVInput = {
					359.792,
					180.136,
					0.003
				}
			},
			fields = {
				fStop = 6.42,
				cameraId = 90859010,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				defaultSkipBranchVInput = 1,
				dialogueIdVInput = 6201255
			},
			fields = {
				portCount = 2,
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 4,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 75,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201256
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 76,
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
				["0"] = true,
				["1"] = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 77,
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
						nodeId = 78,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 95,
						portId = "In"
					}
				},
				["2"] = {
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
				dialogueIdVInput = 6201258,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 6,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 79,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201259,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 11,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 80,
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
						nodeId = 81,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 94,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201260
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 2,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 82,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201261
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 7,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201262
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 12,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 84,
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
						nodeId = 86,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 85,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-496.58,
					59.461,
					782.649
				},
				rotationVInput = {
					10.277,
					188.044,
					0.004
				}
			},
			fields = {
				fStop = 8.6,
				cameraId = 84054320,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 280
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201264,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 0,
				duration = 3,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 87,
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
						nodeId = 88,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201265,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 400180,
				duration = 4,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 89,
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
						nodeId = 90,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 91,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201263
			},
			fields = {
				skipTime = 3,
				npcStaticId = 79229255,
				npcId = 400204,
				duration = 4,
				chatType = 7
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
					146.3,
					0
				},
				targetPositionVInput = {
					-517,
					49,
					696
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 126,
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
						nodeId = 92,
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
						nodeId = 93,
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
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-499.348,
					59.108,
					778.108
				},
				rotationVInput = {
					359.792,
					180.136,
					0.003
				}
			},
			fields = {
				fStop = 6.42,
				cameraId = 90859008,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-499.137,
					58.389,
					776.548
				},
				rotationVInput = {
					11.137,
					67.379,
					0.004
				}
			},
			fields = {
				fStop = 6.92,
				cameraId = 84052603,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201257
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 76,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.102,
					58.121,
					776.396
				},
				rotationVInput = {
					9.418,
					58.612,
					0.003
				}
			},
			fields = {
				fStop = 6.17,
				cameraId = 85461047,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 100
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.074,
					58.203,
					777.007
				},
				rotationVInput = {
					12.684,
					45.205,
					0.003
				}
			},
			fields = {
				fStop = 14.24,
				cameraId = 84049622,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201236
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 100,
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
						nodeId = 102,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 101,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15.2,
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-499.162,
					59.171,
					777.121
				},
				rotationVInput = {
					356.87,
					173.26,
					0.003
				}
			},
			fields = {
				fStop = 32,
				cameraId = 90859013,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 100
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201238
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 8,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 45,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 12.1,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-499.4,
					59.127,
					778.25
				},
				rotationVInput = {
					2.714,
					178.245,
					0.003
				}
			},
			fields = {
				fStop = 18.96,
				cameraId = 85454900,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 180
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6201228
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 105,
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
						nodeId = 106,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201230
			},
			fields = {
				npcStaticId = 79229255,
				npcId = 401059,
				duration = 6,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
						portId = "1"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 7.9,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-499.525,
					59.27,
					780.398
				},
				rotationVInput = {
					17.497,
					156.932,
					0.003
				}
			},
			fields = {
				fStop = 6.01,
				cameraId = 85454175,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 228
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400066,
				positionVInput = {
					-496.602,
					56.858,
					777.705
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -464087137
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
					201.378,
					0
				},
				targetPositionVInput = {
					-498.114,
					56.806,
					777.584
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 125,
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
			kind = 12,
			flowOut = {
				Out = {
					{
						nodeId = 111,
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
						nodeId = 112,
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
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400066,
				positionVInput = {
					-496.79,
					56.841,
					777.764
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -2104508128
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 15.5,
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.533,
					58.479,
					777.305
				},
				rotationVInput = {
					11.652,
					203.514,
					0.004
				}
			},
			fields = {
				fStop = 25.8,
				cameraId = 84049617,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 80
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.393,
					58.643,
					778.302
				},
				rotationVInput = {
					15.778,
					198.014,
					0.004
				}
			},
			fields = {
				fStop = 5.17,
				cameraId = 84052013,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.348,
					58.471,
					778.413
				},
				rotationVInput = {
					13.371,
					180.996,
					0.003
				}
			},
			fields = {
				fStop = 4,
				cameraId = 84052741,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.592,
					58.393,
					779.226
				},
				rotationVInput = {
					356.526,
					181.855,
					0.003
				}
			},
			fields = {
				fStop = 4,
				cameraId = 85454889,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-498.592,
					58.393,
					779.226
				},
				rotationVInput = {
					356.526,
					181.855,
					0.003
				}
			},
			fields = {
				fStop = 4,
				cameraId = 84045290,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 10.5,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-498.61,
					58.362,
					778.086
				},
				rotationVInput = {
					9.246,
					186.668,
					0.003
				}
			},
			fields = {
				fStop = 8.01,
				cameraId = 85457192,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 130
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-497.544,
					56.804,
					778.037
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -1142796910
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-497.952,
					56.81,
					778.839
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -1663507594
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400180,
				positionVInput = {
					-496.948,
					56.824,
					780.043
				},
				rotationVInput = {
					0,
					199.913,
					0
				}
			},
			fields = {
				entityId = -697703590
			}
		},
		{
			kind = 14,
			inputs = {
				targetPositionVInput = {
					-512.51,
					50.28,
					689.86
				}
			},
			fields = {
				setPosition = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2
			},
			fields = {
				entityId = -1968405968
			}
		},
		{
			kind = 17
		},
		{
			kind = 17
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 45,
				blendFuncVInput = "EaseInOut",
				positionVInput = {
					-499.231,
					59.163,
					777.113
				},
				rotationVInput = {
					356.87,
					173.26,
					0.003
				}
			},
			fields = {
				fStop = 6.42,
				cameraId = 90859012,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 200
			}
		},
		{
			kind = 59,
			fields = {
				animationCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1.00235,
							time = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.007076263,
							time = 1.000829,
							inWeight = 0,
							outTangent = -2.937509,
							inTangent = -2.937509
						}
					}
				}
			}
		},
		{
			kind = 46,
			fields = {
				volumeComponentCount = 1,
				volumeParamInfoCount = 1,
				volumeComponents = {
					{
						active = true,
						typeName = "VignetteComponent",
						parameters = {
							m_VignetteColor = {
								overrideState = true,
								valueType = "color",
								value = {
									g = 34.29675,
									a = 1,
									b = 34.29675,
									r = 34.29675
								}
							},
							m_EdgeWidth = {
								overrideState = true,
								value = 0.763,
								valueType = "float"
							},
							m_EdgeSoftness = {
								overrideState = true,
								value = 0.35,
								valueType = "float"
							},
							m_VignetteAlpha = {
								overrideState = true,
								value = 1,
								valueType = "float"
							},
							m_FisheyeFovDeg = {
								overrideState = false,
								value = 0,
								valueType = "float"
							},
							m_FollowAspect = {
								overrideState = false,
								value = true,
								valueType = "bool"
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
			}
		},
		{
			kind = 12
		},
		{
			kind = 59,
			fields = {
				animationCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1.999939,
							time = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.4325165,
							time = 2.746019,
							inWeight = 0,
							outTangent = 0.1174946,
							inTangent = 0.1174946
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.8506042,
							time = 4.47884,
							inWeight = 0,
							outTangent = -0.01289218,
							inTangent = -0.01289218
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.2488505,
							time = 6.482499,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.5957549,
							time = 7.758335,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.3635166,
							time = 8.973153,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.8042349,
							time = 10.554,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.1795261,
							time = 12.97342,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.28123,
							time = 13.55958,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.06354927,
							time = 14.39524,
							inWeight = 0,
							outTangent = -0.3442466,
							inTangent = -0.3442466
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.0002282123,
							time = 15.00103,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						}
					}
				}
			}
		},
		{
			kind = 46,
			valueIn = {
				["1"] = {
					nodeId = 131,
					portId = "animationCurveVOutput"
				}
			},
			fields = {
				volumeComponentCount = 1,
				volumeParamInfoCount = 1,
				volumeComponents = {
					{
						active = true,
						typeName = "VignetteComponent",
						parameters = {
							m_VignetteColor = {
								overrideState = true,
								valueType = "color",
								value = {
									g = 0,
									a = 1,
									b = 0,
									r = 0
								}
							},
							m_EdgeWidth = {
								overrideState = true,
								value = 2,
								valueType = "float"
							},
							m_EdgeSoftness = {
								overrideState = true,
								value = 0.75,
								valueType = "float"
							},
							m_VignetteAlpha = {
								overrideState = true,
								value = 1,
								valueType = "float"
							},
							m_FisheyeFovDeg = {
								overrideState = false,
								value = 0,
								valueType = "float"
							},
							m_FollowAspect = {
								overrideState = false,
								value = true,
								valueType = "bool"
							}
						}
					}
				},
				volumeParamInfo = {
					{
						volumeTypeName = "VignetteComponent",
						params = {
							{
								paramIndex = 1,
								name = "宽度"
							}
						}
					}
				}
			},
			dynamicInputs = {
				"1"
			}
		},
		{
			kind = 59,
			fields = {
				animationCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							outWeight = 0,
							weightedMode = 0,
							value = 1.999939,
							time = 0,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.4325165,
							time = 2.746019,
							inWeight = 0,
							outTangent = 0.1174946,
							inTangent = 0.1174946
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.8506042,
							time = 4.47884,
							inWeight = 0,
							outTangent = -0.01289218,
							inTangent = -0.01289218
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.2488505,
							time = 6.482499,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.5957549,
							time = 7.758335,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.3635166,
							time = 8.973153,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.8042349,
							time = 10.554,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.1795261,
							time = 12.97342,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.28123,
							time = 13.55958,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.06354927,
							time = 14.39524,
							inWeight = 0,
							outTangent = -0.3442466,
							inTangent = -0.3442466
						},
						{
							outWeight = 0,
							weightedMode = 0,
							value = 0.0002282123,
							time = 15.00103,
							inWeight = 0,
							outTangent = 0,
							inTangent = 0
						}
					}
				}
			}
		}
	}
}
