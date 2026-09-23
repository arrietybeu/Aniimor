-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_CustomLoopAnimationWithPreset.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_CustomLoopAnimationWithPreset = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_CustomLoopAnimationWithPreset",
		agenttype = "CombatAgent",
		version = 5,
		useForRoute = true,
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
			},
			{
				name = "tPresetName",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tLoopCount",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tRenderNameList",
				type = "vector<string>",
				value = "0:",
				const = {}
			},
			{
				name = "tPresetDuration",
				type = "float",
				const = 1,
				value = "1"
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
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playPreset",
									params = {
										{
											field = "selfId"
										},
										{
											field = "tPresetName"
										},
										{
											field = "tPresetDuration"
										},
										{
											const = false
										},
										{
											field = "tLoopCount"
										},
										{
											field = "tRenderNameList"
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
						id = "4",
						class = "Action",
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
						attachments = {
							{
								id = "7",
								effector = true,
								precondition = false,
								class = "Effector",
								transition = false,
								properties = {
									{
										Operator = "Invalid"
									},
									{
										Opl = {
											func = "stopPreset",
											params = {
												{
													field = "selfId"
												},
												{
													field = "tPresetName"
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
									func = "stopPreset",
									params = {
										{
											field = "selfId"
										},
										{
											field = "tPresetName"
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

return PBT_Node_Com_CustomLoopAnimationWithPreset
