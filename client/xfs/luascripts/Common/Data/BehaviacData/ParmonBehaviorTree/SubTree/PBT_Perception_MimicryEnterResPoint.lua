-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Perception_MimicryEnterResPoint.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Perception_MimicryEnterResPoint = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Perception_MimicryEnterResPoint",
		version = 27,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tSensorTgtId",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tRandomWaitTime",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "17",
			class = "Action",
			properties = {
				{
					Method = {
						func = "doSendMessage",
						params = {
							{
								field = "selfId"
							},
							{
								const = {}
							},
							{
								const = "Msg_VisionValue_Full_MimicryEnterResPoint"
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

return PBT_Perception_MimicryEnterResPoint
