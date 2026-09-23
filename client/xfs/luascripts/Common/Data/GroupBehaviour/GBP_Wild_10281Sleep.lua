-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10281Sleep.lua

local data = {
	CDAfterEnd = 10,
	behavID = "BP_Wild_GroupBehav_10281Sleep",
	roleList = {
		{
			roleType = "碎岩仔",
			roleCondition = {
				{
					"petPrototypeId",
					1028100
				}
			}
		},
		{
			roleType = "烟囱蚁1",
			roleCondition = {
				{
					"petPrototypeId",
					1043100
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_ResPointGotosleep",
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
						"碎岩仔"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sleep",
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
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_CommonStartSleep",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"碎岩仔"
					}
				},
				{
					para = "GBPMsg_ResPointgo1",
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
						"烟囱蚁1"
					}
				},
				{
					para = "GBPMsg_Common",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep"
							}
						}
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_CommonAwake",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"碎岩仔"
					}
				},
				{
					para = "GBPMsg_CommonLeave",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"烟囱蚁1"
					}
				},
				{
					para = "GBPMsg_Common",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep",
								"BP_Wild_GroupBehav_10281Sleep"
							}
						}
					}
				}
			}
		}
	}
}

return data
