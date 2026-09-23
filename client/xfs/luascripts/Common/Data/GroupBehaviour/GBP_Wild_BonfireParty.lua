-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_BonfireParty.lua

local data = {
	minStartRoleNum = 8,
	minHoldRoleNum = 8,
	behavID = "BP_Wild_GroupBehav_BonfireParty",
	CDAfterEnd = 4,
	roleList = {
		{
			roleType = "篝火中心",
			roleCondition = {
				{
					"petPrototypeId",
					1033100
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role3",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role4",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role5",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role6",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role7",
			roleCondition = {
				{
					"petPrototypeId",
					1020100
				}
			}
		},
		{
			roleType = "role8",
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
						"篝火中心"
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
						"role2"
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
						"role3"
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
						"role4"
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
						tPortId = 5
					},
					role = {
						"role5"
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
						tPortId = 6
					},
					role = {
						"role6"
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
						tPortId = 7
					},
					role = {
						"role7"
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
						tPortId = 8
					},
					role = {
						"role8"
					}
				},
				{
					func = "goToNextStage",
					para = "GBPMsg_Common",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty"
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
							0.5
						}
					},
					role = {
						"篝火中心",
						"role2",
						"role3",
						"role4",
						"role5",
						"role6",
						"role7",
						"role8"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty"
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
						"篝火中心"
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
						"role2"
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
						"role3"
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
						"role4"
					}
				},
				{
					para = "GBPMsg_ResPoint07",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
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
					para = "GBPMsg_ResPoint08",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
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
					para = "GBPMsg_ResPoint09",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 7
					},
					role = {
						"role7"
					}
				},
				{
					para = "GBPMsg_ResPoint10",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.5
						}
					},
					extraPara = {
						tPortId = 8
					},
					role = {
						"role8"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty",
								"BP_Wild_GroupBehav_BonfireParty"
							}
						}
					}
				}
			}
		}
	}
}

return data
