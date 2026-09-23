-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10291_FentuftJumpFur.lua

local data = {
	minStartRoleNum = 4,
	minHoldRoleNum = 4,
	behavID = "BP_Wild_10291_FentuftJumpFurEvent",
	CDAfterEnd = 0,
	roleList = {
		{
			roleType = "1",
			roleCondition = {
				{
					"horiDistLessThan",
					30
				},
				{
					"petPrototypeId",
					1029100,
					"and"
				}
			}
		},
		{
			roleType = "2",
			roleCondition = {
				{
					"horiDistLessThan",
					30,
					"and"
				},
				{
					"petPrototypeId",
					1029100,
					"and"
				}
			}
		},
		{
			roleType = "3",
			roleCondition = {
				{
					"petPrototypeId",
					1029100,
					"and"
				},
				{
					"horiDistLessThan",
					30,
					"and"
				}
			}
		},
		{
			roleType = "4",
			roleCondition = {
				{
					"petPrototypeId",
					1029100,
					"and"
				},
				{
					"horiDistLessThan",
					30,
					"and"
				}
			}
		}
	},
	stageList = {
		{
			timeout = 60,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonChargeFur",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"1"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "checkEnvObjChemState",
						conditionParamObject = {
							82760930,
							"STATE_ELECTRIC_KEY"
						}
					}
				}
			}
		},
		{
			timeout = 15,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_CommonHappyTest",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"1",
						"2",
						"3",
						"4"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_10291_FentuftJumpFurEvent",
								"BP_Wild_10291_FentuftJumpFurEvent",
								"BP_Wild_10291_FentuftJumpFurEvent",
								"BP_Wild_10291_FentuftJumpFurEvent"
							}
						}
					}
				}
			}
		}
	}
}

return data
