-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_DashToTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_DashToTarget = {
	behavior = {
		version = 31,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_DashToTarget",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "66",
			class = "Parallel",
			properties = {
				{
					ChildFinishPolicy = "CHILDFINISH_LOOP"
				},
				{
					ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
				},
				{
					FailurePolicy = "FAIL_ON_ONE"
				},
				{
					SuccessPolicy = "SUCCEED_ON_ALL"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "62",
						class = "Action",
						properties = {
							{
								Method = {
									func = "dashToTarget",
									params = {
										{
											field = "tgt"
										},
										{
											const = 0
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
						id = "65",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToTarget",
									params = {
										{
											field = "tgt"
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
				}
			}
		}
	}
}

return PBT_DashToTarget
