-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10021WRS.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10021WRS",
	CDAfterEnd = 1,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					1002100
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1002100
				}
			}
		}
	},
	stageList = {
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role1",
						"role2"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 60,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_Common01",
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common02",
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
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 6,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_Common03",
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common04",
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
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		}
	}
}

return data
