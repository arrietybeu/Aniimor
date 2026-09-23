-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10431Carry.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10431Carry",
	GroupBehavVisionArea = "visionAreaLow",
	CDAfterEnd = 0.1,
	roleList = {
		{
			roleType = "领头蚁",
			roleCondition = {
				{
					"staticId"
				}
			}
		},
		{
			roleType = "排第二个",
			roleCondition = {
				{
					"staticId"
				}
			}
		},
		{
			roleType = "排第三个",
			roleCondition = {
				{
					"staticId"
				}
			}
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointGO",
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
						"领头蚁"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry"
							}
						}
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointGO",
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
						"排第二个"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointGO",
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
						"排第三个"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDoPatrol1",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"领头蚁"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry"
							}
						}
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDoPatrol2",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"排第二个"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDoPatrol3",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"排第三个"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointCarry01",
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
						"领头蚁"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry"
							}
						}
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointCarry02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							4
						}
					},
					extraPara = {
						tPortId = 5
					},
					role = {
						"排第二个"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointCarry03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							8
						}
					},
					extraPara = {
						tPortId = 6
					},
					role = {
						"排第三个"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointBack01",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"领头蚁"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry"
							}
						}
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointBack02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"排第二个"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointBack03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"排第三个"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDrop01",
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
						"领头蚁"
					}
				},
				{
					func = "goToNextStage",
					para = "",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry",
								"BP_Wild_GroupBehav_10431Carry"
							}
						}
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDrop02",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					extraPara = {
						tPortId = 2
					},
					role = {
						"排第二个"
					}
				},
				{
					func = "sendTrigger_ResPoint",
					para = "GBPMsg_ResPointDrop03",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							6
						}
					},
					extraPara = {
						tPortId = 3
					},
					role = {
						"排第三个"
					}
				}
			}
		}
	}
}

return data
