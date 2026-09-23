-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10501_Cubbo\\PBT_Wild_10503_Combat_Prepare.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10503_Combat_Prepare = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Wild/10501_Cubbo/PBT_Wild_10503_Combat_Prepare",
		agenttype = "CombatAgent",
		version = 25,
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				name = "tSensorTgtId",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "22",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "27",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tSensorTgtId"
								}
							},
							{
								Opr = {
									func = "getPerceptibilityTarget"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "23",
						class = "Action",
						properties = {
							{
								Method = {
									func = "hideQuestionMark"
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "25",
						class = "Action",
						properties = {
							{
								Method = {
									func = "addBuff",
									params = {
										{
											const = 1145129
										},
										{
											const = -1
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "24",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Furious"
										},
										{
											const = 5
										},
										{
											const = false
										},
										{
											const = false
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "26",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											const = 0.3
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "29",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToTarget",
									params = {
										{
											field = "tSensorTgtId"
										},
										{
											const = 4
										},
										{
											const = 20
										},
										{
											const = false
										},
										{
											const = false
										},
										{
											const = false
										},
										{
											const = 10
										},
										{
											const = BaseEnum.MoveUpdateLevel.Once
										},
										{
											const = BaseEnum.PathFindType.Auto
										},
										{
											const = BaseEnum.SpeedRateType.Fast
										},
										{
											const = 0
										},
										{
											const = false
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "28",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "tSensorTgtId"
										},
										{
											const = 10800351
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = BaseEnum.CastAbilitySourceType.Normal
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				}
			}
		}
	}
}

return PBT_Wild_10503_Combat_Prepare
