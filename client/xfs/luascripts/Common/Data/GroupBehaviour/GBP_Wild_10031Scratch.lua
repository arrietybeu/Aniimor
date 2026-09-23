-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10031Scratch.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10031Scratch",
	GroupBehavVisionArea = "visionAreaLow",
	CDAfterEnd = 2,
	minStartRoleNum = 1,
	minHoldRoleNum = 1,
	roleList = {
		{
			roleType = "螳螂",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointManitisGoScratch",
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
						"螳螂"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031Scratch"
							}
						}
					}
				}
			}
		}
	}
}

return data
