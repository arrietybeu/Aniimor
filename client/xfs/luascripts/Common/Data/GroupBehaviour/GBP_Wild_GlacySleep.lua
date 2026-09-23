-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_GlacySleep.lua

local data = {
	minStartRoleNum = 4,
	minHoldRoleNum = 3,
	behavID = "BP_Wild_GroupBehav_GlacySleep",
	CDAfterEnd = 5,
	roleList = {
		{
			roleType = "莹冰龙",
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
			notMustNeed = true,
			roleType = "顽皮鱼1",
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
			notMustNeed = true,
			roleType = "顽皮鱼2",
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
			notMustNeed = true,
			roleType = "顽皮鱼3",
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
					para = "GBPMsg_CommonGlacyGoSleep",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"莹冰龙"
					}
				},
				{
					para = "GBPMsg_CommonDoPatrol",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"莹冰龙",
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					para = "GBPMsg_CommonHappy1",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							10
						}
					},
					role = {
						"顽皮鱼1"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
					para = "GBPMsg_CommonHappy2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼2"
					}
				},
				{
					para = "GBPMsg_CommonHappy3",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
					para = "GBPMsg_CommonHappy",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					para = "GBPMsg_CommonHappy",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"顽皮鱼1"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
					para = "GBPMsg_CommonPlay1",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼1"
					}
				},
				{
					para = "GBPMsg_CommonPlay2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"顽皮鱼2"
					}
				},
				{
					para = "GBPMsg_CommonPlay3",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							4
						}
					},
					role = {
						"顽皮鱼3"
					}
				},
				{
					para = "GBPMsg_CommonGlacyWakeUp",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							20
						}
					},
					role = {
						"莹冰龙"
					}
				},
				{
					para = "GBPMsg_CommonScare",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							23.84
						}
					},
					role = {
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
			timeout = 15,
			functions = {
				{
					para = "GBPMsg_CommonCry",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					para = "GBPMsg_CommonLookAround",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"莹冰龙"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
			timeout = 60,
			functions = {
				{
					para = "GBPMsg_CommonBack1",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼1"
					}
				},
				{
					para = "GBPMsg_CommonBack2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1.5
						}
					},
					role = {
						"顽皮鱼2"
					}
				},
				{
					para = "GBPMsg_CommonBack3",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1.5
						}
					},
					role = {
						"顽皮鱼3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
			timeout = 30,
			functions = {
				{
					para = "GBPMsg_CommonGlacyGoSleep",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"莹冰龙"
					}
				},
				{
					para = "GBPMsg_CommonDoPatrol",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
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
