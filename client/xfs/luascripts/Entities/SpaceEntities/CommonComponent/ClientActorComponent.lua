-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientActorComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local LxGeometry = require("Common.Ability.LxGeometry")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local ClientActorComponent = class.Component("ClientActorComponent", ClientAoiComponent)

function ClientActorComponent:RPC_SC_UpdateBodyInfo(bodySize, bodyHeight)
	self.bodySize = bodySize
	self.bodyHeight = bodyHeight

	if self.updateHitBoxParam then
		self:updateHitBoxParam()
	end
end

function ClientActorComponent:onCampChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onCampChange", old, new)
	end
end

function ClientActorComponent:onEnterSpace()
	if self.clientVisible ~= nil and not self.clientVisible then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_SERVER, false)

		if self.pauseBt then
			self:pauseBt(AiConst.PauseBtReason.ClientVisible)
		end
	else
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_SERVER, true)

		if self.resumeBt then
			self:resumeBt(AiConst.PauseBtReason.ClientVisible)
		end
	end
end

function ClientActorComponent:onClientVisibleChange(old, new)
	if self.clientVisible ~= nil and not self.clientVisible then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_SERVER, false)

		if self.pauseBt then
			self:pauseBt(AiConst.PauseBtReason.ClientVisible)
		end
	else
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_SERVER, true)

		if self.resumeBt then
			self:resumeBt(AiConst.PauseBtReason.ClientVisible)
		end
	end
end

return ClientActorComponent
