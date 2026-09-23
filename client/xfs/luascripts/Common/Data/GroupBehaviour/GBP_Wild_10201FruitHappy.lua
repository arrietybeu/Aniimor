-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10201FruitHappy.lua

local data = {
	CDAfterEnd = 3,
	behavID = "BP_Wild_GroupBehav_10201FruitHappy",
	roleList = {
		{
			roleType = "role1"
		},
		{
			roleType = "role2"
		},
		{
			roleType = "role3"
		},
		{
			roleType = "role4"
		},
		{
			roleType = "role5"
		},
		{
			roleType = "role6"
		},
		{
			roleType = "role7"
		}
	},
	stageList = {
		{
			timeout = 30,
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
					role = {
						"role2"
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
					role = {
						"role3"
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
					role = {
						"role4"
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
					role = {
						"role5"
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
					role = {
						"role6"
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
					role = {
						"role7"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
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
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
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
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
								"BP_Wild_GroupBehav_10201FruitHappy",
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
