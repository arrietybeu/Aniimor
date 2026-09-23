-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_CustomLoopAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_CustomLoopAnimation = {
	behavior = {
		agenttype = "CombatAgent",
		useForRoute = true,
		name = "PatrolTree/PatrolSubTree/ST_CustomLoopAnimation",
		version = 5,
		properties = {},
		pars = {
			{
				const = 0,
				name = "tWaitTime",
				value = "0",
				type = "float"
			},
			{
				const = "",
				name = "tEmojiBubbleKey",
				value = "",
				type = "string"
			},
			{
				const = 5,
				name = "tEmojiBubbleTimeout",
				value = "5",
				type = "float"
			},
			{
				const = "",
				name = "tAnimationStartKey",
				value = "",
				type = "string"
			},
			{
				const = "",
				name = "tAnimationLoopKey",
				value = "",
				type = "string"
			},
			{
				const = "",
				name = "tAnimationEndKey",
				value = "",
				type = "string"
			},
			{
				const = 5,
				name = "tAnimationTimeout",
				value = "5",
				type = "float"
			},
			{
				const = false,
				name = "tIsLoop",
				value = "false",
				type = "bool"
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
											field = "tIsLoop"
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
											const = ""
										},
										{
											const = false
										},
										{
											field = "tIsLoop"
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

return ST_CustomLoopAnimation
