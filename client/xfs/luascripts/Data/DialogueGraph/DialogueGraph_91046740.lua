-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91046740.lua

return {
	startNodeId = 1,
	dialogueId = 91046740,
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
						nodeId = 3,
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
						nodeId = 4,
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
					hideInteractionSign = false,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					applyStateConflict = true,
					pauseNearbyMonsterAI = true,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					hideUIWhiteList = {
						[121] = true
					},
					toplogoComList = {
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
						multiPlayer = true,
						combat = true
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
				In = 0
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 14,
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
						nodeId = 9,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 11,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 12,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 109,
						portId = "In"
					}
				},
				["6"] = {
					{
						nodeId = 110,
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
				ignoreGravity = false,
				entityId = -964740233
			},
			flowIn = {
				In = 0
			}
		},
		[9] = {
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
				ignoreGravity = false,
				entityId = -904020802
			},
			flowIn = {
				In = 0
			}
		},
		[10] = {
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Deny",
				animationLayerVInput = 4
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 9,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400204,
				processingTime = 3,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		[11] = {
			kind = 3,
			inputs = {
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
				focalDistance = 228,
				fStop = 6.01,
				cameraId = 91071651,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[12] = {
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
				ignoreGravity = false,
				entityId = -1557538153
			},
			flowIn = {
				In = 0
			}
		},
		[13] = {
			kind = 33,
			inputs = {
				facialEmotionVInput = "Serious"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 12,
					portId = "EntityID"
				}
			},
			fields = {
				activePlayEmotion = true,
				noBlink = false,
				activePlayLip = true
			},
			flowIn = {
				In = 0,
				StopLip = 1
			}
		},
		[14] = {
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
						nodeId = 15,
						portId = "In"
					}
				}
			}
		},
		[15] = {
			kind = 2,
			fields = {
				portCount = 5
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
				},
				["1"] = {
					{
						nodeId = 21,
						portId = "In"
					}
				}
			}
		},
		[16] = {
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
						nodeId = 17,
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
						nodeId = 19,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		[17] = {
			kind = 15,
			inputs = {
				staticIdVInput = -904020802,
				lookAtEntityStaticIdVInput = -964740233
			},
			flowIn = {
				In = 0
			}
		},
		[18] = {
			kind = 15,
			inputs = {
				staticIdVInput = -1557538153,
				lookAtEntityStaticIdVInput = -964740233
			},
			flowIn = {
				In = 0
			}
		},
		[19] = {
			kind = 15,
			inputs = {
				staticIdVInput = 2,
				lookAtEntityStaticIdVInput = -964740233
			},
			flowIn = {
				In = 0
			}
		},
		[20] = {
			kind = 15,
			inputs = {
				staticIdVInput = -395114539,
				lookAtEntityStaticIdVInput = -964740233
			},
			flowIn = {
				In = 0
			}
		},
		[21] = {
			kind = 23,
			inputs = {
				blendOutTimeVInput = 0.8
			},
			flowIn = {
				In = 0
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
		[22] = {
			kind = 2,
			fields = {
				portCount = 5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 23,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 108,
						portId = "In"
					}
				}
			}
		},
		[23] = {
			kind = 4,
			fields = {
				delayTime = 0.5
			},
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
		[24] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201224
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[25] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201225,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = 79229264,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 5.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[26] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201226,
				defaultSkipBranchVInput = 1
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
						nodeId = 105,
						portId = "In"
					}
				}
			}
		},
		[27] = {
			kind = 7,
			fields = {
				dialogueId = 6201227
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
		[28] = {
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
						nodeId = 29,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 102,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		[29] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201229
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 5.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 30,
						portId = "0"
					}
				}
			}
		},
		[30] = {
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
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
		[31] = {
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
				}
			}
		},
		[32] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201231
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 6.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		[33] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201232
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 7.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[34] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201233
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 11.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		[35] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201234,
				defaultSkipBranchVInput = 1
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 7.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 36,
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
		[36] = {
			kind = 7,
			fields = {
				dialogueId = 6201235
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		[37] = {
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
						nodeId = 38,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 98,
						portId = "In"
					}
				}
			}
		},
		[38] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201237
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 9.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 39,
						portId = "0"
					}
				}
			}
		},
		[39] = {
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 40,
						portId = "In"
					}
				}
			}
		},
		[40] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201239
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 10.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		[41] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201240
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 10.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 42,
						portId = "In"
					}
				}
			}
		},
		[42] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201241
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 6.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 43,
						portId = "In"
					}
				}
			}
		},
		[43] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201242
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 10.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
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
				}
			}
		},
		[44] = {
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
						nodeId = 45,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 97,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 13,
						portId = "In"
					}
				}
			}
		},
		[45] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201243
			},
			fields = {
				npcStaticId = -1557538153,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 6.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		[46] = {
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
						nodeId = 95,
						portId = "In"
					}
				}
			}
		},
		[47] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201244,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -1557538153,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 10,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[48] = {
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
						nodeId = 49,
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
		[49] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201245
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 5.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[50] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201246
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 10.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		[51] = {
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
						nodeId = 52,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 93,
						portId = "In"
					}
				}
			}
		},
		[52] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201247,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -1557538153,
				npcId = 400180,
				matchAudioDuration = true,
				duration = 7.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[53] = {
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
		[54] = {
			kind = 3,
			inputs = {
				fovVInput = 30,
				positionVInput = {
					-500.677,
					59.719,
					776.409
				},
				rotationVInput = {
					27.283,
					79.773,
					359.528
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 14.24,
				cameraId = 91346347,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 21,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[55] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201248
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[56] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201249
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 5.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[57] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201250
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 5.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 58,
						portId = "In"
					}
				}
			}
		},
		[58] = {
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
						nodeId = 59,
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
		[59] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201251,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[60] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201252
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 9.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 61,
						portId = "In"
					}
				}
			}
		},
		[61] = {
			kind = 2,
			fields = {
				portCount = 5
			},
			flowIn = {
				In = 0
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
						nodeId = 10,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 88,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 90,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 13,
						portId = "StopLip"
					}
				}
			}
		},
		[62] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201253,
				lookAtIdVInput = 400159
			},
			fields = {
				npcStaticId = -904020802,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 8.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[63] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201254,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -904020802,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 9.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[64] = {
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
						nodeId = 66,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 65,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 86,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 87,
						portId = "In"
					}
				}
			}
		},
		[65] = {
			kind = 3,
			inputs = {
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
				focalDistance = 200,
				fStop = 6.42,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[66] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201255,
				defaultSkipBranchVInput = 1
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 2.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 67,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 85,
						portId = "In"
					}
				}
			}
		},
		[67] = {
			kind = 7,
			fields = {
				dialogueId = 6201256
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 68,
						portId = "0"
					}
				}
			}
		},
		[68] = {
			kind = 30,
			fields = {
				portCount = 2
			},
			flowIn = {
				["1"] = 0,
				["0"] = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 69,
						portId = "In"
					}
				}
			}
		},
		[69] = {
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
						nodeId = 70,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 81,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 84,
						portId = "In"
					}
				}
			}
		},
		[70] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201258,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -904020802,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 4.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[71] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201259,
				lookAtIdVInput = 401059
			},
			fields = {
				npcStaticId = -904020802,
				npcId = 400204,
				matchAudioDuration = true,
				duration = 9.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
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
		[72] = {
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
						nodeId = 73,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 79,
						portId = "In"
					}
				}
			}
		},
		[73] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201260
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 74,
						portId = "In"
					}
				}
			}
		},
		[74] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201261
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 5.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 75,
						portId = "In"
					}
				}
			}
		},
		[75] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201262
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 76,
						portId = "In"
					}
				}
			}
		},
		[76] = {
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
						nodeId = 77,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 78,
						portId = "In"
					}
				}
			}
		},
		[77] = {
			kind = 12,
			flowIn = {
				In = 0
			}
		},
		[78] = {
			kind = 20,
			inputs = {
				staticIdVInput = -964740233,
				durationVInput = 2
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
		[79] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-499.247,
					59.468,
					778.082
				},
				rotationVInput = {
					5.454,
					179.3,
					359.579
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 6.42,
				cameraId = 91358532,
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
						nodeId = 80,
						portId = "In"
					}
				}
			}
		},
		[80] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 6,
				positionVInput = {
					-498.911,
					59.47,
					778.061
				},
				rotationVInput = {
					6.657,
					188.745,
					359.578
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 6.42,
				cameraId = 91358531,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false
			},
			flowIn = {
				In = 0
			}
		},
		[81] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-498.556,
					58.391,
					776.656
				},
				rotationVInput = {
					18.861,
					65.408,
					359.557
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 14,
				cameraId = 91346464,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 82,
						portId = "In"
					}
				}
			}
		},
		[82] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 7,
				positionVInput = {
					-498.578,
					58.321,
					776.647
				},
				rotationVInput = {
					18.861,
					65.408,
					359.557
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 14,
				cameraId = 91346465,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[83] = {
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Cheeksupport",
				animationLayerVInput = 4,
				staticIdVInput = -904020802
			},
			fields = {
				templateId = 400204,
				processingTime = 4.9,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		[84] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = -964740233,
				playableStateVInput = "Story_CrossingLegs_Start",
				speedVInput = 0.8,
				playStartLoopEndVInput = true
			},
			fields = {
				processingTime = 1.083,
				templateId = 401059,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_CrossingLegs_Start",
					"Story_CrossingLegs_Loop",
					"Story_CrossingLegs_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[85] = {
			kind = 7,
			fields = {
				dialogueId = 6201257
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 68,
						portId = "1"
					}
				}
			}
		},
		[86] = {
			kind = 5,
			inputs = {
				playableStateVInput = "TalkUpper_Cheeksupport",
				animationLayerVInput = 4,
				staticIdVInput = -904020802
			},
			fields = {
				templateId = 400204,
				processingTime = 4.9,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		[87] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Arrogant",
				staticIdVInput = -964740233
			},
			fields = {
				templateId = 401059,
				processingTime = 6.433,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		[88] = {
			kind = 3,
			inputs = {
				fovVInput = 36,
				positionVInput = {
					-498.362,
					58.279,
					776.944
				},
				rotationVInput = {
					13.705,
					88.997,
					359.568
				}
			},
			fields = {
				focalDistance = 142,
				fStop = 32,
				cameraId = 91346435,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 297,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 89,
						portId = "In"
					}
				}
			}
		},
		[89] = {
			kind = 3,
			inputs = {
				fovVInput = 36,
				blendTimeVInput = 8,
				positionVInput = {
					-498.338,
					58.278,
					776.819
				},
				rotationVInput = {
					14.22,
					79.883,
					359.568
				}
			},
			fields = {
				focalDistance = 142,
				fStop = 32,
				cameraId = 91346436,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 297,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[90] = {
			kind = 33,
			inputs = {
				facialEmotionVInput = "Serious",
				entityIdVInput = -904020802
			},
			fields = {
				activePlayEmotion = true,
				noBlink = false,
				activePlayLip = true
			},
			flowIn = {
				In = 0
			}
		},
		[91] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-498.159,
					57.98,
					779.113
				},
				rotationVInput = {
					344.828,
					194.064,
					359.566
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 32,
				cameraId = 0,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 294,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 92,
						portId = "In"
					}
				}
			}
		},
		[92] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 6,
				positionVInput = {
					-498.164,
					57.901,
					779.092
				},
				rotationVInput = {
					344.828,
					194.064,
					359.566
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 32,
				cameraId = 91346515,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 294,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[93] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-498.166,
					58.447,
					777.304
				},
				rotationVInput = {
					20.064,
					60.241,
					359.554
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 18.76,
				cameraId = 91346400,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 394,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[94] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-499.414,
					59.167,
					778.191
				},
				rotationVInput = {
					358.235,
					172.134,
					359.581
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 8.68,
				cameraId = 91346376,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[95] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Think_Start",
				staticIdVInput = -1557538153,
				playStartLoopEndVInput = true
			},
			fields = {
				processingTime = 3.167,
				templateId = 400180,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"",
					"",
					""
				}
			},
			flowIn = {
				In = 0
			}
		},
		[96] = {
			kind = 5,
			inputs = {
				playableStateVInput = "Talk_Lefthand",
				staticIdVInput = -1557538153
			},
			fields = {
				templateId = 400180,
				processingTime = 5.2,
				playAniType = 1,
				isLooping = false,
				entityType = 2
			},
			flowIn = {
				In = 0
			}
		},
		[97] = {
			kind = 3,
			inputs = {
				fovVInput = 35,
				positionVInput = {
					-498.166,
					58.447,
					777.304
				},
				rotationVInput = {
					20.064,
					60.241,
					359.554
				}
			},
			fields = {
				focalDistance = 144,
				fStop = 18.76,
				cameraId = 91346397,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 394,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[98] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				staticIdVInput = -964740233,
				playableStateVInput = "Story_Talk_Start",
				speedVInput = 0.8,
				playStartLoopEndVInput = true
			},
			fields = {
				processingTime = 1.083,
				templateId = 401059,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Story_Talk_Start",
					"Story_Talk_Loop",
					"Story_Talk_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[99] = {
			kind = 7,
			fields = {
				dialogueId = 6201236
			},
			flowIn = {
				In = 0
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
		[100] = {
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
						nodeId = 101,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 98,
						portId = "In"
					}
				}
			}
		},
		[101] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201238
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 7.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 39,
						portId = "1"
					}
				}
			}
		},
		[102] = {
			kind = 3,
			inputs = {
				positionVInput = {
					-499.465,
					59.301,
					777.655
				},
				rotationVInput = {
					5.626,
					169.845,
					359.579
				}
			},
			fields = {
				focalDistance = 180,
				fStop = 11.25,
				cameraId = 91346297,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 103,
						portId = "In"
					}
				}
			}
		},
		[103] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 8,
				positionVInput = {
					-499.276,
					59.301,
					777.659
				},
				rotationVInput = {
					7.517,
					173.785,
					359.577
				}
			},
			fields = {
				focalDistance = 180,
				fStop = 11.25,
				cameraId = 91346319,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[104] = {
			kind = 5,
			inputs = {
				loopDurationVInput = 999,
				playableStateVInput = "Behav_DoubtStart",
				staticIdVInput = -964740233,
				playStartLoopEndVInput = true
			},
			fields = {
				processingTime = 1.083,
				templateId = 401059,
				playAniType = 1,
				isLooping = false,
				entityType = 2,
				aniStateList = {
					"Behav_DoubtStart",
					"Behav_DoubtLoop",
					"Behav_DoubtEnd"
				}
			},
			flowIn = {
				In = 0
			}
		},
		[105] = {
			kind = 7,
			fields = {
				dialogueId = 6201228
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 106,
						portId = "In"
					}
				}
			}
		},
		[106] = {
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
						nodeId = 107,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 102,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		[107] = {
			kind = 1,
			inputs = {
				dialogueIdVInput = 6201230
			},
			fields = {
				npcStaticId = -964740233,
				npcId = 401059,
				matchAudioDuration = true,
				duration = 4.88,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 30,
						portId = "1"
					}
				}
			}
		},
		[108] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 7.9,
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
				focalDistance = 228,
				fStop = 6.01,
				cameraId = 91071652,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true
			},
			flowIn = {
				In = 0
			}
		},
		[109] = {
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
				ignoreGravity = false,
				entityId = -395114539
			},
			flowIn = {
				In = 0
			}
		},
		[110] = {
			kind = 14,
			inputs = {
				staticIdVInput = 2,
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
