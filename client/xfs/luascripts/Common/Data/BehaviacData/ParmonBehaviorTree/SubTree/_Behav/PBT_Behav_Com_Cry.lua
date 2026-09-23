-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_Cry.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Cry = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_Cry",
		version = 16,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				value = "0",
				type = "int",
				const = 0
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
						id = "13",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToTarget",
									params = {
										{
											field = "tTargetActorId"
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
						id = "11",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playSleAnimationFixTime",
									params = {
										{
											const = "Behav_CryStart"
										},
										{
											const = "Behav_CryLoop"
										},
										{
											const = "Behav_CryEnd"
										},
										{
											const = 99999
										},
										{
											const = ""
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

return PBT_Behav_Com_Cry
