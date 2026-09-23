-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10031JumpOverRiver.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10031JumpOverRiver",
	GroupBehavVisionArea = "visionAreaLow",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "小螳螂1",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "小螳螂2",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "小螳螂3",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "吃瓜的螳螂1",
			roleCondition = {
				{
					"staticId"
				},
				{
					"petPrototypeId",
					1003100,
					"and"
				}
			}
		},
		{
			roleType = "吃瓜的螳螂2",
			roleCondition = {
				{
					"petPrototypeId",
					1003100
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
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver"
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
						"小螳螂1"
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
						"小螳螂2"
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
						tPortId = 3
					},
					role = {
						"小螳螂3"
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
						tPortId = 4
					},
					role = {
						"吃瓜的螳螂1"
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
						tPortId = 5
					},
					role = {
						"吃瓜的螳螂2"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver",
								"BP_Wild_GroupBehav_10031JumpOverRiver"
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
						"小螳螂1"
					}
				},
				{
					para = "GBPMsg_ResPointDoPatrol2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					role = {
						"小螳螂2"
					}
				},
				{
					para = "GBPMsg_ResPointDoPatrol3",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							5
						}
					},
					role = {
						"小螳螂3"
					}
				},
				{
					para = "GBPMsg_ResPointChat1",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"吃瓜的螳螂1"
					}
				},
				{
					para = "GBPMsg_ResPointChat2",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"吃瓜的螳螂2"
					}
				}
			}
		}
	}
}

return data
