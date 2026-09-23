-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_SaveHelmon_1v1Chase.lua

local data = {
	behavID = "BP_Wild_GroupBehav_SaveHelmon_1v1Chase",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					100210003
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1002200
				},
				{
					"entityTag",
					"TE_Wild_HelmonBeChased_10022"
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
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 25,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
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
