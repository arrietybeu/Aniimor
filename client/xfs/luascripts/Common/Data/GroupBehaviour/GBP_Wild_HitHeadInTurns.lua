-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_HitHeadInTurns.lua

local data = {
	behavID = "BP_Wild_GroupBehav_HitHeadInTurns",
	CDAfterEnd = 10,
	roleList = {
		{
			roleType = "xiu1",
			roleCondition = {
				{
					"petPrototypeId",
					1017100
				}
			}
		},
		{
			roleType = "xiu2",
			roleCondition = {
				{
					"petPrototypeId",
					1017100
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
						"xiu1",
						"xiu2"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_HitHeadInTurns",
								"BP_Wild_GroupBehav_HitHeadInTurns"
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
					para = "GBPMsg_Common02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"xiu1"
					}
				},
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_Common03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"xiu2"
					}
				},
				{
					func = "goToNextStage",
					para = "GBPMsg_Common",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_HitHeadInTurns",
								"BP_Wild_GroupBehav_HitHeadInTurns"
							}
						}
					}
				}
			}
		}
	}
}

return data
