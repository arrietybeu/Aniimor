-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_CollectiveSing.lua

local data = {
	minStartRoleNum = 4,
	minHoldRoleNum = 4,
	behavID = "BP_Wild_GroupBehav_CollectiveSing",
	CDAfterEnd = 4,
	roleList = {
		{
			roleType = "主唱",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018500,
					"or"
				},
				{
					"petPrototypeId",
					1018101,
					"or"
				},
				{
					"petPrototypeId",
					1018501,
					"or"
				},
				{
					"petPrototypeId",
					1018502,
					"or"
				}
			}
		},
		{
			notMustNeed = true,
			roleType = "附和1",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018101,
					"or"
				}
			}
		},
		{
			notMustNeed = true,
			roleType = "附和2",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018101,
					"or"
				}
			}
		},
		{
			notMustNeed = true,
			roleType = "附和3",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018101,
					"or"
				}
			}
		},
		{
			notMustNeed = true,
			roleType = "附和4",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018101,
					"or"
				}
			}
		},
		{
			notMustNeed = true,
			roleType = "附和5",
			roleCondition = {
				{
					"petPrototypeId",
					1018100
				},
				{
					"petPrototypeId",
					1018101,
					"or"
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
						"主唱"
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
					role = {
						"附和1",
						"附和2",
						"附和3",
						"附和4",
						"附和5"
					}
				},
				{
					para = "GBPMsg_Common",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing"
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
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"主唱",
						"附和1",
						"附和2",
						"附和4",
						"附和3",
						"附和5"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing"
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
					para = "GBPMsg_Common03",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"主唱"
					}
				},
				{
					para = "GBPMsg_Common04",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"附和1"
					}
				},
				{
					para = "GBPMsg_Common05",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"附和2"
					}
				},
				{
					para = "GBPMsg_Common06",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"附和3"
					}
				},
				{
					para = "GBPMsg_Common07",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"附和4"
					}
				},
				{
					para = "GBPMsg_Common08",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"附和5"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing",
								"BP_Wild_GroupBehav_CollectiveSing"
							}
						}
					}
				}
			}
		}
	}
}

return data
