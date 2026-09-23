-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10021&10024.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10021&10024",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					1002100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1002400
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
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_ResPoint01",
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
						"role1"
					}
				},
				{
					para = "GBPMsg_ResPoint01",
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
						"role2"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10021&10024",
								"BP_Wild_GroupBehav_10021&10024"
							}
						}
					}
				}
			}
		},
		{
			timeout = 25,
			functions = {
				{
					para = "GBPMsg_Common01",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role2"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10021&10024",
								"BP_Wild_GroupBehav_10021&10024"
							}
						}
					}
				}
			}
		},
		{
			timeout = 25,
			functions = {
				{
					para = "GBPMsg_Common03",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common04",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role2"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10021&10024",
								"BP_Wild_GroupBehav_10021&10024"
							}
						}
					}
				}
			}
		}
	}
}

return data
