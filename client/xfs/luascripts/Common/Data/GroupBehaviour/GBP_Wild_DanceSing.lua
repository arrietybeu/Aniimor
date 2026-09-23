-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_DanceSing.lua

local data = {
	CDAfterEnd = 0,
	behavID = "BP_Wild_GroupBehav_DanceSing",
	roleList = {
		{
			roleType = "dancer1",
			roleCondition = {
				{
					"petPrototypeId",
					1021100
				}
			}
		},
		{
			roleType = "dancer2",
			roleCondition = {
				{
					"petPrototypeId",
					1021100
				}
			}
		},
		{
			roleType = "dancer3",
			roleCondition = {
				{
					"petPrototypeId",
					1021100
				}
			}
		},
		{
			roleType = "dancer4",
			roleCondition = {
				{
					"petPrototypeId",
					1021100
				}
			}
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
					extraPara = {
						tPortId = 1
					},
					role = {
						"dancer1"
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
					extraPara = {
						tPortId = 2
					},
					role = {
						"dancer2"
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
					extraPara = {
						tPortId = 3
					},
					role = {
						"dancer3"
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
					extraPara = {
						tPortId = 4
					},
					role = {
						"dancer4"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing"
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
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
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
						"dancer1",
						"dancer2",
						"dancer3",
						"dancer4"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing"
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
					para = "GBPMsg_ResPoint03",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 1
					},
					role = {
						"dancer1"
					}
				},
				{
					para = "GBPMsg_ResPoint04",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 2
					},
					role = {
						"dancer2"
					}
				},
				{
					para = "GBPMsg_ResPoint05",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 3
					},
					role = {
						"dancer3"
					}
				},
				{
					para = "GBPMsg_ResPoint06",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 4
					},
					role = {
						"dancer4"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing",
								"BP_Wild_GroupBehav_DanceSing"
							}
						}
					}
				}
			}
		}
	}
}

return data
