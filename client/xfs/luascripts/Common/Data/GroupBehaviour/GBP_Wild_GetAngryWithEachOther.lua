-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_GetAngryWithEachOther.lua

local data = {
	CDAfterEnd = 2,
	behavID = "BP_Wild_GroupBehav_GetAngryWithEachOther",
	roleList = {
		{
			roleType = "role1"
		},
		{
			roleType = "role2"
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
						"role1",
						"role2"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GetAngryWithEachOther",
								"BP_Wild_GroupBehav_GetAngryWithEachOther"
							}
						}
					}
				}
			}
		},
		{
			timeout = 30,
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
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GetAngryWithEachOther",
								"BP_Wild_GroupBehav_GetAngryWithEachOther"
							}
						}
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
				}
			}
		}
	}
}

return data
