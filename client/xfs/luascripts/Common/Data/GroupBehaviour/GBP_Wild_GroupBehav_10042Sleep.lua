-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_GroupBehav_10042Sleep.lua

local data = {
	minHoldRoleNum = 3,
	behavID = "BP_Wild_GroupBehav_10042Sleep",
	GroupBehavVisionArea = "visionAreaDefault",
	CDAfterEnd = 10,
	minStartRoleNum = 3,
	roleList = {
		{
			roleType = "冰莹龙",
			roleCondition = {
				{
					"petPrototypeId",
					1004302
				}
			}
		},
		{
			roleType = "顽皮鱼1",
			roleCondition = {
				{
					"petPrototypeId",
					1004202
				}
			}
		},
		{
			roleType = "顽皮鱼2",
			roleCondition = {
				{
					"petPrototypeId",
					1004202
				}
			}
		},
		{
			roleType = "顽皮鱼3",
			roleCondition = {
				{
					"petPrototypeId",
					1004202
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappyChase",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"冰莹龙",
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep"
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
					para = "GBPMsg_CommonWakeUp",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"冰莹龙",
						"顽皮鱼1",
						"顽皮鱼2",
						"顽皮鱼3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep",
								"BP_Wild_GroupBehav_10042Sleep"
							}
						}
					}
				}
			}
		}
	}
}

return data
