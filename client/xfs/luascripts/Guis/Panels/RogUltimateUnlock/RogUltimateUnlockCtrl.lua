-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogUltimateUnlock\\RogUltimateUnlockCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityParamData = require("Data.ability_param_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RogueUtils = require("Utils.RogueUtils")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local RogueConst = require("Const.RogueConst")
local RogueTransformData = require("Data.rogue_transform_data")
local RogUltimateUnlockCtrl = Class.LightClass("RogUltimateUnlockCtrl", UICtrl)

function RogUltimateUnlockCtrl:onOpen(info)
	self.isClosing = false

	if not pg.me or not pg.me.space or not pg.me.space:isRogueEnv() then
		self:close()

		return
	end

	self.view.imgBossUImage.url = RogueUtils.getUltimatePetTransformVerticalPainting()
	self.abilityId = RogueUtils.getUltimatePetTransformAbilityId()
	self.abilityParamId = AbilityUtils.getAbilityParamId(self.abilityId)
	self.abilityCfg = AbilityParamData[self.abilityParamId]
	self.ultimatePetTemplateId = RogueUtils.getUltimatePetTemplateID()
	self.rogPetCount = RogueConst.MAX_PET_COUNT
	self.rogSpace = pg.me.space

	if not self.abilityCfg then
		self:close()

		return
	end

	ClientTextUtils.setText(self.view.bossTipUBaseText, pg.getGameString("ROGUE_TRANSFORM_BOSS_TIP"))
	self:_refreshFinalShow()
	self:_refreshUnlockShow()
	UIUtils.PlayAnimation(self.view.animRoot, "VX_Ani_Tower_Unlock_Transformation_In")

	local startFrame = 115

	self.radarTimerId = TimerManager.addTimer(startFrame / 60, function()
		self:_refreshRadarShow()
	end)

	pg.game.audio:playEvent("SFX_UI_Rouge_GetTransformed")
end

function RogUltimateUnlockCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.radarTimerId then
		TimerManager.removeTimer(self.radarTimerId)

		self.radarTimerId = nil
	end

	if RogueUtils.isInRogueSpace() then
		pg.me.space:nextCacheInfo()
	end
end

function RogUltimateUnlockCtrl:close()
	if self.isClosing then
		return
	end

	self.isClosing = true

	UIUtils.PlayAnimation(self.view.animRoot, "VX_Ani_Tower_Unlock_Transformation_Out", function()
		UICtrl.close(self)
	end)
end

function RogUltimateUnlockCtrl:_refreshUnlockShow()
	self.view.imgUltimateUnlock.url = self.abilityCfg.icon

	ClientTextUtils.setTextWithId(self.view.txtUltimateUnlock, self.abilityCfg.name)
end

function RogUltimateUnlockCtrl:_refreshFinalShow()
	function self.view.btnClose.luaClick()
		self:close()
	end

	function self.view.btnRules.luaRenderTooltip(button, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("TOWER_ROGUE_TRANSFORM_TIP"))
	end

	local series = pg.me.rogueUltimateSeries
	local transformCfg = RogueTransformData[series]

	if transformCfg then
		RogueUtils.renderSkillBtn(self.view.itemUltimate, transformCfg.bossUltimateSkillId, transformCfg.bossUltimateSkillVideo)
		RogueUtils.renderSkillBtn(self.view.itemSkill1, transformCfg.bossSkill1Id, transformCfg.bossSkill1Video)
		RogueUtils.renderSkillBtn(self.view.itemSkill2, transformCfg.bossSkill2Id, transformCfg.bossSkill2Video)
	end

	local petInfos = self.rogSpace.petInfos

	for i = 1, self.rogPetCount do
		local petInfo = petInfos[i]

		if petInfo then
			LuaUIUtils.renderPetHeadRound(self.view.itemPet[i], petInfo)
		else
			self.view.itemPet[i]:TryChangePage("state", 2)
		end

		self.view.itemPet[i].interactable = false
		self.view.itemPet[i].draggable = false
	end

	RogueUtils.renderUltimatePetPropRadar(self.view.compRadar, true)
end

function RogUltimateUnlockCtrl:_refreshRadarShow()
	RogueUtils.renderUltimatePetPropRadarTransit(self.view.compRadar)
end

return RogUltimateUnlockCtrl
