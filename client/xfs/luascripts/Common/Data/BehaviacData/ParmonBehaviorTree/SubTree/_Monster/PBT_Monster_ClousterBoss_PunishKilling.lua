-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Monster\\PBT_Monster_ClousterBoss_PunishKilling.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Monster_ClousterBoss_PunishKilling = {
	behavior = {
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/_Monster/PBT_Monster_ClousterBoss_PunishKilling",
		version = 14,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "4",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "15",
						class = "Compute",
						properties = {
							{
								Operator = "Add"
							},
							{
								Opl = {
									field = "CounterInt_1"
								}
							},
							{
								Opr1 = {
									field = "CounterInt_1"
								}
							},
							{
								Opr2 = {
									const = 1
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "17",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Angry"
										},
										{
											const = 4
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

return PBT_Monster_ClousterBoss_PunishKilling
