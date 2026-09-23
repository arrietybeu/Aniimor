-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_LoveAndKiss.lua

local data = {
	CDAfterEnd = 10,
	behavID = "BP_Wild_GroupBehav_LoveAndKiss",
	roleList = {
		{
			roleType = "love1",
			roleCondition = {
				{
					"petPrototypeId",
					1017100
				},
				{
					"horiDistMoreThan",
					0.3
				}
			}
		},
		{
			roleType = "love2",
			roleCondition = {
				{
					"petPrototypeId",
					1017100
				},
				{
					"horiDistLessThan",
					0.3,
					"and"
				}
			}
		}
	},
	stageList = {
		{
			timeout = 30,
			functions = {
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
						"love2"
					}
				},
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
						"love1"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_LoveAndKiss",
								"BP_Wild_GroupBehav_LoveAndKiss"
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"love1",
						"love2"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_LoveAndKiss",
								"BP_Wild_GroupBehav_LoveAndKiss"
							}
						}
					}
				}
			}
		}
	}
}

return data
