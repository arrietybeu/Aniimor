-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientEducationComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local SysConfigData = require("Data.sys_config_data")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local ConflictTypes = require("Common.ConflictTypes")
local EventConst = require("Common.Const.EventConst")
local ClientEducationComponent = class.Component("ClientEducationComponent")

function ClientEducationComponent:RPC_SC_OnAddPlayerExp(level, exp, old_level, old_exp, add_exp)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnAddPlayerExp oldLv%f, newLv%f, oldExp%f, newExp%f", old_level, level, exp, old_exp)
	end

	facade:sendMsgToUI(MessageName.PLAYER_EXP_CHANGE, {
		oldLevel = old_level,
		oldExp = old_exp,
		newLevel = level,
		curExp = exp,
		addExp = add_exp
	})

	if old_level ~= level then
		pg.me:postComponentMethod("OnPetProud")
	end
end

function ClientEducationComponent:RPC_SC_OnPlayerSkillUnlockOrUp(skillId, skLv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnSkillUnlockOrUp skillId%f, skLv%f", skillId, skLv)
	end

	local pstdd = PlayerSkillTreeData[skillId]

	if (pstdd == nil or ToInt(pstdd.column) == 0 or ToInt(pstdd.row) == 0) and (SysConfigData.GrabEggSkill == nil or not table.contains(SysConfigData.GrabEggSkill, skillId)) then
		return
	end

	LuaUIUtils.parseSkillBubbleMessage({
		isLearn = skLv == 1,
		skLv = skLv,
		skillId = skillId
	})
end

function ClientEducationComponent:RPC_SC_CombatPetLearnSkill(petId, abilityParamId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_CombatPetLearnSkill petId%f, abilityParamId%f", petId, abilityParamId)
	end

	local pet = pg.getEntity(petId)

	LuaUIUtils.parseSkillBubbleMessage({
		isLearn = true,
		petTmpId = pet.templateId,
		skillId = AbilityUtils.getAbilityIdByParamId(pet.templateId, abilityParamId)
	})
end

function ClientEducationComponent:on_playerName_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_playerName_changed>>> ov", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_NAME_CHANGE)
end

function ClientEducationComponent:on_headIcon_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_headIcon_changed>>> ov", oldV, newV)
	end

	if pg.game and pg.game.chat then
		pg.game.chat:refreshSelfPlayerData()
	end

	if self.isMainPlayer then
		pg.global.showBubbleMessageRaw(pg.getGameString("EXCHANGE_SUCCESS"))
	end

	facade:SendMessageCommand(MessageName.PLAYER_ICON_CHANGE)
end

function ClientEducationComponent:on_headIconDicts_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onHeadIconDicts_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_ICON_DICT_CHANGE)
end

function ClientEducationComponent:on_headFrame_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_headFrame_changed>>> ov", oldV, newV)
	end

	if self.isMainPlayer then
		pg.global.showBubbleMessageRaw(pg.getGameString("EXCHANGE_SUCCESS"))
	end

	facade:SendMessageCommand(MessageName.PLAYER_FRAME_CHANGE)
end

function ClientEducationComponent:on_isWholeTitle_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_isWholeTitle_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_TITLE_CHANGE)
end

function ClientEducationComponent:on_showTitles_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_showTitles_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	if self.isMainPlayer then
		pg.global.showBubbleMessageRaw(pg.getGameString("EXCHANGE_SUCCESS"))
	end

	facade:SendMessageCommand(MessageName.PLAYER_TITLE_CHANGE)
end

function ClientEducationComponent:on_showTitleExtra_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_showTitleExtra_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_TITLE_CHANGE)
end

function ClientEducationComponent:on_showTitleDicts_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_showTitleDicts_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_TITLE_CHANGE)
end

function ClientEducationComponent:on_cardBackground_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_cardBackground_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_CARD_BACKGROUND_CHANGE)
end

function ClientEducationComponent:on_cardBackgroundDicts_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_cardBackgroundDicts_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_CARD_BACKGROUND_CHANGE)
end

function ClientEducationComponent:on_showSignature_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_showSignature_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_SHOW_SIGNATURE_CHANGE)
end

function ClientEducationComponent:on_headFrameDicts_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onHeadFrameDicts_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_FRAME_DICT_CHANGE)
end

function ClientEducationComponent:on_playerLevel_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_playerLevel_changed>>> ov", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_LEVEL_CHANGE)

	if pg.global.UWAGPMManager then
		pg.global.UWAGPMManager:setUserLevel(newV)
	end

	self:executePetAdditiveAIEvent("LevelUpTrigger", {
		targetId = self.actorId
	})
end

function ClientEducationComponent:on_playerRank_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_playerRank_changed>>> ov", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_RANK_CHANGE, newV)
end

