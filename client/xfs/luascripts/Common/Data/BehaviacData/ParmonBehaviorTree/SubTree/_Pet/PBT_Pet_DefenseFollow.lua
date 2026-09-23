-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Pet\\PBT_Pet_DefenseFollow.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_DefenseFollow = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Pet/PBT_Pet_DefenseFollow",
		agenttype = "PetAgent",
		version = 9,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "8",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "selfId"
										},
										{
											const = 10270401
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = true
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
				},
				{
					node = {
						id = "9",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "selfId"
										},
										{
											const = 10270411
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = true
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
				},
				{
					node = {
						id = "10",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "selfId"
										},
										{
											const = 10270421
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = true
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

return PBT_Pet_DefenseFollow
