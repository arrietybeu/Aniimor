-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Idle_Temp_LSJ.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Idle_Temp_LSJ = {
	behavior = {
		version = 16,
		useForRoute = false,
		agenttype = "WxAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Idle_Temp_LSJ",
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tNoIdleSpProb",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "20",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "21",
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
											const = "IdleMsgTrigger"
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
				},
				{
					node = {
						id = "22",
						class = "Action",
						properties = {
							{
								Method = {
									func = "switchToState",
									params = {
										{
											field = "IdleMotionState"
										},
										{
											const = -1
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
				},
				{
					node = {
						id = "56",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											const = 0.1
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

return PBT_Idle_Temp_LSJ
