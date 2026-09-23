-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Test\\PBT_Test_Jenkins.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Test_Jenkins = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Test/PBT_Test_Jenkins",
		agenttype = "CombatAgent",
		version = 11,
		properties = {},
		pars = {},
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
									func = "moveToPos",
									params = {
										{
											const = {}
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = 2
										},
										{
											const = BaseEnum.SpeedRateType.Mid
										},
										{
											const = 3
										},
										{
											const = BaseEnum.PathFindType.Auto
										},
										{
											const = false
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
						id = "4",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToPosList",
									params = {
										{
											const = {}
										},
										{
											const = 0
										},
										{
											const = true
										},
										{
											const = 0
										},
										{
											const = BaseEnum.SpeedRateType.Slow
										},
										{
											const = 0
										},
										{
											const = {}
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
				}
			}
		}
	}
}

return PBT_Test_Jenkins
