-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_WolfChaseSheep.lua

local data = {
	behavID = "BP_Wild_GroupBehav_WolfChaseSheep",
	CDAfterEnd = 1,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					1005100
				}
			}
		},
		{
			roleType = "role2",
			notMustNeed = true,
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role3",
			notMustNeed = true,
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role4",
			notMustNeed = true,
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role5",
			notMustNeed = true,
			roleCondition = {
				{
					"petPrototypeId",
					1026100
				}
			}
		},
		{
			roleType = "role6",
			notMustNeed = true,
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
			timeout = 40,
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
					extraPara = {
						tPortId = 1
					},
					role = {
						"role1"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
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
						"role2"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
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
						"role3"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
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
						"role4"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
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
						"role5"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint01",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 6
					},
					role = {
						"role6"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					role = {
						"role1"
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
						"role2"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint04",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.1
						}
					},
					role = {
						"role3"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint05",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.2
						}
					},
					role = {
						"role4"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint06",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.3
						}
					},
					role = {
						"role5"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint07",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.4
						}
					},
					role = {
						"role6"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"",
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
