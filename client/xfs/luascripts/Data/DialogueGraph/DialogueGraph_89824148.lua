-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_89824148.lua

return {
	schema = "v4",
	startNodeId = 0,
	dialogueId = 89824148,
	nodes = {
		[0] = {
			kind = 8,
			flowOut = {
				Start = {
					{
						portId = "In",
						nodeId = 1
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
					enhanceAmbientIntensity = false,
					exitCatchMode = false,
					resetAllActions = false,
					blockEvent = false,
					modeType = 0,
					blockCameraZoom = false,
					hideTopLogo = false,
					hideMarkShare = false,
					hideInteractionSign = false,
					showHud = false,
					hideAllUI = false,
					disableSpaceFollow = true
				}
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202016
			},
			fields = {
				npcStaticId = 2,
				npcId = 400204,
				duration = 6,
				chatType = 10,
				blackScreenPlayType = 1
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 3
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 6202017
			},
			fields = {
				npcStaticId = 2,
				npcId = 400204,
				duration = 4,
				chatType = 10,
				blackScreenPlayType = 1
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 3,
			inputs = {
				fovVInput = 35,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-452.53,
					38.117,
					585.72
				},
				rotationVInput = {
					355.659,
					134.449,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 90487893,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
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
			kind = 3,
			inputs = {
				blendTimeVInput = 7,
				fovVInput = 35,
				blendFuncVInput = "EaseInOut",
				blendExponentVInput = 2,
				positionVInput = {
					-452.539,
					38.28,
					585.728
				},
				rotationVInput = {
					355.659,
					134.449,
					0
				}
			},
			fields = {
				fStop = 4,
				cameraId = 89926602,
				squeezeFactor = 1,
				sensorWidth = 360,
				focalDistance = 200
			},
			flowIn = {
				In = true
			}
		},
		{
			kind = 64
		}
	}
}
