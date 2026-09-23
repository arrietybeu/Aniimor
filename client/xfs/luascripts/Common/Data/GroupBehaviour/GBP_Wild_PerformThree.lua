-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_PerformThree.lua

local data = {
	CDAfterEnd = 4,
	behavID = "BP_Wild_GroupBehav_PerformThree",
	roleList = {
		{
			roleType = "role1"
		},
		{
			roleType = "role2"
		},
		{
			roleType = "role3"
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
						"role1"
					}
				},
				{
					para = "GBPMsg_ResPoint01",
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
					para = "GBPMsg_ResPoint01",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0.2
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
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
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
						"role1"
					}
				},
				{
					para = "GBPMsg_Common01",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1.5
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_Common04",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common05",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common02",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2.5
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_Common04",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common05",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_Common03",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common03",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							2.5
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		},
		{
			timeout = 20,
			functions = {
				{
					para = "GBPMsg_Common04",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_Common05",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							1
						}
					},
					role = {
						"role2",
						"role3"
					}
				},
				{
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd"
					}
				}
			}
		}
	}
}

return data
