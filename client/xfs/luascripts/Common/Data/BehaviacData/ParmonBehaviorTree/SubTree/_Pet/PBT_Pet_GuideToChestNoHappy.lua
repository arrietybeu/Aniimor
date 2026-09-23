-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Pet\\PBT_Pet_GuideToChestNoHappy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_GuideToChestNoHappy = {
	behavior = {
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/_Pet/PBT_Pet_GuideToChestNoHappy",
		version = 7,
		useForRoute = false,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tTargetActorId",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "tStopDist",
				value = "0.2",
				const = 0.2
			},
			{
				type = "float",
				name = "tMaxTimeout",
				value = "5",
				const = 5
			},
			{
				type = "bool",
				name = "tFaceTarget",
				value = "false",
				const = false
			},
			{
				type = "float",
				name = "tSpeed",
				value = "0",
				const = 0
			},
			{
				type = "MoveUpdateLevel",
				name = "tMoveUpdateLevel",
				value = "Once",
				const = BaseEnum.MoveUpdateLevel.Once
			},
			{
				type = "PathFindType",
				name = "tPathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "moveToTarget",
						params = {
							{
								field = "guideTargetActorId"
							},
							{
								field = "tStopDist"
							},
							{
								field = "tMaxTimeout"
							},
							{
								const = false
							},
							{
								const = false
							},
							{
								field = "tFaceTarget"
							},
							{
								field = "tSpeed"
							},
							{
								field = "tMoveUpdateLevel"
							},
							{
								field = "tPathFindType"
							},
							{
								const = BaseEnum.SpeedRateType.Slow
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
	}
}

return PBT_Pet_GuideToChestNoHappy
