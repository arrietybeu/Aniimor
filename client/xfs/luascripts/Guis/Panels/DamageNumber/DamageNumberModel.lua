-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DamageNumber\\DamageNumberModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("DamageNumberCtrl")
local DamageNumberModel = Class.LightClass("DamageNumberModel", UIModel)

DamageNumberModel.RES_PREFIX_STR = "UI_DamageNumber_"
DamageNumberModel.WORD_RES = {
	EXECUTE = "UI_DamageNumber_Execute",
	ENERGY = "UI_DamageNumber_Energy",
	IMMUNE = "UI_DamageNumber_Immune",
	HEAL = "UI_DamageNumber_Heal",
	POWER_BREAK = "UI_DamageNumber_PowerBreak",
	CRITICAL = "UI_DamageNumber_" .. UIConst.DAMAGE_UI_TYPE_DESC.CRITICAL,
	BASIC_WEAK = "UI_DamageNumber_" .. UIConst.DAMAGE_UI_TYPE_DESC.NON_CRITICAL .. "_" .. UIConst.DAMAGE_UI_TYPE_DESC.WEAK,
	BASIC_NORMAL = "UI_DamageNumber_" .. UIConst.DAMAGE_UI_TYPE_DESC.NON_CRITICAL .. "_" .. UIConst.DAMAGE_UI_TYPE_DESC.NORMAL,
	BASIC_EXCELLENT = "UI_DamageNumber_" .. UIConst.DAMAGE_UI_TYPE_DESC.NON_CRITICAL .. "_" .. UIConst.DAMAGE_UI_TYPE_DESC.EXCELLENT
}

do
	local ids = {}

	for _, id in pairs(DamageNumberModel.WORD_RES) do
		ids[#ids + 1] = id
	end

	DamageNumberModel.ALL_RES_IDS = ids
end

DamageNumberModel.BASIC_RES_BY_SHOW_ENUM = {
	[Const.DAMAGE_SHOW_ENUM_WEAK] = DamageNumberModel.WORD_RES.BASIC_WEAK,
	[Const.DAMAGE_SHOW_ENUM_NORMAL] = DamageNumberModel.WORD_RES.BASIC_NORMAL,
	[Const.DAMAGE_SHOW_ENUM_EXCELLENT] = DamageNumberModel.WORD_RES.BASIC_EXCELLENT
}
DamageNumberModel.RES_EP_CONFIG_ID = DamageNumberModel.WORD_RES.ENERGY
DamageNumberModel.RES_BP_CONFIG_ID = DamageNumberModel.WORD_RES.BASIC_NORMAL
DamageNumberModel.BOSS_CATCH_TYPE_RES_MAP = {
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH1] = DamageNumberModel.WORD_RES.BASIC_NORMAL,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH2] = DamageNumberModel.WORD_RES.BASIC_EXCELLENT,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH3] = DamageNumberModel.WORD_RES.POWER_BREAK
}
DamageNumberModel.VX_DMGTYPE_ANI_PRIORITY = {
	CRITICAL = 2,
	NORMAL = 1,
	BREAK = 3
}
DamageNumberModel.VX_DMGNUM_ANINAMES = {
	[Const.DAMAGE_SHOW_ENUM_WEAK] = {
		"VX_NumLow_In",
		"VX_NumLow_Critical_In",
		"VX_NumLow_Break_In"
	},
	[Const.DAMAGE_SHOW_ENUM_NORMAL] = {
		"VX_NumNormal_In",
		"VX_NumNormal_Critical_In",
		"VX_NumNormal_Break_In"
	},
	[Const.DAMAGE_SHOW_ENUM_EXCELLENT] = {
		"VX_NumHigh_In",
		"VX_NumHigh_Critical_In",
		"VX_NumHigh_Break_In"
	}
}
DamageNumberModel.VX_DMGNUM_ANINAMES_POWER_BREAK = {
	[Const.DAMAGE_SHOW_ENUM_WEAK] = "VX_NumLow_PowerBreak_In",
	[Const.DAMAGE_SHOW_ENUM_NORMAL] = "VX_NumNormal_PowerBreak_In",
	[Const.DAMAGE_SHOW_ENUM_EXCELLENT] = "VX_NumHigh_PowerBreak_In"
}
DamageNumberModel.VX_DMGNUM_ANINAMES_MINE = {
	"VX_NumMine_Low_In",
	"VX_NumMine_Normal_In",
	"VX_NumMine_High_In"
}
DamageNumberModel.TAG_NUM_BREAKE_IN_ANIM = "Break_In"
DamageNumberModel.VX_NUM_RECOVER_IN_ANIM = "VX_NumRecover_In"
DamageNumberModel.VX_NUM_IMMUNE_IN_ANIM = "VX_NumImmune_In"
DamageNumberModel.VX_NUM_EXECUTE_IN_ANIM = "VX_Pb_DmgNumber_Execute_In"
DamageNumberModel.DAMAGE_STATUS_IDX = {
	NULL = 3,
	SPECIAL = 2,
	IMMUNE = 1,
	MISS = 0
}
DamageNumberModel.DAMAGE_DESC_IDX = {
	CLEAR = 2,
	FROZEN = 1,
	PALSY = 0
}

