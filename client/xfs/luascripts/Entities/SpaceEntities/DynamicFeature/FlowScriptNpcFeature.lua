-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\FlowScriptNpcFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local FlowScriptNpcFeature = Class.LiteClass("FlowScriptNpcFeature", iFeature)

function FlowScriptNpcFeature:EVENT_OnModelRefreshed()
	return
end

function FlowScriptNpcFeature:onMasterModelLoaded()
	if self.master.eModel then
		self.master.eModel:SendNpcStateChangeEvent(self.master:getSpecialStateId(), true)
	end
end

function FlowScriptNpcFeature:onMasterSpecialStateUpdate()
	if self.master.eModel then
		self.master.eModel:SendNpcStateChangeEvent(self.master:getSpecialStateId(), false)
	end
end

return FlowScriptNpcFeature
