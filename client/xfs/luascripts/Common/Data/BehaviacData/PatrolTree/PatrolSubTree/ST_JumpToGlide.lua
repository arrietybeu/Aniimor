-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_JumpToGlide.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_JumpToGlide = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		version = 9,
		name = "PatrolTree/PatrolSubTree/ST_JumpToGlide",
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "float",
				name = "jumpTime"
			},
			{
				value = "0",
				const = 0,
				type = "float",
				name = "glideStartTime"
			},
			{
				value = "false",
				const = false,
				type = "bool",
				name = "IsVerticalJump"
			}
		},
		attachments = {},
		node = {
			id = "5",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "9",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									field = "IsVerticalJump"
								}
							},
							{
								Opr = {
									const = true
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "7",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playJumpGlideAction",
									params = {
										{
											const = "Jump"
										},
										{
											field = "jumpTime"
										},
										{
											field = "glideStartTime"
										},
										{
											const = 0
										},
										{
											const = 0
										},
										{
											const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
										},
										{
											const = 10
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
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playJumpGlideAction",
									params = {
										{
											const = "AI_JumpInRun"
										},
										{
											field = "jumpTime"
										},
										{
											field = "glideStartTime"
										},
										{
											const = 0
										},
										{
											const = 5
										},
										{
											const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
										},
										{
											const = 10
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

return ST_JumpToGlide
