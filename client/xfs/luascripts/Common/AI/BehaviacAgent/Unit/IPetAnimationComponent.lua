-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPetAnimationComponent.lua

local class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local EventConst = require("Const.EventConst")
local EBTStatus = enums.EBTStatus
local IPetAnimationComponent = class.Component("IPetAnimationComponent")

function IPetAnimationComponent:showMasterBubble(emojiName, timeout)
	local masterEnt = pg.getEntityByActorId(self:getMasterId())

	if masterEnt then
		masterEnt.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, timeout)
	end

	return EBTStatus.BT_SUCCESS
end

function IPetAnimationComponent:playMasterSound(soundId)
	local masterEnt = pg.getEntityByActorId(self:getMasterId())

	if masterEnt then
		masterEnt:playSoundEvent(soundId)
	end

	return EBTStatus.BT_SUCCESS
end

function IPetAnimationComponent:showPetChatInfo__resetState(resetStateType)
	self.x_showPetChatInfoTimeOut = nil

	local topLogoItem = self.ent:peekTopLogoItem()

	if topLogoItem then
		topLogoItem:hidePetChatInfo()
	end

	self:turnToYaw__resetState(resetStateType)
	self:_removeCustomTimeout("showPetChatInfo")
end

function IPetAnimationComponent:showPetChatInfo(chatId)
	if self.x_showPetChatInfoTimeOut == nil then
		local tRet
		local topLogoItem = self.ent:ensureTopLogoItem("pet_chat")

		if topLogoItem then
			tRet, self.x_showPetChatInfoTimeOut = topLogoItem:showPetChatInfo(chatId)
		end

		if not tRet then
			return EBTStatus.BT_FAILURE
		end
	end

	if self:_checkAndSetCustomTimeout("showPetChatInfo", self.x_showPetChatInfoTimeOut) then
		return EBTStatus.BT_SUCCESS
	end

	self:turnToTarget(self:getMasterId(), false, 0)

	return EBTStatus.BT_RUNNING
end

return IPetAnimationComponent
