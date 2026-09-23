-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\InteractModel.lua

local PetData = require("Data.pet_data")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InteractData = require("Data.interact_data")
local AbilityConst = require("Common.Const.AbilityConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local InteractModel = Class.LightClass("InteractModel", UIModel)

InteractModel.INTERACT_ITEM_NORMAL = 1
InteractModel.INTERACT_ITEM_PRAY = 1

function InteractModel:checkHasReportAward()
	local rewards = pg.me.catchPetsReportReward or {}

	return table.nums(rewards) > 0
end

function InteractModel:getInteractItemState(unitType, btnInfo)
	if unitType == InteractionConst.INTERACTION_TYPE_NPC_FUNC then
		if self:checkHasReportAward() then
			return self.INTERACT_ITEM_NORMAL
		else
			return self.INTERACT_ITEM_PRAY
		end
	end

	return self.INTERACT_ITEM_NORMAL
end

function InteractModel:setSwitchCtrlInfo(info)
	self.switchGlobalId = info.switchGlobalId
	self.abilityIndex = info.abilityIndex
end

function InteractModel:getSwitchCtrlBtnStyle()
	if not self.switchGlobalId then
		return {}
	end

	local styleId

	if self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB then
		styleId = 19
	elseif self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_WATERFALL then
		styleId = 83
	elseif self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE then
		styleId = 20
	elseif self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM then
		styleId = 21
	end

	if not styleId then
		return {}
	end

	local pet = pg.me:getPetInfo(self.switchGlobalId)
	local iconId = ""
	local hpRatio = 0
	local petCustomName = ""
	local targetPlayerName = ""
	local targetUid, targetPlayerInfo

	if pet then
		local templateId = pet.templateId
		local petData = PetData[templateId]

		iconId = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON) or ""
		hpRatio = pet.hpRatio
		petCustomName = pet.customName or ""
	end

	local targetEntity = pg.getEntity and pg.getEntity(self.switchGlobalId) or nil

	if targetEntity and targetEntity.playerName ~= nil and targetEntity.playerName ~= "" then
		targetPlayerName = targetEntity.playerName
		targetUid = targetEntity.uid or targetEntity.playerId

		local chatSystem = pg.game and pg.game.chat or nil

		if chatSystem and chatSystem.getPlayerInfo and targetUid ~= nil and targetUid ~= "" then
			targetPlayerInfo = chatSystem:getPlayerInfo(targetUid)
		end

		if type(targetPlayerInfo) ~= "table" then
			targetPlayerInfo = {
				uid = targetUid,
				playerName = targetPlayerName
			}
		end
	end

	return {
		iconId = iconId,
		actionName = styleId and InteractData[styleId].actionName or "",
		hotkeyType = InteractData[styleId].hotkeyType,
		hpRatio = hpRatio,
		specialAbilityIndex = self.abilityIndex,
		switchGlobalId = self.switchGlobalId,
		petCustomName = petCustomName,
		targetPlayerName = targetPlayerName,
		targetUid = targetUid,
		targetPlayerInfo = targetPlayerInfo,
		ownerUid = pg.me and pg.me.uid or nil
	}
end

function InteractModel:getQuickCaptureBtnStyle()
	return InteractData[InteractionConst.STYLE_CONST.QUICK_CAPTURE]
end

function InteractModel:getQuickCaptureDis()
	return self:getQuickCaptureBtnStyle().interactiveDist
end

return InteractModel
