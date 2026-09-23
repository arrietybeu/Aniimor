-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_FlyStopGrab.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_FlyStopGrab = {
	behavior = {
		version = 18,
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_FlyStopGrab",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "15",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "20",
						class = "DecoratorAlwaysSuccess",
						properties = {
							{
								DecorateWhenChildEnds = "true"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "14",
									class = "Action",
									properties = {
										{
											Method = {
												func = "flyStopGrab",
												params = {
													{
														const = 5
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
				},
				{
					node = {
						id = "18",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											const = 0.5
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

return PBT_Node_Com_FlyStopGrab
