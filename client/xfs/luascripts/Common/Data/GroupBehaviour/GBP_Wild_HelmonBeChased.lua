-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_HelmonBeChased.lua

local data = {
	behavID = "BP_Wild_GroupBehav_HelmonBeChased",
	CDAfterEnd = 0.2,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					100210003
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1002200
				},
				{
					"entityTag",
					"TE_Wild_HelmonBeChased_10022"
				}
			}
		},
		{
			roleType = "role3",
			roleCondition = {
				{
					"petPrototypeId",
					1002200
				},
				{
					"entityTag",
					"TE_Wild_HelmonBeChased_10022"
				}
			}
		},
		{
			roleType = "role4",
			roleCondition = {
				{
					"petPrototypeId",
					1002200
				},
				{
					"entityTag",
					"TE_Wild_HelmonBeChased_10022"
				}
			}
		}
	},
	stageList = {
		{
			timeout = 30,
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint02",
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
					para = "GBPMsg_ResPoint03",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint03",
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common01",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint04",
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
					para = "GBPMsg_ResPoint05",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint06",
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common01",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint07",
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
					para = "GBPMsg_ResPoint08",
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
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPoint09",
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
					func = "sendTrigger_Common",
					para = "GBPMsg_Common01",
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
