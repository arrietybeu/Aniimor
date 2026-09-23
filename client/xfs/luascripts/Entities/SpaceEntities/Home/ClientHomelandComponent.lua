-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomelandComponent.lua

local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientHomelandComponent = Class.Component("ClientHomelandComponent")

function ClientHomelandComponent:init(dict)
	if self.isClientEnt then
		self.homeTemplateId = dict.homeTemplateId
		self.ornamentId = dict.ornamentId
		self.areaId = dict.areaId or 0
	end

	self.isHomeTrash = Utils.isHomeTrashOrnament(self.homeTemplateId)

	return true
end

function ClientHomelandComponent:start()
	if self.ornamentId and self.ornamentId ~= 0 then
		pg.game.home:registerHomeEnt(self.ornamentId, self)
	end
end

function ClientHomelandComponent:EVENT_onModelLoaded()
	if self.ornamentId and self.ornamentId ~= 0 then
		pg.game.home:registerShadowLight(self.ornamentId, self)
	end
end

function ClientHomelandComponent:destroy()
	if self.ornamentId and self.ornamentId ~= 0 then
		pg.game.home:unregisterHomeEnt(self.ornamentId, self)
		pg.game.home:unregisterShadowLight(self.ornamentId)
	end
end

function ClientHomelandComponent:getHomelandConfigData()
	if self.homeTemplateId then
		return HomeObjectData[self.homeTemplateId] or {}
	end

	return {}
end

function ClientHomelandComponent:canEntEdit()
	return Utils.checkHomeObjectEditable(self.homeTemplateId)
end

function ClientHomelandComponent:getOrnamentInfo()
	return pg.space.ornament[self.ornamentId]
end

function ClientHomelandComponent:EVENT_OnAddExtraDebugInfo(extraInfo)
	table.insert(extraInfo, "ornamentId:" .. self.ornamentId)
end

function ClientHomelandComponent:EVENT_onEntityPositionChanged()
	pg.game.home:onOrnamentPositionChanged(self.ornamentId, self)
end

function ClientHomelandComponent:RPC_SC_OnOrnamentPositionChanged()
	if self.onEntityPositionChanged then
		self:onEntityPositionChanged()
	end
end

function ClientHomelandComponent:on_scaleRatios_changed(old, new)
	if pg.logDebug() then
		self.logger:debug("ClientHomelandComponent scaleRatios changed, old=%s, new=%s", inspect(old), inspect(new))
	end
end

return ClientHomelandComponent
