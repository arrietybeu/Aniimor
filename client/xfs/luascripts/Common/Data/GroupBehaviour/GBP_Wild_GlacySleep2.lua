-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_GlacySleep2.lua

local data = {
	minStartRoleNum = 4,
	minHoldRoleNum = 4,
	behavID = "BP_Wild_GroupBehav_GlacySleep",
	CDAfterEnd = 25,
	roleList = {
		{
			roleType = "Glacy",
			roleCondition = {
				{
					"horiDistLessThan",
					30
				},
				{
					"petPrototypeId",
					1004302,
					"and"
				}
			}
		},
		{
			roleType = "Pranky1",
			roleCondition = {
				{
					"horiDistLessThan",
					30,
					"and"
				},
				{
					"petPrototypeId",
					1004202,
					"and"
				}
			}
		},
		{
			roleType = "Pranky2",
			roleCondition = {
				{
					"petPrototypeId",
					1004202
				},
				{
					"horiDistLessThan",
					30,
					"and"
				}
			}
		},
		{
			roleType = "Pranky3",
			roleCondition = {
				{
					"petPrototypeId",
					1004202
				},
				{
					"horiDistLessThan",
					30,
					"and"
				}
			}
		}
	},
	stageList = {
		{
			timeout = 60,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonGlacyGoSleep",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Glacy"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappy1",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							15
						}
					},
					role = {
						"Pranky1"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"BP_Wild_GroupBehav_GlacySleep",
								"",
								""
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappy2",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Pranky2"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappy3",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Pranky3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"",
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep"
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappy",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Pranky2",
						"Pranky3"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappy",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"Pranky1"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"BP_Wild_GroupBehav_GlacySleep",
								"",
								""
							}
						}
					}
				}
			}
		},
		{
			timeout = 60,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonPlay1",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Pranky1"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonPlay2",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"Pranky2"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonPlay3",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					role = {
						"Pranky3"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonGlacyWakeUp",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							15
						}
					},
					role = {
						"Glacy"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GlacySleep",
								"",
								"",
								""
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonCry",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"Pranky1",
						"Pranky2",
						"Pranky3"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonLookAround",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							5
						}
					},
					role = {
						"Glacy"
					}
				},
				{
					func = "goToNextStage",
					para = "GBPMsg_Common",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep"
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonBack1",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Pranky1"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonBack2",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1.5
						}
					},
					role = {
						"Pranky2"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonBack3",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1.5
						}
					},
					role = {
						"Pranky3"
					}
				},
				{
					func = "goToNextStage",
					para = "GBPMsg_CommonGlacyGoSleep",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep",
								"BP_Wild_GroupBehav_GlacySleep"
							}
						}
					}
				}
			}
		},
		{
			timeout = 15,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonGlacyGoSleep",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Glacy"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GlacySleep",
								"",
								"",
								""
							}
						}
					}
				}
			}
		}
	}
}

return data
