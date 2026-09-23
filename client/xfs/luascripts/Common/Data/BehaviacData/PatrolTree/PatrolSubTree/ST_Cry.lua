-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_Cry.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Cry = {
	behavior = {
		version = 25,
		agenttype = "CombatAgent",
		name = "PatrolTree/PatrolSubTree/ST_Cry",
		useForRoute = true,
		properties = {},
		pars = {
			{
				name = "cryTimeOut",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tIsLoop",
				value = "false",
				type = "bool",
				const = false
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "7",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Cry"
										},
										{
											const = 7
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
				},
				{
					node = {
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playPhaseAction",
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
											field = "cryTimeOut"
										},
										{
											const = ""
										},
										{
											const = false
										},
										{
											field = "tIsLoop"
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

return ST_Cry
