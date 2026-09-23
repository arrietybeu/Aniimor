-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Pet\\PBT_Pet_DefenseOccupy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_DefenseOccupy = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Pet/PBT_Pet_DefenseOccupy",
		agenttype = "PetAgent",
		version = 13,
		useForRoute = false,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "DecoratorLoop",
			id = "11",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "false"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "12",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											const = 60
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

return PBT_Pet_DefenseOccupy
