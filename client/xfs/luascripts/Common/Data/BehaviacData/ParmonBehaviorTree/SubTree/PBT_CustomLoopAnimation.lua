-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CustomLoopAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CustomLoopAnimation = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_CustomLoopAnimation",
		version = 9,
		useForRoute = true,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tWaitTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tEmojiBubbleKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tEmojiBubbleTimeout",
				type = "float",
				const = 5,
				value = "5"
			},
			{
				name = "tAnimationStartKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationLoopKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationEndKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationTimeout",
				type = "float",
				const = 5,
				value = "5"
			},
			{
				name = "tTimelineTag",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tNeedLoop",
				type = "bool",
				const = false,
				value = "false"
			},
			{
				name = "tAnimationPlayOnce",
				type = "bool",
				const = false,
				value = "false"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "2",
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
						class = "Action",
						id = "3",
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
						class = "Action",
						id = "4",
						properties = {
							{
								Method = {
									func = "playPhaseAction",
									params = {
										{
											field = "tAnimationStartKey"
										},
										{
											field = "tAnimationLoopKey"
										},
										{
											field = "tAnimationEndKey"
										},
										{
											field = "tAnimationTimeout"
										},
										{
											field = "tTimelineTag"
										},
										{
											field = "tAnimationPlayOnce"
										},
										{
											field = "tNeedLoop"
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

return PBT_CustomLoopAnimation