function ClientEducationComponent:on_unlockedAbilityMap_changed(oldV, newV)
	facade:SendMessageCommand(MessageName.PLAYER_UNLOCKED_SKILL_MAP)
end

function ClientEducationComponent:on_chatBubble_changed(oldV, newV)
	facade:SendMessageCommand(MessageName.PLAYER_CHAT_BUBBLE_CHANGE, newV)
end

function ClientEducationComponent:on_chatBubbleDicts_changed(oldV, newV)
	facade:SendMessageCommand(MessageName.PLAYER_CHAT_BUBBLE_DICTS_CHANGE, newV)
end

function ClientEducationComponent:RPC_SC_OnAbilityMapUpdate(reason, changed)
	facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
		self,
		reason,
		changed
	})
end

function ClientEducationComponent:onTempPetCurAbilityMapChanged(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onTempPetCurAbilityMapChanged", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
		self
	})
end

function ClientEducationComponent:onTempPetsExploreAbilityChange(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onTempPetsExploreAbilityChange", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
		self
	})
end

function ClientEducationComponent:onPetsExploreAbilityChange(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetsExploreAbilityChange", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
		self
	})
end

function ClientEducationComponent:on_skillNodeMap_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_skillNodeMap_changed>>> ov", oldV, newV)
	end

	facade:SendMessageCommand(MessageName.PLAYER_UNLOCKED_SKILL_TREE)
end

function ClientEducationComponent:on_starTitle_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_starTitle_changed>>> ov", oldV, newV)
	end

	facade:sendMsgToUI(MessageName.PLAYER_STAR_CHANGE)

	if pg and pg.global and pg.global.eventEmitter then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_STAR_TITLE_CHANGED, newV)
	end
end

function ClientEducationComponent:getSkillPoint()
	return ClientUtils.getItemCountById(SysConfigData.skillItemIds[1])
end

function ClientEducationComponent:getCatchBallRecycleRate()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.catch_ball_recycle_rate)
end

function ClientEducationComponent:getMaxControlLevel()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.max_control_level)
end

function ClientEducationComponent:getMaxCaptureLevel()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.max_capture_level)
end

function ClientEducationComponent:getShopPurchaseLevel()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.shop_purchase_level)
end

function ClientEducationComponent:getPetBoxExtraCount()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.pet_box_extra_count)
end

function ClientEducationComponent:getPetInitMoodAdd()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.pet_init_mood_add)
end

function ClientEducationComponent:getPetBallSlotExtraCount()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.pet_ball_slot_extra_count)
end

function ClientEducationComponent:getPetBallActionSpeedRate()
	return lume.clamp(self.actorCombatAttribute:getAttribValue(AttributeConst.pet_ball_action_speed_rate), 0, 1)
end

function ClientEducationComponent:getExploreRange()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.explore_range)
end

function ClientEducationComponent:isExploreOpen()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.explore_range) > 0
end

function ClientEducationComponent:isCameraOpen()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.camera_open) > 0
end

function ClientEducationComponent:getMaxSkillMasterLevel()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.max_skill_master_level)
end

function ClientEducationComponent:getMaxSkillCatchLevel()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.max_skill_catch_level)
end

function ClientEducationComponent:getBaseCatchRatio()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.base_catch_ratio)
end

function ClientEducationComponent:getBreedingDoubleEggsRatio()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.breeding_double_eggs_ratio)
end

function ClientEducationComponent:getPetExpAddRatio()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.pet_exp_add_ratio)
end

function ClientEducationComponent:entryDebugPrint()
	local res = {}

	res.getCatchBallRecycleRate = self:getCatchBallRecycleRate()
	res.getMaxControlLevel = self:getMaxControlLevel()
	res.getMaxCaptureLevel = self:getMaxCaptureLevel()
	res.getShopPurchaseLevel = self:getShopPurchaseLevel()
	res.getPetBoxExtraCount = self:getPetBoxExtraCount()
	res.getPetInitMoodAdd = self:getPetInitMoodAdd()
	res.getPetBallSlotExtraCount = self:getPetBallSlotExtraCount()
	res.getPetBallActionSpeedRate = self:getPetBallActionSpeedRate()
	res.getExploreRange = self:getExploreRange()
	res.isExploreOpen = self:isExploreOpen()
	res.isCameraOpen = self:isCameraOpen()
	res.getMaxSkillMasterLevel = self:getMaxSkillMasterLevel()
	res.getMaxSkillCatchLevel = self:getMaxSkillCatchLevel()

	return res
end

function ClientEducationComponent:switchToAbilityGroup(groupIndex)
	if not self:checkStatus(ConflictTypes.CT_SWITCH_SKILL_GROUP, true) then
		return
	end

	if self:isInCombat() then
		-- block empty
	else
		pg.me:serverMsg("RPC_CS_SelectCustomAbilityIds", false, groupIndex)
	end
end

return ClientEducationComponent
