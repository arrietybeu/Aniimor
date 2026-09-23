-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10431Run.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10431Run",
	GroupBehavVisionArea = "visionAreaDefault",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "role01",
			roleCondition = {
				{
					"petPrototypeId",
					11043100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "role02",
			roleCondition = {
				{
					"petPrototypeId",
					11043100
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
			timeout = 20,
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
						"role01",
						"role02"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Run",
								"BP_Wild_GroupBehav_10431Run",
								"BP_Wild_GroupBehav_10431Run",
								"BP_Wild_GroupBehav_10431Run"
							}
						}
					}
				}
			}
		},
		{
			timeout = 40,
			functions = {
				{
					para = "GBPMsg_Common01",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role01"
					}
				},
				{
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							4
						}
					},
					role = {
						"role02"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Run",
								"BP_Wild_GroupBehav_10431Run"
							}
						}
					}
				}
			}
		},
		{
			timeout = 60,
			functions = {
				{
					para = "GBPMsg_ResPoint02",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role01"
					}
				},
				{
					para = "GBPMsg_ResPoint03",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role02"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Run",
								"BP_Wild_GroupBehav_10431Run"
							}
						}
					}
				}
			}
		}
	}
}

return data
