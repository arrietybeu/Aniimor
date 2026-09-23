-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarOrnamentComponent.lua

local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientHomeCarOrnamentComponent")
local ClientHomeCarOrnamentComponent = Class.Component("ClientHomeCarOrnamentComponent")

function ClientHomeCarOrnamentComponent:init(dict)
	if self.isClientEnt then
		self.homeTemplateId = dict.homeTemplateId
		self.ornamentId = dict.ornamentId
		self.areaId = dict.areaId or 0
		self.playerUID = dict.playerUID
	end

	if self.ornamentId and self.ornamentId ~= 0 and self.playerUID then
		self.carGroup = pg.game.homeCar:getHomeCarGroup(self.playerUID)

		if not self.carGroup then
			logger:error("carGroup is nil:", self.className, self.playerUID, self.ornamentId)
		end
	end

	return true
end

function ClientHomeCarOrnamentComponent:isSelfHomeCar()
	return self.playerUID == pg.me.uid
end

function ClientHomeCarOrnamentComponent:start()
	if self.carGroup then
		self.carGroup:registerHomeCarEnt(self.ornamentId, self)
	end

	local _h = ClientHomeCarOrnamentComponent._platformHooks

	if _h and _h.start then
		_h.start(self)
	end
end

function ClientHomeCarOrnamentComponent:destroy()
	local _h = ClientHomeCarOrnamentComponent._platformHooks

	if _h and _h.destroy then
		_h.destroy(self)
	end

	if self.carGroup then
		self.carGroup:unregisterHomeCarEnt(self.ornamentId, self)

		self.carGroup = nil
	end
end

function ClientHomeCarOrnamentComponent:canEntEdit()
	return true
end

function ClientHomeCarOrnamentComponent:getHomelandConfigData()
	if self.homeTemplateId then
		return HomeObjectData[self.homeTemplateId] or {}
	end

	return {}
end

function ClientHomeCarOrnamentComponent:EVENT_OnAddExtraDebugInfo(extraInfo)
	table.insert(extraInfo, "ornamentId:" .. self.ornamentId)
end

function ClientHomeCarOrnamentComponent:onHomeCarObjectPositionChanged()
	if self.homeGroup then
		self.homeGroup:onOrnamentPositionChanged(self.ornamentId)
	end
end

function ClientHomeCarOrnamentComponent:RPC_SC_OnOrnamentPositionChanged()
	if self.onEntityPositionChanged then
		self:onEntityPositionChanged()
	end
end

function ClientHomeCarOrnamentComponent:on_scaleRatios_changed(old, new)
	if pg.logDebug() then
		self.logger:debug("ClientHomeCarOrnamentComponent scaleRatios changed, old=%s, new=%s", inspect(old), inspect(new))
	end

	if new and self.setScale then
		local scaleBase = HomeLandUtils.ORNAMENT_SCALE_INT_BASE
		local scale = Vector3((new[1] or scaleBase) / scaleBase, (new[2] or scaleBase) / scaleBase, (new[3] or scaleBase) / scaleBase)

		self:setScale(scale)
	end
end

return ClientHomeCarOrnamentComponent
