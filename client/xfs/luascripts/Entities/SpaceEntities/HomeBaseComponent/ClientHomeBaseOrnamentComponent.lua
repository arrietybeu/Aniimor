-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeBaseComponent\\ClientHomeBaseOrnamentComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Const.EventConst")
local OrnamentCodec = require("Common.Homeland.OrnamentCodec")
local OrnamentSingleData = require("CustomTypes.OrnamentSingleData")
local ClientHomeBaseOrnamentComponent = Class.Component("ClientHomeBaseOrnamentComponent")

function ClientHomeBaseOrnamentComponent:init()
	self.homeSpace = Utils.isHomeland(self) and self or self.space
	self.ornament = {}

	self:_loadOrnamentFromBinaryData()

	return true
end

function ClientHomeBaseOrnamentComponent:_loadOrnamentFromBinaryData()
	local ornament = self.ornament
	local failedCount = 0

	for ornamentId, text in pairs(self.ornamentBinaryData) do
		local ornamentInfo = self:_decodeOrnament(ornamentId, text)

		if ornamentInfo then
			ornament[ornamentId] = ornamentInfo
		else
			failedCount = failedCount + 1
		end
	end

	if failedCount > 0 then
		self.logger:error("_loadOrnamentFromBinaryData skipped %d broken ornaments", failedCount)
	end
end

function ClientHomeBaseOrnamentComponent:_decodeOrnament(ornamentId, text)
	local info, err = OrnamentCodec.decode(text)

	if not info then
		self.logger:error("decode ornament failed, ornamentId=%s, err=%s", tostring(ornamentId), tostring(err))

		return nil
	end

	return OrnamentSingleData.new(info)
end

function ClientHomeBaseOrnamentComponent:on_ornament_binary_changed(ov, nv, key)
	local ornamentInfo = self:_decodeOrnament(key, nv)

	if not ornamentInfo then
		return
	end

	self.ornament[key] = ornamentInfo

	self:onOrnamentDataChanged(key, ornamentInfo)
end

function ClientHomeBaseOrnamentComponent:on_ornament_binary_added(k, v)
	local ornamentInfo = self:_decodeOrnament(k, v)

	if not ornamentInfo then
		return
	end

	self.ornament[k] = ornamentInfo

	self:onOrnamentDataAdded(k, ornamentInfo)
end

function ClientHomeBaseOrnamentComponent:on_ornament_binary_delete(k, v)
	self.ornament[k] = nil

	self:onOrnamentDataDeleted(k)
end

function ClientHomeBaseOrnamentComponent:onOrnamentDataAdded(ornamentId, ornamentInfo)
	return
end

function ClientHomeBaseOrnamentComponent:onOrnamentDataChanged(ornamentId, ornamentInfo)
	return
end

function ClientHomeBaseOrnamentComponent:onOrnamentDataDeleted(ornamentId)
	return
end

function ClientHomeBaseOrnamentComponent:changeOrnamentSwitch(ornamentId, isOpen, callback)
	isOpen = isOpen or false

	local homeEntity = HomeLandUtils.getHomeEntity(self)
	local ownerUid = homeEntity and homeEntity.ownerUid or pg.me.uid
	local localCallback = callback or function(noticeId, noticeArgs)
		if pg.logDebug() then
			self.logger:debug("ClientHomeBaseOrnamentComponent:changeOrnamentSwitch callback, noticeId=%s, noticeArgs=%s", tostring(noticeId), inspect(noticeArgs))
		end
	end

	pg.me:serverMsg("RPC_CS_InteractOrnamentSwitch", ornamentId, isOpen, ownerUid, localCallback)
end

function ClientHomeBaseOrnamentComponent:on_ornament_switch_open_added(k, v)
	if pg.logDebug() then
		self.logger:debug("ClientHomeBaseOrnamentComponent:on_ornament_switch_open_added, k=%s, v=%s", tostring(k), tostring(v))
	end

	self:_notifyOrnamentSwitchChanged(k, true)
end

function ClientHomeBaseOrnamentComponent:on_ornament_switch_open_delete(k, v)
	if pg.logDebug() then
		self.logger:debug("ClientHomeBaseOrnamentComponent:on_ornament_switch_open_delete, k=%s, v=%s", tostring(k), tostring(v))
	end

	self:_notifyOrnamentSwitchChanged(k, false)
end

function ClientHomeBaseOrnamentComponent:_notifyOrnamentSwitchChanged(ornamentId, isOpen)
	local ornamentEnt

	if pg.game.home then
		ornamentEnt = pg.game.home:getHomeEntity(ornamentId)
	end

	if not ornamentEnt and self.carGroup and self.carGroup.ornamentEntities then
		ornamentEnt = self.carGroup.ornamentEntities[ornamentId]
	end

	if ornamentEnt and ornamentEnt.onOrnamentSwitchChanged then
		ornamentEnt:onOrnamentSwitchChanged(isOpen)
	end
end

return ClientHomeBaseOrnamentComponent
