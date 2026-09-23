-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientShadowComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ClientShadowComponent = Class.Component("ClientShadowComponent")

function ClientShadowComponent:EVENT_AddEComponent()
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_SHADOW)
	self:addEModelComponent(CommonConst.COMPONENT_VOXEL)
end

function ClientShadowComponent:OpenShadow(mainEnt, offset)
	if not self:hasEModelComponent(CommonConst.COMPONENT_INDEX_SHADOW) then
		return
	end

	self.eModel.shadowFollowEntity = mainEnt.eModel
	self.eModel.shadowPosOffset = offset

	self.eModel:OpenShadow(CommonConst.COMPONENT_INDEX_SHADOW)
end

function ClientShadowComponent:CloseShadow()
	self.eModel:CloseShadow(CommonConst.COMPONENT_INDEX_SHADOW)
end

function ClientShadowComponent:destroy()
	self.shadowComponent = nil
end

return ClientShadowComponent
