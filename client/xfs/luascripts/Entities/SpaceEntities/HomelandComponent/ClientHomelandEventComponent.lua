-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandEventComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local ClientHomelandEventComponent = Class.Component("ClientHomelandEventComponent")

function ClientHomelandEventComponent:getPetHomeEventInsId(petId)
	if string.isNilOrEmpty(petId) or not self.petHomeEventInsIdMap then
		return ""
	end

	return self.petHomeEventInsIdMap[petId] or ""
end

function ClientHomelandEventComponent:_onPetHomeEventChanged(petId)
	facade:sendMsgToUI(MessageName.HOMELAND_PET_EVENT_STATE_CHANGED, {
		petId = petId
	})

	local ent = pg.getEntity(petId)

	if ent then
		ent:postComponentMethod("onHomelandAIPlanChanged")
		ent:postComponentMethod("onHomeEventChanged")
		ent.eventEmitter:emit(EventConst.HOMELAND_ACTION_STATE_CHANGED, {})
	end
end

function ClientHomelandEventComponent:on_petHomeEventInsIdMap_entry_added(petId)
	self:_onPetHomeEventChanged(petId)
end

function ClientHomelandEventComponent:on_petHomeEventInsIdMap_entry_deleted(petId)
	self:_onPetHomeEventChanged(petId)
end

function ClientHomelandEventComponent:on_petHomeEventInsIdMap_value_changed(ov, nv, petId)
	self:_onPetHomeEventChanged(petId)
end

function ClientHomelandEventComponent:on_eventOwnerLoginDone_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("homeEvent onEventOwnerLoginDoneChanged, ov=%s, nv=%s", ov, nv)
	end

	self:checkAndShowLoginEventList()
end

function ClientHomelandEventComponent:on_homeEventMap_solvedTs_changed(oldVal, newVal, eventId)
	local pets = pg.space.pets

	for petId in pairs(pets) do
		local petEntity = pg.getEntity(petId)

		if petEntity then
			petEntity.eventEmitter:emit(EventConst.HOMELAND_ACTION_STATE_CHANGED, {})
		end
	end
end

function ClientHomelandEventComponent:ownerPlayerJoinHomeland(player)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("homeEvent ownerPlayerJoinHomeland, player=%s", player:repr())
	end

	self:checkAndShowLoginEventList()
end

function ClientHomelandEventComponent:checkAndShowLoginEventList()
	if not self.eventOwnerLoginDone or not self:isSelfHomeland(pg.me) or not pg.me.simulateOutputMapReady then
		return
	end

	local lastLeaveHomelandTs = pg.me.lastLeaveHomelandTs
	local offlineTime = Time.secondCache - lastLeaveHomelandTs

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		local eventInsIds = self.homeEventMap:getLoginEventInsIds(lastLeaveHomelandTs)

		self.logger:debug("homeEvent owner login welcome, offlineTime=%d, eventInsIds=%s", offlineTime, inspect(eventInsIds))
	end

	if lastLeaveHomelandTs > 0 then
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_PET_ACTION, {
			type = 0
		})
	end
end

return ClientHomelandEventComponent
