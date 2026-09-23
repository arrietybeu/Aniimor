-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10201FruitHappy_03.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10201FruitHappy",
	CDAfterEnd = 3,
	roleList = {
		{
			roleType = "role1"
		},
		{
			roleType = "role2"
		},
		{
			roleType = "role3"
		}
	},
	stageList = {
		{
			timeout = 30,
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
						"role1"
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
						"role2"
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
						"role3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy"
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
							0
						}
					},
					role = {
						"role1",
						"role2",
						"role3",
						"role4",
						"role5",
						"role6",
						"role7"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy"
							}
						}
					}
				}
			}
		}
	}
}

return data
