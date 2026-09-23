-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10281Sneak.lua

local data = {
	CDAfterEnd = 0.1,
	behavID = "BP_Wild_GroupBehav_10281Sneak",
	GroupBehavVisionArea = "visionAreaLow",
	roleList = {
		{
			roleType = "炽焰兽",
			roleCondition = {
				{
					"petPrototypeId",
					1028200
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "碎岩仔1",
			roleCondition = {
				{
					"petPrototypeId",
					1028100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "碎岩仔2",
			roleCondition = {
				{
					"petPrototypeId",
					1028100
				},
				{
					"staticId",
					"and"
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_ResPointGO1",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 1
					},
					role = {
						"炽焰兽"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointGO2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 2
					},
					role = {
						"碎岩仔1"
					}
				},
				{
					para = "GBPMsg_ResPointGO3",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 3
					},
					role = {
						"碎岩仔2"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_Commonjianghua",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"炽焰兽"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak"
							}
						}
					}
				},
				{
					para = "GBPMsg_Commonshoudao",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"碎岩仔1",
						"碎岩仔2"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_CommonSleep",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					role = {
						"炽焰兽"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak",
								"BP_Wild_GroupBehav_10281Sneak"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointGoPatrol1",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"碎岩仔1"
					}
				},
				{
					para = "GBPMsg_ResPointGoPatrol2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							8
						}
					},
					role = {
						"碎岩仔2"
					}
				}
			}
		}
	}
}

return data
