-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\GroupBehaviour\\GBP_Wild_SkippySlide.lua

local data = {
	behavID = "BP_Wild_GroupBehav_SkippySlide",
	CDAfterEnd = 3,
	roleList = {
		{
			roleType = "role1",
			roleCondition = {
				{
					"petPrototypeId",
					1004100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "role2",
			roleCondition = {
				{
					"petPrototypeId",
					1004100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "role3",
			roleCondition = {
				{
					"petPrototypeId",
					1004100
				},
				{
					"staticId",
					"and"
				}
			}
		},
		{
			roleType = "role4",
			roleCondition = {
				{
					"petPrototypeId",
					1004100
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
							0.4
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
							0.6
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
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_GroupBehav_SkippySlide",
								"BP_Wild_GroupBehav_SkippySlide",
								"BP_Wild_GroupBehav_SkippySlide",
								"BP_Wild_GroupBehav_SkippySlide"
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
					para = "GBPMsg_ResPoint02",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							0
						}
					},
					extraPara = {
						tPortId = 0
					},
					role = {
						"role1"
					}
				},
				{
					para = "GBPMsg_ResPoint02",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							5
						}
					},
					role = {
						"role2"
					}
				},
				{
					para = "GBPMsg_ResPoint02",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							10
						}
					},
					role = {
						"role3"
					}
				},
				{
					para = "GBPMsg_ResPoint02",
					func = "sendTrigger_ResPoint",
					condition = {
						conditionName = "delayTime",
						conditionParamObject = {
							15
						}
					},
					role = {
						"role4"
					}
				},
				{
					para = "",
					func = "goToNextStage",
					condition = {
						conditionName = "behavEnd",
						conditionParamList = {
							{
								"BP_Wild_10041_SkippySlide",
								"BP_Wild_10041_SkippySlide",
								"BP_Wild_10041_SkippySlide",
								"BP_Wild_10041_SkippySlide"
							}
						}
					}
				}
			}
		}
	}
}

return data
