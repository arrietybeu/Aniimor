-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetTransmogComponent.lua

local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientPetTransmogComponent = class.Component("ClientPetTransmogComponent")

function ClientPetTransmogComponent:ctor()
	return
end

function ClientPetTransmogComponent:destroy()
	return
end

function ClientPetTransmogComponent:rollTransmog(petId, lockHoles)
	self:serverMsg("RPC_CS_PetCreateTransmogScheme", petId, lockHoles, CallbackHandler(self, "_onRolled"))
end

function ClientPetTransmogComponent:_onRolled(retStatus)
	facade:sendMsgToUI(MessageName.PET_TRANSMOG_ROLL_FINISHED, {
		retStatus = retStatus
	})

	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.PET_TRANSMOG_ROLLED, {
			retStatus = retStatus
		})
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientPetTransmogComponent:saveTempToCustom(petId, tempIndex, imageKey)
	local targetCustomIndex = PetTransmogUtils.getFirstEmptyCustomIndex(petId)

	self:serverMsg("RPC_CS_PetSaveTransmogSchemeToCustom", petId, tempIndex, imageKey or "", CallbackHandler(self, "_onSchemeReplacedAndApplied", targetCustomIndex))
end

function ClientPetTransmogComponent:delCustomScheme(petId, customIndex)
	self:serverMsg("RPC_CS_PetDelTransmogScheme", petId, customIndex, CallbackHandler(self, "_onSchemeListChanged"))
end

function ClientPetTransmogComponent:replaceCustomScheme(petId, tempIndex, customIndex, imageKey)
	self:serverMsg("RPC_CS_PetReplaceCustomTransmogScheme", petId, tempIndex, customIndex, imageKey or "", CallbackHandler(self, "_onSchemeReplacedAndApplied", customIndex))
end

function ClientPetTransmogComponent:useCustomScheme(petId, customIndex)
	self:serverMsg("RPC_CS_PetUseCustomTransmogScheme", petId, customIndex, CallbackHandler(self, "_onSchemeApplied"))
end

function ClientPetTransmogComponent:useCurrTransmogScheme(petId, imageKey)
	local targetCustomIndex = PetTransmogUtils.getFirstEmptyCustomIndex(petId)

	self:serverMsg("RPC_CS_PetUseCurrTransmogScheme", petId, imageKey or "", CallbackHandler(self, "_onSchemeApplied", targetCustomIndex))
end

function ClientPetTransmogComponent:replaceAndUseCurrTransmogScheme(petId, customSchemeIndex, imageKey)
	self:serverMsg("RPC_CS_PetReplaceAndUseCurrTransmogScheme", petId, customSchemeIndex, imageKey or "", CallbackHandler(self, "_onSchemeApplied", customSchemeIndex))
end

function ClientPetTransmogComponent:lockTransmogSchemeHole(petId, lockHoles)
	self:serverMsg("RPC_CS_PetLockTransmogSchemeHole", petId, lockHoles or {})
end

function ClientPetTransmogComponent:setUseItemFlag(petId, flag)
	self:serverMsg("RPC_CS_SetUseItemFlag", petId, flag == true)
end

function ClientPetTransmogComponent:_onSchemeApplied(customIndex, retStatus)
	if retStatus == nil then
		retStatus = customIndex
		customIndex = nil
	end

	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.PET_TRANSMOG_SCHEME_APPLIED)

		local tipDecs

		if customIndex then
			tipDecs = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_SAVE_SUCCESS"), PetTransmogUtils.getCustomSchemeDisplayName(customIndex))
		else
			tipDecs = pg.getGameString("PETTRANSMOGRIFY_CONFIRM_SUCCESS")
		end

		pg.global.ui.tips:showTextTip(tipDecs)
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientPetTransmogComponent:_onSchemeListChanged(retStatus)
	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.PET_TRANSMOG_SCHEME_LIST_CHANGED)
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientPetTransmogComponent:_onSchemeReplacedAndApplied(customIndex, retStatus)
	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.PET_TRANSMOG_SCHEME_LIST_CHANGED)
		facade:sendMsgToUI(MessageName.PET_TRANSMOG_SCHEME_APPLIED)

		local tipDecs = pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_SAVE_SUCCESS"), PetTransmogUtils.getCustomSchemeDisplayName(customIndex))

		pg.global.ui.tips:showTextTip(tipDecs)
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

return ClientPetTransmogComponent