function DamageNumberModel:getFinalDmgAniByDmgType(damageInfo, damageShowEnum)
	if not damageInfo then
		return nil
	end

	damageShowEnum = damageShowEnum or Const.DAMAGE_SHOW_ENUM_NORMAL

	local dmgPriority = self.VX_DMGTYPE_ANI_PRIORITY.NORMAL

	if damageInfo.isBreakEnhance then
		dmgPriority = self.VX_DMGTYPE_ANI_PRIORITY.BREAK
	elseif damageInfo.isCritical and not damageInfo.isPlayerBeAttacked then
		dmgPriority = self.VX_DMGTYPE_ANI_PRIORITY.CRITICAL
	end

	if damageInfo.isPowerfulStrike then
		local aniName = self.VX_DMGNUM_ANINAMES_POWER_BREAK[damageShowEnum]

		if aniName then
			return aniName
		end
	end

	local isSelf = pg.me and pg.me.id == damageInfo.targetId
	local isSelfPet = pg.me and pg.me.pets and pg.me.pets[damageInfo.targetId]
	local isSelfEgg = damageInfo.isAttackSelfControlEgg

	if isSelf or isSelfPet or isSelfEgg then
		return self.VX_DMGNUM_ANINAMES_MINE[damageShowEnum]
	end

	local aniNames = self.VX_DMGNUM_ANINAMES[damageShowEnum]

	if not aniNames then
		return self.VX_DMGNUM_ANINAMES[Const.DAMAGE_SHOW_ENUM_NORMAL][dmgPriority]
	end

	return aniNames[dmgPriority]
end

function DamageNumberModel:getSpecialIndexInPrefab(damageStatus)
	if damageStatus == AbilityConst.DAMAGE_UI_TAG_PALSY then
		return self.DAMAGE_DESC_IDX.PALSY
	elseif damageStatus == AbilityConst.DAMAGE_UI_TAG_FROZEN then
		return self.DAMAGE_DESC_IDX.FROZEN
	elseif damageStatus == AbilityConst.DAMAGE_UI_TAG_REMOVE_BUFF then
		return self.DAMAGE_DESC_IDX.CLEAR
	else
		return nil
	end
end

DamageNumberModel.DAMAGE_NUMBER_IDX = {
	ENERGY = 15,
	HEAL = 12,
	NULL = 17,
	PLAYER_BREAK = 16,
	ENEMY_NORMAL_CRITICAL_NONBREAK = 14,
	ENEMY_NORMAL_BASIC_NONBREAK = 13,
	PARTNER_HEAVY_CRITICAL_BREAK = 11,
	PARTNER_HEAVY_BASIC_BREAK = 10,
	PARTNER_HEAVY_CRITICAL_NONBREAK = 9,
	PARTNER_HEAVY_BASIC_NONBREAK = 8,
	PARTNER_NORMAL_CRITICAL_BREAK = 7,
	PARTNER_NORMAL_BASIC_BREAK = 6,
	PARTNER_NORMAL_CRITICAL_NONBREAK = 5,
	PARTNER_NORMAL_BASIC_NONBREAK = 4,
	PARTNER_LIGHT_CRITICAL_BREAK = 3,
	PARTNER_LIGHT_BASIC_BREAK = 2,
	PARTNER_LIGHT_CRITICAL_NONBREAK = 1,
	PARTNER_LIGHT_BASIC_NONBREAK = 0
}

function DamageNumberModel:getNumberIndexInPrefab(info)
	local map = self.DAMAGE_NUMBER_IDX

	if info.hurtType == AbilityConst.HURT_TYPE_HP_ADD then
		return map.HEAL
	elseif info.hurtType == AbilityConst.HURT_TYPE_HP_REDUCE or info.hurtType == AbilityConst.HURT_TYPE_FORCE then
		if info.isToSelf then
			return info.isCritical and map.ENEMY_NORMAL_CRITICAL_NONBREAK or map.ENEMY_NORMAL_BASIC_NONBREAK
		elseif info.damageShowEnum == Const.DAMAGE_SHOW_ENUM_WEAK then
			if info.isCritical then
				return info.isBreakEnhance and map.PARTNER_LIGHT_CRITICAL_BREAK or map.PARTNER_LIGHT_CRITICAL_NONBREAK
			else
				return info.isBreakEnhance and map.PARTNER_LIGHT_BASIC_BREAK or map.PARTNER_LIGHT_BASIC_NONBREAK
			end
		elseif info.damageShowEnum == Const.DAMAGE_SHOW_ENUM_NORMAL then
			if info.isCritical then
				return info.isBreakEnhance and map.PARTNER_NORMAL_CRITICAL_BREAK or map.PARTNER_NORMAL_CRITICAL_NONBREAK
			else
				return info.isBreakEnhance and map.PARTNER_NORMAL_BASIC_BREAK or map.PARTNER_NORMAL_BASIC_NONBREAK
			end
		elseif info.damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT then
			if info.isCritical then
				return info.isBreakEnhance and map.PARTNER_HEAVY_CRITICAL_BREAK or map.PARTNER_HEAVY_CRITICAL_NONBREAK
			else
				return info.isBreakEnhance and map.PARTNER_HEAVY_BASIC_BREAK or map.PARTNER_HEAVY_BASIC_NONBREAK
			end
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl damageShowEnum Err", info.damageShowEnum)
			end

			return nil
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("DamageNumberCtrl hurtType Err", info.hurtType)
		end

		return nil
	end
end

function DamageNumberModel:getEpIndexInPrefab()
	return self.DAMAGE_NUMBER_IDX.ENERGY
end

function DamageNumberModel:getBreakIndexInPrefab()
	return self.DAMAGE_NUMBER_IDX.PLAYER_BREAK
end

function DamageNumberModel:getEpWordConfigId()
	return "ep_playerPet_playerPet"
end

function DamageNumberModel:getBreakWordConfigId()
	return "num_player_enemy_nonbreak_basic_light"
end

function DamageNumberModel:getSpecialStatusWordConfigId()
	return nil
end

return DamageNumberModel
