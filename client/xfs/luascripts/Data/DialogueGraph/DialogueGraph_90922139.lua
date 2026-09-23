-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_90922139.lua

return {
	dialogueId = 90922139,
	schema = "v4",
	startNodeId = 2,
	nodes = {
		[0] = {
			kind = 6,
			fields = {
				retFlag = 2
			},
			flowIn = {
				End = true
			}
		},
		{
			kind = 6,
			fields = {
				retFlag = 1
			},
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
				switchToPetVInput = true
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
			kind = 18,
			inputs = {
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
					callFriends = true
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
						nodeId = 10,
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
						nodeId = 8,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 132,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 130,
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
					283.75,
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
					nodeId = 157,
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
						nodeId = 7,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 157,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 163,
					portId = "EntityID"
				}
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
					142.689,
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
					nodeId = 161,
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
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 161,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 157,
					portId = "EntityID"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709089
			},
			fields = {
				chatType = 3,
				portCount = 2,
				duration = 4
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
			kind = 7,
			fields = {
				dialogueId = 6709090
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 12,
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
						nodeId = 13,
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
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 32,
				blendTimeVInput = 0.5,
				positionVInput = {
					40.172,
					100.665,
					874.514
				},
				rotationVInput = {
					3.666,
					41.779,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				cameraId = 90965621,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709092
			},
			fields = {
				chatType = 3,
				duration = 7
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
				portCount = 2
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
						nodeId = 16,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709093
			},
			fields = {
				chatType = 3,
				duration = 7
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
				portCount = 2
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
				},
				["1"] = {
					{
						nodeId = 18,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709094
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
						nodeId = 19,
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
						nodeId = 28,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709095
			},
			fields = {
				chatType = 3,
				duration = 5
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
						nodeId = 22,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709096
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
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709097
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
						nodeId = 24,
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
						nodeId = 25,
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
						nodeId = 1,
						portId = "End"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				blendExponentVInput = 2,
				positionVInput = {
					39.151,
					100.657,
					873.789
				},
				rotationVInput = {
					1.775,
					41.779,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90965623,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 2,
				fovVInput = 28,
				blendTimeVInput = 8,
				positionVInput = {
					39.308,
					100.653,
					873.894
				},
				rotationVInput = {
					1.26,
					42.982,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 180,
				fStop = 14,
				cameraId = 90965684,
				squeezeFactor = 1.2,
				sensorWidth = 150
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
				fovVInput = 32,
				positionVInput = {
					40.813,
					100.555,
					874.698
				},
				rotationVInput = {
					349.228,
					270.973,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90965672,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 29,
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
				fovVInput = 32,
				blendTimeVInput = 3,
				positionVInput = {
					40.635,
					100.592,
					874.698
				},
				rotationVInput = {
					347.681,
					269.941,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				cameraId = 90965683,
				squeezeFactor = 1.2,
				sensorWidth = 150
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
				fovVInput = 30,
				positionVInput = {
					40.179,
					100.61,
					874.626
				},
				rotationVInput = {
					2.119,
					46.592,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90965668,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 31,
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
				fovVInput = 30,
				blendTimeVInput = 3,
				positionVInput = {
					40.317,
					100.604,
					874.755
				},
				rotationVInput = {
					1.604,
					47.623,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				cameraId = 90965682,
				squeezeFactor = 1.2,
				sensorWidth = 150
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
				fovVInput = 32,
				positionVInput = {
					41.811,
					100.423,
					875.034
				},
				rotationVInput = {
					351.978,
					269.426,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90965681,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 33,
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
				fovVInput = 32,
				blendTimeVInput = 6,
				positionVInput = {
					41.664,
					100.444,
					875.032
				},
				rotationVInput = {
					351.978,
					269.426,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 140,
				fStop = 16,
				cameraId = 90965667,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 6709091
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
			kind = 12,
			flowIn = {
				In = true
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
						nodeId = 37,
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
					chat = true,
					bubble = true,
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
					callFriends = true
				}
			},
			flowIn = {
				In = true
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
			kind = 22,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 39,
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
						nodeId = 40,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 129,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 127,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 128,
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
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
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
				portCount = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 46,
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
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400800,
				processingTime = 2.5
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Furious",
				duration = 3
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
				fovVInput = 40,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961644,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 47,
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
				fovVInput = 34,
				blendTimeVInput = 1.9,
				positionVInput = {
					44.835,
					100.369,
					874.679
				},
				rotationVInput = {
					354.999,
					65.827,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961747,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 48,
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
						nodeId = 49,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 123,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 126,
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
				fovVInput = 45,
				positionVInput = {
					42.909,
					100.479,
					874.725
				},
				rotationVInput = {
					351.218,
					280.583,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961759,
				squeezeFactor = 1,
				sensorWidth = 360
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
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 3,
				positionVInput = {
					42.603,
					100.45,
					874.781
				},
				rotationVInput = {
					347.78,
					282.645,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961779,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 51,
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
						nodeId = 52,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 120,
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
				fovVInput = 40,
				positionVInput = {
					45.03,
					100.321,
					874.43
				},
				rotationVInput = {
					352.936,
					51.561,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961861,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 53,
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
				fovVInput = 45,
				blendTimeVInput = 0.7,
				positionVInput = {
					45.278,
					100.53,
					874.651
				},
				rotationVInput = {
					342.108,
					48.982,
					0.003
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961860,
				squeezeFactor = 1,
				sensorWidth = 360
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
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 40,
				blendTimeVInput = 0.5,
				positionVInput = {
					45.148,
					100.479,
					874.54
				},
				rotationVInput = {
					343.998,
					49.498,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962217,
				squeezeFactor = 1,
				sensorWidth = 360
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
						nodeId = 56,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 117,
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
				fovVInput = 45,
				positionVInput = {
					43.064,
					100.811,
					875.21
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962218,
				squeezeFactor = 1,
				sensorWidth = 360
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
			kind = 3,
			inputs = {
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 2.5,
				positionVInput = {
					43.064,
					100.811,
					875.21
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961887,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
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
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 0.5,
				positionVInput = {
					42.528,
					100.811,
					875.112
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962219,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 59,
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
				fovVInput = 45,
				blendTimeVInput = 0.2,
				positionVInput = {
					42.528,
					100.811,
					875.112
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962301,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
						nodeId = 61,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 115,
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
				fovVInput = 45,
				positionVInput = {
					39.692,
					101.458,
					876.101
				},
				rotationVInput = {
					357.577,
					269.41,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961607,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				fovVInput = 45,
				blendTimeVInput = 1.5,
				positionVInput = {
					39.677,
					101.458,
					876.101
				},
				rotationVInput = {
					357.577,
					269.41,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962266,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 63,
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
				fovVInput = 45,
				blendTimeVInput = 1.5,
				positionVInput = {
					39.074,
					101.458,
					876.101
				},
				rotationVInput = {
					357.577,
					269.41,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962272,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 64,
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
						nodeId = 67,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 65,
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
					263.34,
					0
				},
				targetPositionVInput = {
					53.005,
					100.406,
					875.98
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 66,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "SprintLoop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400800,
				processingTime = 5,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"SprintLoop",
					"SprintLoop",
					"SprintLoop"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.1
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 68,
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
				fovVInput = 45,
				positionVInput = {
					54.138,
					100.623,
					876.289
				},
				rotationVInput = {
					6.57,
					256.348,
					4.969
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961876,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 69,
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
				fovVInput = 45,
				blendTimeVInput = 1.7,
				positionVInput = {
					47.51,
					100.818,
					874.362
				},
				rotationVInput = {
					9.362,
					276.6,
					358.438
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961877,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 70,
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
						nodeId = 71,
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
				fovVInput = 45,
				positionVInput = {
					41.997,
					100.673,
					874.714
				},
				rotationVInput = {
					358.652,
					80.024,
					359.656
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961897,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 72,
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
				fovVInput = 45,
				blendTimeVInput = 0.5,
				positionVInput = {
					42.005,
					100.62,
					874.672
				},
				rotationVInput = {
					358.67,
					82.846,
					359.591
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961900,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 73,
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
						nodeId = 74,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 113,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 112,
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
				fovVInput = 45,
				blendTimeVInput = 0.2,
				positionVInput = {
					42.528,
					100.811,
					875.112
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962344,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 75,
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
				fovVInput = 45,
				blendTimeVInput = 0.5,
				positionVInput = {
					42.528,
					100.811,
					875.112
				},
				rotationVInput = {
					1.875,
					258.237,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962345,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 76,
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
						nodeId = 77,
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
						nodeId = 78,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 110,
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
						nodeId = 79,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 80,
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
				fovVInput = 45,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962363,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 81,
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
				fovVInput = 45,
				blendTimeVInput = 1.9,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961958,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
		{
			kind = 22,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 83,
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
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 84,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 85,
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
				fovVInput = 45,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961968,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 86,
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
				fovVInput = 45,
				blendTimeVInput = 1.9,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90961969,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 87,
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
						nodeId = 88,
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
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 89,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 90,
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
				fovVInput = 45,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962209,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 91,
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
				fovVInput = 45,
				blendTimeVInput = 3,
				positionVInput = {
					44.686,
					100.456,
					874.637
				},
				rotationVInput = {
					355.687,
					66.687,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962208,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
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
						nodeId = 93,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 106,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 109,
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
				fovVInput = 45,
				positionVInput = {
					43.298,
					100.631,
					875.106
				},
				rotationVInput = {
					16.089,
					267.973,
					2.413
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962316,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 94,
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
				fovVInput = 45,
				blendTimeVInput = 3,
				positionVInput = {
					42.961,
					100.632,
					875.276
				},
				rotationVInput = {
					353.011,
					262.378,
					2.336
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962319,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 95,
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
				fovVInput = 45,
				blendTimeVInput = 5,
				positionVInput = {
					42.961,
					100.632,
					875.276
				},
				rotationVInput = {
					353.011,
					262.378,
					2.336
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962368,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 96,
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
						nodeId = 97,
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
						nodeId = 98,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 99,
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
						nodeId = 100,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 23,
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 101,
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
						nodeId = 102,
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
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709105
			},
			fields = {
				chatType = 6,
				duration = 4
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 103,
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
						nodeId = 104,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 20,
			inputs = {
				isResetValueInput = true,
				durationVInput = 3
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
			kind = 19,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 10,
				speedVInput = 1.25,
				targetEulerAngleVInput = {
					0,
					60,
					0
				},
				targetPositionVInput = {
					58.638,
					100.448,
					900.706
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				reset = true,
				speedCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							inWeight = 0,
							outTangent = 1,
							inTangent = 0,
							value = 0,
							time = 0,
							weightedMode = 0,
							outWeight = 0
						},
						{
							inWeight = 0,
							outTangent = 0,
							inTangent = 1,
							value = 1,
							time = 1,
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
						nodeId = 107,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 108,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Behav_AngryLoop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400800,
				processingTime = 1.333,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Behav_AngryLoop",
					"Behav_AngryLoop",
					"Behav_AngryLoop"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Laugh",
				duration = 5
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Cheer_Start",
				playStartLoopEndVInput = true,
				loopDurationVInput = 20
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 159,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400077,
				playAniType = 1,
				aniStateList = {
					"Emotion_Cheer_Start",
					"Emotion_Cheer_Loop",
					"Emotion_Cheer_End"
				}
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
					251.926,
					0
				},
				targetPositionVInput = {
					45.323,
					100.261,
					874.94
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				setPosition = true,
				setRotation = true
			},
			flowIn = {
				In = true
			},
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
			kind = 5,
			inputs = {
				speedVInput = 0.1,
				playableStateVInput = "Die"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400800,
				processingTime = 1.333
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
					251.926,
					0
				},
				targetPositionVInput = {
					45.323,
					100.261,
					874.94
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
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
			kind = 4,
			fields = {
				delayTime = 0.3
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 114,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Skill_ArcAttack"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400800,
				processingTime = 1.717
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.6
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Out = {
					{
						nodeId = 116,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Emotion_Shock"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 159,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400077,
				processingTime = 4.333
			},
			flowIn = {
				In = true
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
						nodeId = 118,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 119,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "IdleSpecial"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				playAniType = 1,
				entityType = 2,
				templateId = 400800,
				processingTime = 3.667
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Alert",
				duration = 3
			},
			flowIn = {
				In = true
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
						nodeId = 121,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 122,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Skill_Strike"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400800,
				processingTime = 2.5,
				playAniType = 1,
				entityType = 2,
				aniStateList = {
					"Skill_Strike",
					"Skill_Strike",
					"Skill_Strike"
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Furious",
				duration = 3
			},
			flowIn = {
				In = true
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
						nodeId = 124,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 125,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				playStartLoopEndVInput = true,
				playableStateVInput = "Behav_DoubtStart"
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				templateId = 400800,
				processingTime = 3.667,
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
			kind = 29,
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
					portId = "EntityID"
				}
			},
			fields = {
				emojiName = "Mistake",
				duration = 3
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 5,
			inputs = {
				playableStateVInput = "Story_Akimbo01_Loop",
				playStartLoopEndVInput = true,
				loopDurationVInput = 999
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 159,
					portId = "EntityID"
				}
			},
			fields = {
				entityType = 2,
				templateId = 400077,
				playAniType = 1,
				aniStateList = {
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop",
					"Story_Akimbo01_Loop"
				}
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
					79.475,
					0
				},
				targetPositionVInput = {
					41.522,
					100.406,
					874.898
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 158,
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
					105.66,
					0
				},
				targetPositionVInput = {
					38.337,
					100.406,
					876.095
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 159,
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
					252.13,
					0
				},
				targetPositionVInput = {
					46.064,
					100.34,
					875.154
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 160,
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
					62.422,
					0
				},
				targetPositionVInput = {
					39.677,
					100.432,
					874.645
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 163,
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
						nodeId = 131,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			valueIn = {
				entityIdVInput = {
					nodeId = 163,
					portId = "EntityID"
				},
				lookAtEntityIdVInput = {
					nodeId = 157,
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
				fovVInput = 30,
				blendTimeVInput = 0.6,
				positionVInput = {
					38.914,
					101.01,
					872.778
				},
				rotationVInput = {
					6.245,
					30.434,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 169,
				fStop = 12,
				cameraId = 90965628,
				squeezeFactor = 1.2,
				sensorWidth = 150
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
				blendTimeVInput = 0.5,
				positionVInput = {
					39.074,
					101.458,
					876.101
				},
				rotationVInput = {
					357.577,
					269.41,
					0.002
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90962223,
				squeezeFactor = 1,
				sensorWidth = 360
			}
		},
		{
			kind = 2,
			fields = {
				portCount = 2
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 135,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 136,
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
				fovVInput = 32,
				blendTimeVInput = 0.5,
				positionVInput = {
					40.172,
					100.665,
					874.514
				},
				rotationVInput = {
					3.666,
					41.779,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709098
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
						nodeId = 137,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709099
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
						nodeId = 138,
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
						nodeId = 139,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 141,
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
				fovVInput = 32,
				positionVInput = {
					41.811,
					100.423,
					875.034
				},
				rotationVInput = {
					351.978,
					269.426,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				focalDistance = 200,
				fStop = 4,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 140,
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
				fovVInput = 32,
				blendTimeVInput = 6,
				positionVInput = {
					41.664,
					100.444,
					875.032
				},
				rotationVInput = {
					351.978,
					269.426,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 140,
				fStop = 16,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709100
			},
			fields = {
				chatType = 3,
				duration = 5
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 142,
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
						nodeId = 143,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 145,
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
				fovVInput = 30,
				positionVInput = {
					40.179,
					100.61,
					874.626
				},
				rotationVInput = {
					2.119,
					46.592,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				focalDistance = 200,
				fStop = 4,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 144,
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
				fovVInput = 30,
				blendTimeVInput = 3,
				positionVInput = {
					40.317,
					100.604,
					874.755
				},
				rotationVInput = {
					1.604,
					47.623,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709101
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
						nodeId = 146,
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
						nodeId = 147,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 149,
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
				fovVInput = 32,
				positionVInput = {
					40.813,
					100.555,
					874.698
				},
				rotationVInput = {
					349.228,
					270.973,
					0
				}
			},
			fields = {
				squeezeFactor = 1,
				focalDistance = 200,
				fStop = 4,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 148,
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
				fovVInput = 32,
				blendTimeVInput = 3,
				positionVInput = {
					40.635,
					100.592,
					874.698
				},
				rotationVInput = {
					347.681,
					269.941,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 75,
				fStop = 16,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709102
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 150,
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
						nodeId = 151,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 153,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 28,
				blendExponentVInput = 2,
				positionVInput = {
					39.003,
					100.69,
					873.81
				},
				rotationVInput = {
					5.213,
					48.998,
					0
				}
			},
			fields = {
				focalDistance = 200,
				fStop = 4,
				cameraId = 90965722,
				squeezeFactor = 1,
				sensorWidth = 360
			},
			flowIn = {
				In = true
			},
			flowOut = {
				Finish = {
					{
						nodeId = 152,
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
				fovVInput = 28,
				blendTimeVInput = 0.5,
				positionVInput = {
					40.059,
					100.66,
					874.591
				},
				rotationVInput = {
					4.01,
					51.233,
					0
				}
			},
			fields = {
				openDof = true,
				focalDistance = 80,
				fStop = 20,
				cameraId = 90965721,
				squeezeFactor = 1.2,
				sensorWidth = 150
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6709103
			},
			fields = {
				duration = 2
			},
			flowIn = {
				In = true
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
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					252.13,
					0
				},
				targetPositionVInput = {
					45.7,
					100.406,
					875.07
				}
			},
			fields = {
				setPosition = true,
				reset = true,
				setRotation = true
			}
		},
		{
			kind = 13,
			fields = {
				resetOrientation = true,
				enableGroupLookAt = true,
				enableDefaultLookAt = true
			}
		},
		{
			kind = 16,
			inputs = {
				virtualEntityTypeVInput = 2,
				slotParamVInput = 400800,
				positionVInput = {
					46.064,
					100.34,
					875.154
				},
				rotationVInput = {
					0,
					252.13,
					0
				}
			},
			fields = {
				entityId = -779615324
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
			kind = 9
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
			kind = 9,
			inputs = {
				staticIdVInput = 90948935
			},
			fields = {
				entityType = 2
			}
		},
		{
			kind = 14,
			inputs = {
				targetEulerAngleVInput = {
					0,
					252.13,
					0
				},
				targetPositionVInput = {
					45.7,
					100.406,
					875.07
				}
			},
			fields = {
				setPosition = true,
				reset = true,
				setRotation = true
			}
		},
		{
			kind = 9
		}
	}
}
