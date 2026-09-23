-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_GrassTrain.lua

local data = {
	behavID = "BP_Wild_GroupBehav_Train",
	CDAfterEnd = 0,
	roleList = {
		{
			roleType = "Leader",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role1",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role2",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role3",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_ResPoint01_1",
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
						"Leader"
					}
				},
				{
					para = "GBPMsg_ResPoint01_2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Role1",
						"Role2",
						"Role3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train"
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
					para = "GBPMsg_Common02_1",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"Leader"
					}
				},
				{
					para = "GBPMsg_Common02_2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"Role2",
						"Role1"
					}
				},
				{
					para = "GBPMsg_Common02_3",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"Role3"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train",
								"BP_Wild_GroupBehav_Train"
							}
						}
					}
				}
			}
		}
	}
}

return data
