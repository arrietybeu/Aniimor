-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CustomAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CustomAnimation = {
	behavior = {
		useForRoute = true,
		version = 8,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_CustomAnimation",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "tWaitTime",
				value = "0"
			},
			{
				type = "string",
				const = "",
				name = "tAnimationKey",
				value = ""
			},
			{
				type = "float",
				const = 5,
				name = "tAnimationTimeout",
				value = "5"
			},
			{
				type = "string",
				const = "",
				name = "tEmojiBubbleKey",
				value = ""
			},
			{
				type = "float",
				const = 5,
				name = "tEmojiBubbleTimeout",
				value = "5"
			},
			{
				type = "string",
				const = "",
				name = "tTimelineTag",
				value = ""
			},
			{
				type = "bool",
				const = false,
				name = "tNeedLoop",
				value = "false"
			},
			{
				type = "bool",
				const = false,
				name = "tAnimationPlayOnce",
				value = "false"
			},
			{
				type = "bool",
				const = false,
				name = "tEmojiBubbleMustPlayFull",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "tWaitTime"
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
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiBubbleKey"
										},
										{
											field = "tEmojiBubbleTimeout"
										},
										{
											field = "tNeedLoop"
										},
										{
											field = "tEmojiBubbleMustPlayFull"
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
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											field = "tAnimationKey"
										},
										{
											field = "tAnimationTimeout"
										},
										{
											field = "tTimelineTag"
										},
										{
											field = "tNeedLoop"
										},
										{
											field = "tAnimationPlayOnce"
										},
										{
											const = 10
										},
										{
											const = BaseEnum.AIAnimationRootMotionType.Default
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

return PBT_CustomAnimation
