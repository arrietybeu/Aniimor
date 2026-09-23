-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10031_Mantis\\PBT_Wild_10031_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10031_Perception_Leave = {
	behavior = {
		version = 26,
		name = "ParmonBehaviorTree/SubTree/_Wild/10031_Mantis/PBT_Wild_10031_Perception_Leave",
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				type = "int",
				name = "tSensorTgtId"
			},
			{
				const = 0,
				value = "0",
				type = "int",
				name = "tTgtId"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "18",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "24",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tSensorTgtId"
								}
							},
							{
								Opr = {
									func = "getPerceptibilityTarget"
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
						id = "19",
						properties = {
							{
								Method = {
									func = "turnToTarget",
									params = {
										{
											field = "tSensorTgtId"
										},
										{
											const = false
										},
										{
											const = 0
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
						id = "66",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											const = 0
										},
										{
											const = 10310900
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
						class = "ReferencedBehavior",
						id = "68",
						properties = {
							{
								ReferenceBehavior = {
									const = "PBT_Perception_Leave"
								}
							},
							{
								subTreeProperties = {}
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

return PBT_Wild_10031_Perception_Leave
