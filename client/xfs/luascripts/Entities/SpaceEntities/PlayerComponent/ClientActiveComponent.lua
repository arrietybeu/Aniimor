-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientActiveComponent.lua

local class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientActiveComponent = class.Component("ClientActiveComponent")

function ClientActiveComponent:init(dict)
	self.activityDatas = dict.activityDatas
	self.ActiveClientDatas = {}

	return true
end

function ClientActiveComponent:RPC_SC_GetActivityData(activeDatas)
	self.activityDatas = activeDatas
end

return ClientActiveComponent
