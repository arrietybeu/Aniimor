-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\DialogueGraph\\DialogueGraph_51220399.lua

return {
	schema = 1,
	startNodeId = 2,
	dialogueId = 51220399,
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
		[2] = {
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
		[3] = {
			kind = 3,
			inputs = {
				blendTimeVInput = 2,
				fovVInput = 46,
				positionVInput = {
					-39.976,
					1.836,
					54.019
				},
				rotationVInput = {
					5.022,
					223.203,
					0
				}
			},
			valueIn = {
				dofTargetVInput = {
					nodeId = 21,
					portId = "BoneTransform"
				}
			},
			fields = {
				openDof = true,
				focalDistance = 469.049,
				fStop = 4,
				cameraId = 71407541,
				visualizeDOF = false,
				squeezeFactor = 1,
				sensorWidth = 360,
				recombineQuality = 0
			},
			flowIn = {
				In = 0
			},
			flowOut = {
				Finish = {
					{
						nodeId = 0,
						portId = "End"
					}
				},
				Out = {
					{
						nodeId = 4,
						portId = "In"
					}
				}
			}
		},
		[4] = {
			kind = 56,
			fields = {
				shakeType = 1,
				cameraShakeItem = {
					shakeDissipation = 28,
					decayTime = 2,
					shakeRadius = -1,
					flags = 0,
					sustainTime = 0.1,
					attackTime = 0,
					holdForever = false,
					playSpace = 0,
					shakeType = 1,
					shakeFrequency = 6,
					shakeRadiusCurve = {
						preWrapMode = 8,
						postWrapMode = 8,
						keys = {
							{
								weightedMode = 0,
								time = 0,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								value = 1
							},
							{
								weightedMode = 0,
								time = 1,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								value = 1
							}
						}
					},
					shakePos = {
						0,
						0,
						0
					},
					noisePosAmplitudes = {
						0,
						0,
						0
					},
					noiseRotAmplitudes = {
						3,
						3,
						3
					},
					shakeFrequencyCurve = {
						preWrapMode = 8,
						postWrapMode = 8,
						keys = {
							{
								weightedMode = 0,
								time = 0,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								value = 1
							},
							{
								weightedMode = 0,
								time = 1,
								outWeight = 0,
								inWeight = 0,
								outTangent = 0,
								inTangent = 0,
								value = 1
							}
						}
					},
					noisePosSeeds = {
						0,
						0,
						0
					},
					noiseRotSeeds = {
						0,
						0,
						0
					}
				}
			},
			flowIn = {
				In = 0
			}
		},
		[21] = {
			kind = 17,
			inputs = {
				boneNameVInput = "Bip001 Head",
				staticIdVInput = 58125111
			},
			fields = {
				entityType = 2
			}
		}
	},
	blackboard = {
		StaticId = 1,
		TargetPosition = {
			1,
			0.5,
			5
		}
	}
}
