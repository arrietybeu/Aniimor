-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_SingInTheStone .lua

local data = {
	behavID = "BP_Wild_GroupBehav_SingInTheStone",
	CDAfterEnd = 1,
	roleList = {
		{
			roleType = "bird1",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				}
			}
		},
		{
			roleType = "bird2",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				}
			}
		},
		{
			roleType = "bird3",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				}
			}
		}
	},
	stageList = {
		{
			timeout = 20,
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
						"bird1",
						"bird2",
						"bird3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone"
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
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
						"bird1"
					}
				},
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
						"bird2"
					}
				},
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
						"bird3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone"
							}
						}
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					func = "sendTrigger_Common",
					para = "GBPMsg_Common01",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"bird1",
						"bird2",
						"bird3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone"
							}
						}
					}
				}
			}
		},
		{
			timeout = 120,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"bird1"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"bird2"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint04",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"bird3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone",
								"BP_Wild_GroupBehav_SingInTheStone"
							}
						}
					}
				}
			}
		}
	}
}

return data
