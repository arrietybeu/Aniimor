-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_10031TeachInvisible.lua

local data = {
	behavID = "BP_Wild_GroupBehav_10031TeachInvisible",
	GroupBehavVisionArea = "visionAreaLow",
	CDAfterEnd = 0,
	roleList = {
		{
			roleType = "大螳螂",
			roleCondition = {
				{
					"petPrototypeId",
					1003200
				},
				{
					"staticId",
					"and"
				}
			}
		},
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
		}
	},
	stageList = {
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_ResPointGoRoute",
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
						"大螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible"
							}
						}
					}
				},
				{
					para = "GBPMsg_ResPointGoRoute",
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
						"小螳螂1"
					}
				},
				{
					para = "GBPMsg_ResPointGoRoute",
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
						"小螳螂2"
					}
				},
				{
					para = "GBPMsg_ResPointGoRoute",
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
						"小螳螂3"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_CommonStartChat",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"大螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible"
							}
						}
					}
				},
				{
					para = "GBPMsg_CommonCopyThat",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							5
						}
					},
					role = {
						"小螳螂2",
						"小螳螂1",
						"小螳螂3"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_Common10032StartInvisible",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"大螳螂"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible"
							}
						}
					}
				},
				{
					para = "GBPMsg_CommonChat1",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							3
						}
					},
					role = {
						"小螳螂1",
						"小螳螂2"
					}
				},
				{
					para = "GBPMsg_CommonChat2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							4
						}
					},
					role = {
						"小螳螂3"
					}
				}
			}
		},
		{
			timeout = -1,
			functions = {
				{
					para = "GBPMsg_Common10031StartInvisible1",
					func = "sendTrigger_Common",
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
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible",
								"BP_Wild_GroupBehav_10031TeachInvisible"
							}
						}
					}
				},
				{
					para = "GBPMsg_CommonEndChat",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							11
						}
					},
					role = {
						"大螳螂"
					}
				},
				{
					para = "GBPMsg_Common10031StartInvisible2",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"小螳螂2"
					}
				},
				{
					para = "GBPMsg_Common10031StartInvisible3",
					func = "sendTrigger_Common",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					role = {
						"小螳螂3"
					}
				}
			}
		}
	}
}

return data
