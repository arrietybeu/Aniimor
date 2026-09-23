-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10291JumpTest.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10291JumpTest",
	GroupBehavVisionArea = "visionAreaLow",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "天使耶-跳1",
			roleCondition = {
				{
					"petPrototypeId",
					1029100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "天使耶-跳2",
			roleCondition = {
				{
					"petPrototypeId",
					1029100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "天使耶-山羊",
			roleCondition = {
				{
					"petPrototypeId",
					1029100
				},
				{
					"staticId",
					"and"
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_Common",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10291JumpTest",
								"BP_Wild_GroupBehav_10291JumpTest",
								"BP_Wild_GroupBehav_10291JumpTest"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointGO",
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
						"天使耶-跳1"
					}
				},
				{
					para = "GBPMsg_ResPointGO",
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
						"天使耶-跳2"
					}
				},
				{
					para = "GBPMsg_ResPointGO",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 0
					},
					role = {
						"天使耶-山羊"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_Common",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10291JumpTest",
								"BP_Wild_GroupBehav_10291JumpTest",
								"BP_Wild_GroupBehav_10291JumpTest"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointDoPatrol1",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"天使耶-跳1"
					}
				},
				{
					para = "GBPMsg_ResPointDoPatrol2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"天使耶-跳2"
					}
				},
				{
					para = "GBPMsg_ResPointgoat",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"天使耶-跳1",
						"天使耶-跳2",
						"天使耶-山羊"
					}
				}
			}
		}
	}
}

return data
