-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Behav_Com_Sleep.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Sleep = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Behav_Com_Sleep",
		version = 10,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tSleepTimeout",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tisLoop",
				const = false,
				value = "false",
				type = "bool"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "17",
			properties = {},
			attachments = {
				{
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
					id = "8",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "removeEntityTag",
								params = {
									{
										field = "selfId"
									},
									{
										const = "TE_Par_Sleep"
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
					id = "10",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "setVisionAreaOverride",
								params = {
									{
										const = "visionAreaDefault"
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
						id = "16",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{
											field = "selfId"
										},
										{
											const = "TE_Par_Sleep"
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
						id = "12",
						properties = {
							{
								Method = {
									func = "setVisionAreaOverride",
									params = {
										{
											const = "visionAreaLow"
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
						id = "11",
						properties = {
							{
								Method = {
									func = "playPhaseAction",
									params = {
										{
											const = "Behav_SleepStart"
										},
										{
											const = "Behav_SleepLoop"
										},
										{
											const = "Behav_SleepEnd"
										},
										{
											field = "tSleepTimeout"
										},
										{
											const = ""
										},
										{
											const = false
										},
										{
											field = "tisLoop"
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
						id = "13",
						properties = {
							{
								Method = {
									func = "setVisionAreaOverride",
									params = {
										{
											const = "visionAreaDefault"
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
				}
			}
		}
	}
}

return PBT_Behav_Com_Sleep
