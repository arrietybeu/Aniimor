-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Wild_10501_DreamDialogue.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10501_DreamDialogue = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		version = 18,
		name = "ParmonBehaviorTree/SubTree/PBT_Wild_10501_DreamDialogue",
		properties = {},
		pars = {
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
				name = "tRandomFloat"
			},
			{
				const = 70008552,
				type = "int",
				value = "70008552",
				name = "firstDialogueId"
			},
			{
				const = 70008560,
				type = "int",
				value = "70008560",
				name = "lastDialogueId"
			}
		},
		attachments = {},
		node = {
			class = "SelectorProbability",
			id = "23",
			properties = {
				{
					UntilSuccessOrEnd = false
				}
			},
			attachments = {},
			children = {
				{
					node = {
						class = "DecoratorWeight",
						id = "24",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							},
							{
								Weight = {
									const = 20
								}
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "12",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Assignment",
												id = "22",
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
												class = "Action",
												id = "9",
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
					}
				},
				{
					node = {
						class = "DecoratorWeight",
						id = "25",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							},
							{
								Weight = {
									const = 80
								}
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "Noop",
									id = "26",
									properties = {},
									attachments = {},
									children = {}
								}
							}
						}
					}
				}
			}
		}
	}
}

return PBT_Wild_10501_DreamDialogue
