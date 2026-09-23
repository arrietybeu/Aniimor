-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10481_Fahloo\\PBT_Wild_10481_Skill14830900.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10481_Skill14830900 = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10481_Fahloo/PBT_Wild_10481_Skill14830900",
		version = 78,
		properties = {},
		pars = {
			{
				value = "0",
				name = "tSensorTgtId",
				type = "int",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "21",
			properties = {},
			attachments = {
				{
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
					id = "96",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "switchToState",
								params = {
									{
										const = "LOCOMOTION"
									},
									{
										const = -1
									},
									{
										const = ""
									}
								}
							}
						},
						{
							Phase = "Both"
						}
					}
				},
				{
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
					id = "100",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "stopEffectOnTarget",
								params = {
									{
										const = "Eff_Parmon_10481_Bubble"
									},
									{
										const = 0
									}
								}
							}
						},
						{
							Phase = "Both"
						}
					}
				}
			},
			children = {
				{
					node = {
						class = "Action",
						id = "40",
						properties = {
							{
								Method = {
									func = "switchToFly",
									params = {
										{
											const = 0
										},
										{
											const = 2
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
						class = "Action",
						id = "99",
						properties = {
							{
								Method = {
									func = "playEffectOnTarget",
									params = {
										{
											const = "Eff_Parmon_10481_Bubble"
										},
										{
											const = 0
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
						class = "Action",
						id = "65",
						properties = {
							{
								Method = {
									func = "flyToTarget",
									params = {
										{
											field = "tSensorTgtId"
										},
										{
											const = 0
										},
										{
											const = 10
										},
										{
											const = 10
										},
										{
											const = true
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = true
										},
										{
											const = 1
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

return PBT_Wild_10481_Skill14830900
