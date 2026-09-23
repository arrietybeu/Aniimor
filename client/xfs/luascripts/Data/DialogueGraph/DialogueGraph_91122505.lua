-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_91122505.lua

return {
	schema = 1,
	startNodeId = 1,
	dialogueId = 91122505,
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
						portId = "In",
						nodeId = 2
					}
				}
			}
		},
		{
			kind = 25,
			fields = {
				condition = {
					"ACTIVATE_SPECIFIC_MAP_MARKER",
					59419446,
					nil,
					"=",
					0
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				False = {
					{
						portId = "In",
						nodeId = 8
					}
				},
				True = {
					{
						portId = "In",
						nodeId = 3
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
						portId = "In",
						nodeId = 7
					}
				},
				["1"] = {
					{
						portId = "In",
						nodeId = 4
					}
				}
			}
		},
		{
			kind = 1,
			inputs = {
				dialogueIdVInput = 350210500
			},
			fields = {
				skipTime = 0,
				npcStaticId = -1,
				npcId = 0,
				matchAudioDuration = true,
				duration = 2,
				disableCamera = false,
				chatType = 2,
				blackScreenPlayType = 0,
				blackScreenIntervalTime = 2,
				portCount = 1
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				["0"] = {
					{
						portId = "In",
						nodeId = 5
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
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		{
			kind = 47,
			inputs = {
				cancelBlendFovVInput = true,
				fovBlendOutTimeVInput = 2,
				fovBlendOutFuncVInput = "Linear",
				cancelSetPlayerCamShoulderVInput = true,
				cancelModifyYawSpeedRatioVInput = true,
				cancelModifyPitchSpeedRatioVInput = true,
				cancelFocusToTargetVInput = true
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Out = {
					{
						portId = "End",
						nodeId = 0
					}
				}
			}
		},
		{
			kind = 39,
			inputs = {
				fovBlendFuncVInput = "Linear",
				maxLockTimeVInput = 99
			},
			valueIn = {
				faceToTargetVInput = {
					portId = "BoneTransform",
					nodeId = 11
				}
			},
			flowIn = {
				In = 0
			}
		},
		{
			kind = 39,
			inputs = {
				fovBlendFuncVInput = "Linear",
				maxLockTimeVInput = 3
			},
			valueIn = {
				faceToTargetVInput = {
					portId = "BoneTransform",
					nodeId = 12
				}
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				LockTimeOut = {
					{
						portId = "In",
						nodeId = 6
					}
				}
			}
		},
		[11] = {
			kind = 17,
			inputs = {
				staticIdVInput = 91043954
			},
			fields = {
				entityType = 2
			}
		},
		[12] = {
			kind = 17,
			inputs = {
				staticIdVInput = 91043954
			},
			fields = {
				entityType = 2
			}
		}
	}
}
