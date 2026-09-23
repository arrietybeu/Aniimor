-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10501_Cubbo\\PBT_Wild_10501_Dialogue.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10501_Dialogue = {
	behavior = {
		version = 6,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10501_Cubbo/PBT_Wild_10501_Dialogue",
		useForRoute = true,
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				value = "0",
				name = "firstDialogueId"
			},
			{
				const = 0,
				type = "int",
				value = "0",
				name = "lastDialogueId"
			},
			{
				const = 0,
				type = "int",
				value = "0",
				name = "dialogueId"
			},
			{
				const = 0,
				type = "float",
				value = "0",
				name = "tWaitTime"
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "5",
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
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "dialogueId"
								}
							},
							{
								Opr = {
									func = "getRandomInt",
									params = {
										{
											field = "firstDialogueId"
										},
										{
											field = "lastDialogueId"
										}
									}
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "1",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showDialogue",
									params = {
										{
											field = "dialogueId"
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

return PBT_Wild_10501_Dialogue
