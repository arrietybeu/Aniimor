-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_SheepHappyChase.lua

local data = {
	CDAfterEnd = 1,
	behavID = "BP_Wild_GroupBehav_SheepHappyChase",
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role3",
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role4",
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role5",
			roleCondition = {
				{
					"petPrototypeId",
					1026100
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
						"role1",
						"role2",
						"role3",
						"role4",
						"role5"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"",
								"",
								"",
								""
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
					para = "GBPMsg_ResPoint02",
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
						"role1"
					}
				},
				{
					para = "GBPMsg_ResPoint03",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.2
						}
					},
					extraPara = {
						tPortId = 2
					},
					role = {
						"role2"
					}
				},
				{
					para = "GBPMsg_ResPoint04",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.4
						}
					},
					extraPara = {
						tPortId = 3
					},
					role = {
						"role3"
					}
				},
				{
					para = "GBPMsg_ResPoint05",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.6
						}
					},
					extraPara = {
						tPortId = 4
					},
					role = {
						"role4"
					}
				},
				{
					para = "GBPMsg_ResPoint06",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.8
						}
					},
					extraPara = {
						tPortId = 5
					},
					role = {
						"role5"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
								"",
								"",
								"",
								""
							}
						}
					}
				}
			}
		}
	}
}

return data
