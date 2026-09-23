-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_Grassout.lua

local data = {
	behavID = "BP_Wild_GroupBehav_GrassOut",
	CDAfterEnd = 0,
	roleList = {
		{
			roleType = "Role1",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role2",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role3",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "Role4",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
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
						"Role1",
						"Role2",
						"Role3",
						"Role4"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut"
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"Role1"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut"
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"Role2"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut"
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common04",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"Role3"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut"
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common05",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2
						}
					},
					role = {
						"Role4"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut",
								"BP_Wild_GroupBehav_GrassOut"
							}
						}
					}
				}
			}
		}
	}
}

return data
