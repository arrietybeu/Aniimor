-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_TestRabbit.lua

local data = {
	minStartRoleNum = 5,
	minHoldRoleNum = 5,
	behavID = "BP_Wild_GroupBehav_1v1Argue",
	CDAfterEnd = 30,
	roleList = {
		{
			roleType = "role1",
			notMustNeed = true,
			roleCondition = {
				{
					"petPrototypeId",
					10021
				},
				{
					"horiDistLessThan",
					0.5,
					"and"
				},
				{
					"entityTag",
					"TE_Par_Fly",
					"and"
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					10021
				}
			}
		},
		{
			roleType = "role3",
			roleCondition = {
				{
					"petPrototypeId",
					10021
				},
				{
					"horiDistMoreThan",
					0.5,
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
					para = "GBPMsg_Common01",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					editorPara = {
						paraName = "GBPMsg_Common",
						paraValue = "01"
					},
					role = {
						"role1",
						"role2",
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
								"BP_Wild_XXX",
								"BP_Wild_XXA",
								"BP_Wild_XXB"
							}
						}
					},
					editorPara = {}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					editorPara = {
						paraName = "GBPMsg_ResPoint",
						paraValue = "02"
					},
					extraPara = {
						tPointId = 1,
						tPortId = 0
					},
					role = {
						"role1",
						"role2",
						"role3"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "checkEnvObjChemState",
						conditionParamObject = {
							110252,
							"STATE_AFLAME_KEY"
						}
					},
					editorPara = {}
				}
			}
		}
	}
}

return data
