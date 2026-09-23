-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_77012190.lua

return {
	startNodeId = 1,
	dialogueId = 77012190,
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
			kind = 11,
			fields = {
				modeInfo = {
					applyStateConflict = false,
					pauseNearbyMonsterAI = false,
					enhanceAmbientIntensity = true,
					exitCatchMode = true,
					resetAllActions = false,
					blockEvent = false,
					modeType = 1,
					blockCameraZoom = false,
					hideTopLogo = true,
					hideMarkShare = false,
					hideInteractionSign = true,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
						petChat = true,
						npc = true,
						multiPlayer = true,
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
						petExchange = true
					}
				}
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
			kind = 24,
			inputs = {
				switchToWalkVInput = true
			},
			flowIn = {
				In = 0
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
						nodeId = 164,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 5,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260230230
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 6,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 6,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
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
				delayTime = 0.5
			},
			flowIn = {
				In = 0
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
						nodeId = 9,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 10,
			inputs = {
				showTopLogoVInput = false,
				showAllUIVInput = false,
				enablePlayerMoveVInput = false,
				enableEventVInput = false,
				enableCameraZoomVInput = false
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
			kind = 45,
			inputs = {
				timelineResIdVInput = "$P_TL_Novice_P3_ShuangZiChuXian.prefab"
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 11,
						portId = "In"
					}
				},
				PreFinish = {
					{
						nodeId = 163,
						portId = "In"
					}
				},
				Start = {
					{
						nodeId = 162,
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
						nodeId = 12,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 161,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 11,
			fields = {
				modeInfo = {
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
					hideInteractionSign = true,
					showHud = true,
					hideAllUI = true,
					disableSpaceFollow = true,
					toplogoComList = {
						petChat = true,
						npc = true,
						multiPlayer = true,
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
						petExchange = true
					}
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
						nodeId = 14,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 34,
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
						nodeId = 42,
						portId = "In"
					}
				},
				["4"] = {
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
				portCount = 4
			},
			flowIn = {
				In = 0
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
						nodeId = 22,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 24,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 28,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 79379149,
				targetEulerAngleVInput = {
					0.055,
					47.647,
					359.744
				},
				targetPositionVInput = {
					-1743.4,
					94.61,
					631.66
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
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
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 79379149
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 17,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				speedVInput = 1.2,
				staticIdVInput = 79379149,
				playableStateVInput = "Story_Observe"
			},
			fields = {
				entityType = 2,
				templateId = 400061,
				processingTime = 5.833,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				portCount = 3
			},
			flowIn = {
				In = 0
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
						nodeId = 21,
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 20,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 79379149
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79379149,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 79379146,
				targetEulerAngleVInput = {
					0,
					97.3,
					0
				},
				targetPositionVInput = {
					-1743.844,
					94.61,
					632.795
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 23,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 79379146
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 14,
			inputs = {
				staticIdVInput = 2,
				targetEulerAngleVInput = {
					0,
					248.675,
					0
				},
				targetPositionVInput = {
					-1742.192,
					94.598,
					632.727
				}
			},
			fields = {
				setRotation = true,
				setPosition = true,
				reset = false
			},
			flowIn = {
				In = 0
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
			kind = 5,
			inputs = {
				playableStateVInput = "SquatObserve_Start",
				loopDurationVInput = 999,
				staticIdVInput = 2,
				defaultTransStateVInput = "SquatObserve_Loop"
			},
			fields = {
				entityType = 0,
				templateId = 3,
				processingTime = 3.733,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
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
						nodeId = 27,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79379149,
				staticIdVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
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
						nodeId = 29,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 30,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 31,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 32,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 33,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 63,
			inputs = {
				positionVInput = {
					-1742.579,
					95.267,
					632.706
				},
				rotationVInput = {
					16.285,
					272.227,
					359.184
				}
			},
			fields = {
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				radius = 4,
				spotLightInnerAngle = 0,
				spotLightOuterAngle = 65,
				temperature = 1500,
				usePhysicalLightUnit = true,
				twoSide = false,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 4,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 1000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				areaLightUnit = 1,
				color = {
					r = 0.6084906,
					b = 1,
					a = 1,
					g = 0.9314762
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 63,
			inputs = {
				positionVInput = {
					-1751.302,
					99.221,
					628.622
				},
				rotationVInput = {
					22.92,
					70.766,
					4.749
				}
			},
			fields = {
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				radius = 60,
				spotLightInnerAngle = 0,
				spotLightOuterAngle = 80,
				temperature = 1500,
				usePhysicalLightUnit = false,
				twoSide = false,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 20406,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 0,
				areaLightUnit = 1,
				color = {
					r = 0.8537736,
					b = 1,
					a = 1,
					g = 0.9751462
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 63,
			inputs = {
				positionVInput = {
					-1744.646,
					95.589,
					631.549
				},
				rotationVInput = {
					355.378,
					66.174,
					0
				}
			},
			fields = {
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				radius = 10,
				spotLightInnerAngle = 0,
				spotLightOuterAngle = 163,
				temperature = 1500,
				usePhysicalLightUnit = true,
				twoSide = false,
				punctualLightUnit = 2,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 4,
				lightUnit = 2,
				lightType = 2,
				isSpot = false,
				isDisk = false,
				intensity = 700,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				areaLightUnit = 1,
				color = {
					r = 0.7216981,
					b = 1,
					a = 1,
					g = 0.9086822
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 63,
			inputs = {
				positionVInput = {
					-1742.679,
					95.764,
					632.95
				},
				rotationVInput = {
					13.432,
					203.444,
					1.924
				}
			},
			fields = {
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				radius = 10,
				spotLightInnerAngle = 0,
				spotLightOuterAngle = 117,
				temperature = 1500,
				usePhysicalLightUnit = true,
				twoSide = false,
				punctualLightUnit = 2,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 4,
				lightUnit = 2,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 400,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				areaLightUnit = 1,
				color = {
					r = 1,
					b = 0.6273585,
					a = 1,
					g = 0.8853377
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 63,
			inputs = {
				positionVInput = {
					-1743.019,
					95.73,
					632.296
				},
				rotationVInput = {
					7.623,
					72.307,
					349.783
				}
			},
			fields = {
				areaLightShapeRectangleSizeY = 5,
				areaLightShapeRectangleSizeX = 5,
				areaLightShapeCapsuleUseEndCaps = false,
				areaLightShapeCapsuleRadius = 1,
				areaLightShapeCapsuleLength = 5,
				areaLightShape = 0,
				radius = 10,
				spotLightInnerAngle = 0,
				spotLightOuterAngle = 136,
				temperature = 1500,
				usePhysicalLightUnit = false,
				twoSide = false,
				punctualLightUnit = 1,
				needTodEVMapping = false,
				mainLightRange = 3,
				localLightRange = 0,
				lightUnit = 1,
				lightType = 0,
				isSpot = false,
				isDisk = false,
				intensity = 2000,
				ignoreDynamicCasters = false,
				emissionAppearanceType = 0,
				directionalLightAngularDiameter = 0,
				directionLightUnit = 3,
				channel = 2,
				areaLightUnit = 1,
				color = {
					r = 0.6462264,
					b = 1,
					a = 1,
					g = 0.8918828
				}
			},
			dynamicInputs = {
				"colorDynamicVInput",
				"intensityDynamicVInput",
				"positionDynamicVInput",
				"radiusDynamicVInput",
				"rotationDynamicVInput",
				"temperatureDynamicVInput"
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendFuncVInput = "Cubic",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.373,
					96.1,
					633.694
				},
				rotationVInput = {
					20.8,
					218.739,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837811,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 35,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"PLAYER_BODY_TYPE",
					1,
					1,
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 39,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 36,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 3,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.509,
					96.05,
					633.853
				},
				rotationVInput = {
					25.639,
					209.04,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837815,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 37,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.638,
					95.896,
					633.452
				},
				rotationVInput = {
					26.478,
					241.5,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837846,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 38,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 12,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.688,
					95.708,
					633.772
				},
				rotationVInput = {
					8.727,
					234.469,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837848,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 3,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.588,
					96.2,
					634.131
				},
				rotationVInput = {
					26.81,
					217,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90879521,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
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
				fovVInput = 38,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.648,
					96.058,
					633.995
				},
				rotationVInput = {
					25.822,
					219.4,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90879507,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 41,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 12,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.8,
					95.894,
					634.098
				},
				rotationVInput = {
					17.4,
					217.4,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90879508,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 32,
			fields = {
				eventName = "setBGM",
				eventParam = {
					[1] = "BGM_Story_MeetingXY"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 46,
			valueIn = {
				["1"] = {
					nodeId = 184,
					portId = "animationCurveVOutput"
				}
			},
			fields = {
				volumeComponentCount = 1,
				volumeParamInfoCount = 1,
				volumeComponents = {
					{
						typeName = "VignetteComponent",
						active = false,
						parameters = {
							m_VignetteColor = {
								overrideState = true,
								valueType = "color",
								value = {
									r = 0,
									b = 0,
									a = 1,
									g = 0
								}
							},
							m_EdgeWidth = {
								value = 2,
								overrideState = true,
								valueType = "float"
							},
							m_EdgeSoftness = {
								value = 0.75,
								overrideState = true,
								valueType = "float"
							},
							m_VignetteAlpha = {
								value = 1,
								overrideState = true,
								valueType = "float"
							},
							m_FisheyeFovDeg = {
								value = 0,
								overrideState = false,
								valueType = "float"
							},
							m_FollowAspect = {
								value = true,
								overrideState = false,
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
								name = "宽度",
								paramIndex = 1
							}
						}
					}
				}
			},
			dynamicInputs = {
				"1"
			},
			flowIn = {
				In = 0,
				Stop = 1
			},
			flowOut = {
				Out = {
					{
						nodeId = 44,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 43,
						portId = "Stop"
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
						nodeId = 46,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025029
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0.5,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 3.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025030
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Emotion_Surprise_Start",
				portCount = 1,
				skipTime = 0.5,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 5.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					"Emotion_Surprise_Start",
					"Emotion_Surprise_Loop",
					"Emotion_Surprise_End",
					{
						[1] = true,
						[2] = 0
					}
				}
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
		{
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
						nodeId = 159,
						portId = "In"
					}
				},
				["1"] = {
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
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025031
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0.5,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 7,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
		{
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 51,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				dialogueIdVInput = 26025032
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Behav_HappyEnd",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 7.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Behav_HappyEnd",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025033
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Emotion_Solemn_Start",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 8.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					"Emotion_Solemn_Start",
					"Emotion_Solemn_Loop",
					"Emotion_Solemn_End",
					{
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 54,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025034
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 8,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025035
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Emotion_Surprise",
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 7.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Emotion_Surprise",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
				},
				["1"] = {
					{
						nodeId = 152,
						portId = "In"
					}
				},
				ShowFinOut = {
					{
						nodeId = 154,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 26025036
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 57,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025038
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Story_Idle_Proud",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 3,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Story_Idle_Proud",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 59,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 150,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025040
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 7.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025041
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 8.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
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
						nodeId = 148,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 62,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025042
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Emotion_Solemn_Start",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 6.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					"Emotion_Solemn_Start",
					"Emotion_Solemn_Loop",
					"Emotion_Solemn_End",
					{
						[1] = true,
						[2] = 0
					}
				}
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
						nodeId = 146,
						portId = "In"
					}
				},
				["1"] = {
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
				dialogueIdVInput = 26025043
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Emotion_Solemn_Start",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 8.12,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					"Emotion_Solemn_Start",
					"Emotion_Solemn_Loop",
					"Emotion_Solemn_End",
					{
						[1] = true,
						[2] = 0
					}
				}
			},
			flowIn = {
				In = 0
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
			kind = 12,
			inputs = {
				resumeNpcVInput = false
			},
			flowIn = {
				In = 0
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
						nodeId = 67,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 69,
						portId = "In"
					}
				},
				["2"] = {
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
				fovVInput = 60,
				blendTimeVInput = 2.5,
				blendExponentVInput = 0,
				positionVInput = {
					-1742.394,
					95.1,
					632.977
				},
				rotationVInput = {
					357.6,
					241,
					0.388
				}
			},
			fields = {
				fStop = 2,
				cameraId = 90837927,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 100,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 100
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 60,
				blendTimeVInput = 20,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.408,
					95.1,
					632.975
				},
				rotationVInput = {
					354.3,
					240.8,
					0.388
				}
			},
			fields = {
				fStop = 3,
				cameraId = 90837928,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 200,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 100
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				portCount = 3
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
				},
				["1"] = {
					{
						nodeId = 144,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 114
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				CloseOut = {
					{
						nodeId = 72,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"CHECK_CLIENT_CUSTOM_VARIABLE",
					1137,
					nil,
					"<",
					2
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 137,
						portId = "In"
					}
				},
				True = {
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
				portCount = 4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 133,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 74,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 134,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025051
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Behav_Happy",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 4.12,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Behav_Happy",
					[2] = {
						[1] = false,
						[2] = 10
					}
				}
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
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260250510
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 4.25,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0
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
		{
			kind = 12,
			inputs = {
				resumeNpcVInput = false
			},
			flowIn = {
				In = 0
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 129,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 78,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 131,
						portId = "StopDof"
					}
				},
				["3"] = {
					{
						nodeId = 132,
						portId = "StopDof"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025053
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 6.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
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
				dialogueIdVInput = 26025054
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 9,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025055
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 8.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 81,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025056
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
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
				dialogueIdVInput = 26025057
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 2,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 83,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 127,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 26025058
			},
			flowIn = {
				In = 0
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
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025060
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 7.38,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 85,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025062
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 86,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 88,
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
				delayTime = 2.5
			},
			flowIn = {
				In = 0
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
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 79379146,
				staticIdVInput = 79379149
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025063
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 3.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 92,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400061,
				dialogueIdVInput = 26025064
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 3.5,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 93,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				lookAtIdVInput = 400109,
				dialogueIdVInput = 26025065
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 6.62,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 94,
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
						nodeId = 109,
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
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025066
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 1,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 2.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 96,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 12,
			flowIn = {
				In = 0
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
						nodeId = 98,
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
						nodeId = 103,
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
						nodeId = 101,
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
			kind = 4,
			fields = {
				delayTime = 0.6
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
		{
			kind = 38,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 15,
				entityIdVInput = 79379146,
				targetEulerAngleVInput = {
					0,
					7.407,
					0
				},
				targetPositionVInput = {
					-1735.176,
					94.492,
					616.786
				}
			},
			fields = {
				finishToSteer = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 38,
			inputs = {
				moveTypeVInput = 2,
				maxLimitTimeVInput = 15,
				entityIdVInput = 79379149,
				targetEulerAngleVInput = {
					0,
					302.72,
					0
				},
				targetPositionVInput = {
					-1734.093,
					94.585,
					617.466
				}
			},
			fields = {
				finishToSteer = true
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				blendTimeVInput = 2,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1743.505,
					95.883,
					634.223
				},
				rotationVInput = {
					0.804,
					151.33,
					0.001
				}
			},
			fields = {
				fStop = 4,
				cameraId = 79412480,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.2
			},
			flowIn = {
				In = 0
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
			kind = 26,
			inputs = {
				staticIdVInput = 2,
				durationVInput = 0.4,
				targetEulerAngleVInput = {
					0,
					-97.7,
					0
				}
			},
			valueIn = {
				entityIdVInput = {
					nodeId = 185,
					portId = "EntityID"
				},
				faceTransVInput = {
					nodeId = 186,
					portId = "BoneTransform"
				}
			},
			fields = {
				reset = false
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				FinishOut = {
					{
						nodeId = 105,
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
		{
			kind = 10,
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 107,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 21,
			inputs = {
				blendTimeVInput = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 108,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 24,
			inputs = {
				switchToLocomotionVInput = true
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
		{
			kind = 28,
			inputs = {
				staticIdVInput = 79379149
			},
			flowIn = {
				In = 0
			}
		},
		{
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
						nodeId = 111,
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 116,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 121,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 112,
						portId = "In"
					}
				},
				["3"] = {
					{
						nodeId = 122,
						portId = "In"
					}
				},
				["4"] = {
					{
						nodeId = 124,
						portId = "In"
					}
				},
				["5"] = {
					{
						nodeId = 126,
						portId = "Play"
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
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 113,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				blendExponentVInput = 0,
				blendTimeVInput = 4.7,
				positionVInput = {
					-1741.302,
					95.55,
					633.764
				},
				rotationVInput = {
					15.3,
					237.177,
					4.31
				}
			},
			fields = {
				fStop = 4,
				cameraId = 87919241,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 114,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.5
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
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
				blendTimeVInput = 4,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.489,
					96,
					633.61
				},
				rotationVInput = {
					15.3,
					237.177,
					1.945
				}
			},
			fields = {
				fStop = 4,
				cameraId = 87920787,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.4
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 117,
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
						nodeId = 118,
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
			kind = 56,
			fields = {
				shakeType = 0,
				cameraShakeItem = {
					shakeFrequency = 6,
					shakeDissipation = 28,
					random = false,
					shakeRadius = -1,
					decayTime = 4,
					sustainTime = 3,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 0,
					flags = 0,
					initPhase = 0,
					shakeBias = 0,
					shakeAmplitude = 0.3,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0
							},
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0
							},
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0
							}
						}
					},
					shakeDir = {
						0.2,
						0.2,
						-0.2
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 119,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 56,
			fields = {
				shakeType = 0,
				cameraShakeItem = {
					shakeFrequency = 4,
					shakeDissipation = 28,
					random = false,
					shakeRadius = -1,
					decayTime = 6,
					sustainTime = 4,
					attackTime = 2,
					holdForever = false,
					playSpace = 0,
					shakeType = 0,
					flags = 0,
					initPhase = 0,
					shakeBias = 0,
					shakeAmplitude = 0.15,
					shakeRadiusCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0
							},
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					shakeFrequencyCurve = {
						postWrapMode = 8,
						preWrapMode = 8,
						keys = {
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 0,
								outTangent = 0,
								inTangent = 0
							},
							{
								value = 1,
								inWeight = 0,
								weightedMode = 0,
								outWeight = 0,
								time = 1,
								outTangent = 0,
								inTangent = 0
							}
						}
					},
					shakeDir = {
						0.2,
						0.2,
						-0.2
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 32,
			fields = {
				eventName = "setBGM",
				eventParam = {
					[1] = "BGM_Scene_Novice_Cave_2"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 5,
			inputs = {
				speedVInput = 1.2,
				playStartLoopEndVInput = true,
				staticIdVInput = 2,
				playableStateVInput = "SquatFall_Start"
			},
			fields = {
				entityType = 0,
				isLooping = false,
				templateId = 3,
				processingTime = 3.733,
				playAniType = 1,
				aniStateList = {
					"SquatFall_Start",
					"SquatFall_Loop",
					"SquatFall_End"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 0.6
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 123,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 79379149,
				playableStateVInput = "Story_Shaking"
			},
			fields = {
				entityType = 2,
				templateId = 400061,
				processingTime = 3.733,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
			}
		},
		{
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
						nodeId = 125,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 5,
			inputs = {
				staticIdVInput = 79379146,
				playableStateVInput = "Story_Shaking"
			},
			fields = {
				entityType = 2,
				templateId = 400109,
				processingTime = 3.733,
				playAniType = 1,
				isLooping = false
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 31,
			inputs = {
				audioEventVInput = "SFX_Novice_Earthquake"
			},
			flowIn = {
				Play = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 26025059
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 128,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025061
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 4.25,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
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
				fovVInput = 38,
				blendTimeVInput = 4,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.744,
					95.527,
					633.949
				},
				rotationVInput = {
					11.352,
					223.895,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837959,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 130,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 12,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.958,
					95.527,
					634.358
				},
				rotationVInput = {
					12.033,
					209.951,
					1.435
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837966,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 46,
				blendTimeVInput = 6,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.705,
					95.35,
					632.827
				},
				rotationVInput = {
					12.97,
					205.6,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					nodeId = 187,
					portId = "BoneTransform"
				}
			},
			fields = {
				fStop = 9,
				cameraId = 90849797,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 1357
			},
			flowIn = {
				In = 0,
				StopDof = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 44,
				blendTimeVInput = 6,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.601,
					95.005,
					632.782
				},
				rotationVInput = {
					359.26,
					276,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					nodeId = 188,
					portId = "BoneTransform"
				}
			},
			fields = {
				fStop = 9,
				cameraId = 90849750,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = true,
				focalDistance = 1357
			},
			flowIn = {
				In = 0,
				StopDof = 1
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 1.6,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.21,
					95.25,
					632.844
				},
				rotationVInput = {
					6.67,
					229.77,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837937,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 131,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 135,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 306,
				param = {
					name = "CHARACTER_APPEARANCE_NAME_X",
					pos = {
						-1200,
						200,
						0
					}
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				Out = {
					{
						nodeId = 136,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 135,
						portId = "closeUIFInput"
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
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 138,
						portId = "In"
					}
				},
				["1"] = {
					{
						nodeId = 140,
						portId = "In"
					}
				},
				["2"] = {
					{
						nodeId = 141,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025052
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Behav_Happy",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 3.38,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Behav_Happy",
					[2] = {
						[1] = false,
						[2] = 5
					}
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						nodeId = 139,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 260250520
			},
			fields = {
				blackScreenIntervalTime = 2,
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400061,
				matchAudioDuration = true,
				duration = 3.62,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0
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
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 1.6,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.395,
					94.9,
					633.217
				},
				rotationVInput = {
					354.2,
					253.7,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837939,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 132,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 1.2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 142,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 27,
			fields = {
				uid = 306,
				param = {
					name = "CHARACTER_APPEARANCE_NAME_Y",
					pos = {
						1200,
						-400,
						0
					}
				}
			},
			flowIn = {
				In = 0,
				closeUIFInput = 1
			},
			flowOut = {
				Out = {
					{
						nodeId = 143,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 3
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 142,
						portId = "closeUIFInput"
					}
				}
			}
		},
		{
			kind = 32,
			fields = {
				eventName = "setBGM",
				eventParam = {
					[1] = "BGM_Story_ChooseXY"
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 15,
			inputs = {
				lookAtEntityStaticIdVInput = 2,
				staticIdVInput = 79379149
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 3,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.395,
					94.9,
					633.217
				},
				rotationVInput = {
					354.2,
					253.7,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90866145,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 147,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 12,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.618,
					95.15,
					632.826
				},
				rotationVInput = {
					7.3,
					272.21,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90866147,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 36,
				blendTimeVInput = 1.6,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.4,
					95.4,
					633
				},
				rotationVInput = {
					13.7,
					223.3,
					359.769
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90877213,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
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
				fovVInput = 38,
				blendTimeVInput = 12,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.368,
					95.35,
					632.974
				},
				rotationVInput = {
					12.97,
					211.5,
					0
				}
			},
			fields = {
				fStop = 9,
				cameraId = 90877203,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 4,
				blendFuncVInput = "EaseIn",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.744,
					95.527,
					633.949
				},
				rotationVInput = {
					11.352,
					223.895,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837958,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 151,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 12,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.744,
					95.527,
					633.949
				},
				rotationVInput = {
					12.7,
					223.3,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837964,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 7,
			fields = {
				dialogueId = 26025037
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 153,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 26025039
			},
			fields = {
				blackScreenIntervalTime = 2,
				anim = "Story_Bind_Nod",
				portCount = 1,
				skipTime = 0,
				npcStaticId = -1,
				npcId = 400109,
				matchAudioDuration = true,
				duration = 4.75,
				disableCamera = false,
				chatType = 3,
				blackScreenPlayType = 0,
				animCfg = {
					[1] = "Story_Bind_Nod",
					[2] = {
						[1] = true,
						[2] = 0
					}
				}
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
		{
			kind = 25,
			fields = {
				condition = {
					"PLAYER_BODY_TYPE",
					1,
					1,
					">=",
					1
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						nodeId = 157,
						portId = "In"
					}
				},
				True = {
					{
						nodeId = 155,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 50,
				blendTimeVInput = 2,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.904,
					95.1,
					633.294
				},
				rotationVInput = {
					354.2,
					239.3,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837891,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 156,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 48,
				blendTimeVInput = 18,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.926,
					95.1,
					633.331
				},
				rotationVInput = {
					354.2,
					237.8,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837934,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 48,
				blendTimeVInput = 2,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.072,
					95.1,
					633.465
				},
				rotationVInput = {
					351.4,
					237.5,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90879546,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 158,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 48,
				blendTimeVInput = 18,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1742.107,
					95.1,
					633.56
				},
				rotationVInput = {
					351.412,
					234.393,
					0.464
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90879553,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 4,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.744,
					95.527,
					633.949
				},
				rotationVInput = {
					11.352,
					223.895,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837852,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 160,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 12,
				blendFuncVInput = "Linear",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.744,
					95.527,
					633.949
				},
				rotationVInput = {
					12.7,
					223.3,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90837950,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 1357
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 21,
			inputs = {
				blendTimeVInput = 2
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 36,
			inputs = {
				retValueInput = 1
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 22,
			flowIn = {
				In = 0
			}
		},
		{
			kind = 4,
			fields = {
				delayTime = 2
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						nodeId = 165,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 38,
				blendTimeVInput = 4,
				blendExponentVInput = 0,
				positionVInput = {
					-1741.124,
					95.8,
					633.617
				},
				rotationVInput = {
					344.6,
					245.4,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 85129676,
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
						nodeId = 166,
						portId = "In"
					}
				}
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendTimeVInput = 11,
				blendFuncVInput = "EaseOut",
				blendExponentVInput = 0,
				positionVInput = {
					-1741.124,
					95.8,
					633.617
				},
				rotationVInput = {
					344.5,
					243.4,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 85159453,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0,
				openDof = false,
				focalDistance = 200
			},
			flowIn = {
				In = 0
			}
		},
		[184] = {
			kind = 59,
			fields = {
				animationCurve = {
					postWrapMode = 8,
					preWrapMode = 8,
					keys = {
						{
							value = 2,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 0,
							outTangent = 0,
							inTangent = 0
						},
						{
							value = 0,
							inWeight = 0,
							weightedMode = 0,
							outWeight = 0,
							time = 1.5,
							outTangent = 0,
							inTangent = 0
						}
					}
				}
			}
		},
		[185] = {
			kind = 9,
			fields = {
				entityType = 0
			}
		},
		[186] = {
			kind = 17,
			inputs = {
				staticIdVInput = 82161089
			},
			fields = {
				entityType = 2
			}
		},
		[187] = {
			kind = 17,
			inputs = {
				staticIdVInput = 79379149,
				boneNameVInput = "Bip001 Head"
			},
			fields = {
				entityType = 2
			}
		},
		[188] = {
			kind = 17,
			inputs = {
				staticIdVInput = 79379146,
				boneNameVInput = "Bip001 Head"
			},
			fields = {
				entityType = 2
			}
		}
	}
}
