-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90653830.lua

return {
	schema = "v4",
	startNodeId = 1,
	dialogueId = 90653830,
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
				clearEventInputVInput = true,
				blockPlayerMoveVInput = true,
				blockEventVInput = true,
				blockCameraZoomVInput = true,
				applyStateConflictVInput = true,
				startSkipVInput = true,
				hideTopLogoVInput = true,
				hideAllUIVInput = true
			},
			fields = {
				topLogoComs = {
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
					vlog = true,
					teamSpeech = true,
					quest = true
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
			kind = 13,
			valueIn = {
				npcIdVInput = {
					nodeId = 15,
					portId = "EntityID"
				}
			},
			fields = {
				enableDefaultLookAt = true,
				resetOrientation = true,
				reactPreset = 3,
				enableGroupLookAt = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				FOut = {
					{
						nodeId = 4,
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
						nodeId = 8,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 5,
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
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				fadeDurationVInput = 0,
				playableStateVInput = "Talk_Crossingarms"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 16,
					portId = "EntityID"
				}
			},
			fields = {
				processingTime = 5.867,
				playAniType = 1,
				entityType = 2,
				templateId = 400079
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 30,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-1583.42,
					89.015,
					831.406
				},
				rotationVInput = {
					1.863,
					90.993,
					0
				}
			},
			fields = {
				fStop = 10.18,
				squeezeFactor = 1,
				sensorWidth = 360,
				openDof = true,
				focalDistance = 255
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
					98.213,
					0
				},
				targetPositionVInput = {
					-1582.04,
					87.582,
					831.738
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 17,
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 6701351
			},
			fields = {
				npcId = 400079,
				duration = 10,
				chatType = 3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6701352
			},
			fields = {
				npcId = 400079,
				duration = 3,
				chatType = 3
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
			kind = 12,
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
						nodeId = 12,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 14,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showAllUIVInput = false,
				endSkipVInput = true
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
						nodeId = 0,
						portId = "End"
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
			kind = 9,
			inputs = {
				staticIdVInput = 52417422
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 9,
			inputs = {
				staticIdVInput = 52417422
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 17
		}
	}
}
