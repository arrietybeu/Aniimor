-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10031TrickCrab.lua

local data = {
	CDAfterEnd = 30,
	minStartRoleNum = 2,
	minHoldRoleNum = 2,
	behavID = "BP_Wild_GroupBehav_10031TrickCrab",
	GroupBehavVisionArea = "visionAreaLow",
	roleList = {
		{
			roleType = "螳螂",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
				}
			}
		},
		{
			roleType = "螃蟹",
			roleCondition = {
				{
					"petPrototypeId",
					1016100
				}
			}
		}
	},
	stageList = {
		{
			timeout = 60,
			functions = {
				{
					para = "GBPMsg_ResPointManitisGoFirst",
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
						"螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TrickCrab",
								"BP_Wild_GroupBehav_10031TrickCrab"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointCrabGoFirst",
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
						"螃蟹"
					}
				}
			}
		},
		{
			timeout = 60,
			functions = {
				{
					para = "GBPMsg_ResPointManitisGoSecond",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					extraPara = {
						tPortId = 3
					},
					role = {
						"螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TrickCrab",
								"BP_Wild_GroupBehav_10031TrickCrab"
							}
						}
					}
				},
				{
					para = "GBPMsg_CommonCrabSleep",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"螃蟹"
					}
				}
			}
		},
		{
			timeout = 60,
			functions = {
				{
					para = "GBPMsg_CommonManitisScare",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TrickCrab",
								"BP_Wild_GroupBehav_10031TrickCrab"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointCrabAngry",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 4
					},
					role = {
						"螃蟹"
					}
				}
			}
		}
	}
}

return data
